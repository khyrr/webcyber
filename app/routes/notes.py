from datetime import datetime, timedelta

from flask import Blueprint, render_template, redirect, url_for, flash, abort, Response, request
from flask_login import login_required, current_user

from app.forms import NoteForm
from app.models import Note
from app.extensions import db

notes_bp = Blueprint("notes", __name__, url_prefix="/notes")

_TRASH_TTL_DAYS = 30


@notes_bp.route("/")
@login_required
def list_notes():
    notes = (
        Note.query
        .filter_by(user_id=current_user.id, is_archived=False, is_trashed=False)
        .order_by(Note.is_pinned.desc(), Note.updated_at.desc())
        .all()
    )
    return render_template("notes/list.html", notes=notes)


@notes_bp.route("/create", methods=["GET", "POST"])
@login_required
def create_note():
    form = NoteForm()

    if form.validate_on_submit():
        note = Note(
            title=form.title.data,
            content=form.content.data,
            user_id=current_user.id
        )
        db.session.add(note)
        db.session.commit()
        flash("Note created successfully.", "success")
        return redirect(url_for("notes.list_notes"))

    return render_template("notes/create.html", form=form)


@notes_bp.route("/<int:id>")
@login_required
def view_note(id):
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    return render_template("notes/view.html", note=note)


@notes_bp.route("/<int:id>/edit", methods=["GET", "POST"])
@login_required
def edit_note(id):
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    form = NoteForm(obj=note)

    if form.validate_on_submit():
        note.title = form.title.data
        note.content = form.content.data
        note.updated_at = datetime.utcnow()
        db.session.commit()
        flash("Note updated successfully.", "success")
        return redirect(url_for("notes.view_note", id=note.id))

    return render_template("notes/edit.html", form=form, note=note)


@notes_bp.route("/<int:id>/delete", methods=["POST"])
@login_required
def delete_note(id):
    """Move note to Trash (soft delete, auto-purges after 30 days)."""
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    note.is_trashed = True
    note.trashed_at = datetime.utcnow()
    note.is_pinned = False
    db.session.commit()

    flash("Note moved to Trash.", "info")
    return redirect(url_for("notes.list_notes"))


@notes_bp.route("/<int:id>/pin", methods=["POST"])
@login_required
def toggle_pin(id):
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    note.is_pinned = not note.is_pinned
    db.session.commit()
    return redirect(url_for("notes.list_notes"))


# ── Archive routes ─────────────────────────────────────────────

@notes_bp.route("/<int:id>/export")
@login_required
def export_note(id):
    """Download the note as .md (default) or .txt (?fmt=txt)."""
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    fmt = request.args.get("fmt", "md").lower()
    if fmt not in ("md", "txt"):
        fmt = "md"

    created = note.created_at.strftime("%Y-%m-%d %H:%M UTC")
    updated = note.updated_at.strftime("%Y-%m-%d %H:%M UTC") if note.updated_at else created

    # Sanitise title to a safe filename
    safe_name = "".join(c if c.isalnum() or c in " -_" else "_" for c in note.title).strip()
    safe_name = safe_name[:80] or "note"

    if fmt == "txt":
        import re
        body = note.content
        body = re.sub(r'^#{1,6}\s+', '', body, flags=re.MULTILINE)  # headings
        body = re.sub(r'\*\*(.+?)\*\*', r'\1', body)               # bold
        body = re.sub(r'\*(.+?)\*', r'\1', body)                   # italic
        body = re.sub(r'`(.+?)`', r'\1', body)                     # inline code
        body = re.sub(r'^```.*?^```', '', body, flags=re.MULTILINE | re.DOTALL)  # code blocks
        body = re.sub(r'!?\[([^\]]+)\]\([^)]+\)', r'\1', body)    # links / images
        body = re.sub(r'^[-*+]\s+', '', body, flags=re.MULTILINE)  # list bullets
        body = re.sub(r'^>\s?', '', body, flags=re.MULTILINE)       # blockquotes
        body = re.sub(r'\n{3,}', '\n\n', body).strip()             # collapse blank lines
        content = f"{note.title}\n{'=' * len(note.title)}\n\nCreated : {created}\nUpdated : {updated}\n\n{body}\n"
        mimetype = "text/plain; charset=utf-8"
        filename = f"{safe_name}.txt"
    else:
        content = (
            f"# {note.title}\n\n"
            f"<!-- created: {created} | updated: {updated} -->\n\n"
            f"{note.content}\n"
        )
        mimetype = "text/markdown; charset=utf-8"
        filename = f"{safe_name}.md"

    return Response(
        content,
        mimetype=mimetype,
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@notes_bp.route("/<int:id>/archive", methods=["POST"])
@login_required
def archive_note(id):
    """Move note to Archive (preserved indefinitely)."""
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    note.is_archived = True
    note.archived_at = datetime.utcnow()
    note.is_pinned = False
    db.session.commit()

    flash("Note archived.", "info")
    return redirect(url_for("notes.list_notes"))


@notes_bp.route("/archive")
@login_required
def archive_list():
    notes = (
        Note.query
        .filter_by(user_id=current_user.id, is_archived=True)
        .order_by(Note.archived_at.desc())
        .all()
    )
    return render_template("notes/archive.html", notes=notes)


@notes_bp.route("/<int:id>/restore", methods=["POST"])
@login_required
def restore_note(id):
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    note.is_archived = False
    note.archived_at = None
    db.session.commit()

    flash("Note restored.", "success")
    return redirect(url_for("notes.archive_list"))


@notes_bp.route("/<int:id>/delete-permanent", methods=["POST"])
@login_required
def delete_permanent(id):
    """Permanently delete a note from the Archive."""
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    db.session.delete(note)
    db.session.commit()

    flash("Note permanently deleted.", "info")
    return redirect(url_for("notes.archive_list"))


# ── Trash routes ───────────────────────────────────────────────

@notes_bp.route("/trash")
@login_required
def trash_list():
    # Auto-purge notes trashed more than 30 days ago
    cutoff = datetime.utcnow() - timedelta(days=_TRASH_TTL_DAYS)
    Note.query.filter(
        Note.user_id == current_user.id,
        Note.is_trashed == True,
        Note.trashed_at <= cutoff
    ).delete(synchronize_session=False)
    db.session.commit()

    notes = (
        Note.query
        .filter_by(user_id=current_user.id, is_trashed=True)
        .order_by(Note.trashed_at.desc())
        .all()
    )
    return render_template("notes/trash.html", notes=notes, now=datetime.utcnow())


@notes_bp.route("/<int:id>/restore-trash", methods=["POST"])
@login_required
def restore_from_trash(id):
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    note.is_trashed = False
    note.trashed_at = None
    db.session.commit()

    flash("Note restored.", "success")
    return redirect(url_for("notes.trash_list"))


@notes_bp.route("/<int:id>/delete-permanent-trash", methods=["POST"])
@login_required
def delete_permanent_trash(id):
    """Permanently delete a note from the Trash."""
    note = Note.query.get_or_404(id)

    if note.user_id != current_user.id:
        abort(404)

    db.session.delete(note)
    db.session.commit()

    flash("Note permanently deleted.", "info")
    return redirect(url_for("notes.trash_list"))


@notes_bp.route("/trash/empty", methods=["POST"])
@login_required
def empty_trash():
    """Permanently delete all notes in Trash."""
    Note.query.filter_by(
        user_id=current_user.id,
        is_trashed=True
    ).delete(synchronize_session=False)
    db.session.commit()

    flash("Trash emptied.", "info")
    return redirect(url_for("notes.trash_list"))

