from flask import Blueprint, render_template, redirect, url_for, flash, abort
from flask_login import login_required, current_user

from app.forms import NoteForm
from app.models import Note
from app.extensions import db

notes_bp = Blueprint("notes", __name__, url_prefix="/notes")


@notes_bp.route("/")
@login_required
def list_notes():
    notes = Note.query.filter_by(user_id=current_user.id).all()
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


@notes_bp.route("/<int:id>/edit", methods=["GET", "POST"])
@login_required
def edit_note(id):
    note = Note.query.get_or_404(id)

    # Verify ownership
    if note.user_id != current_user.id:
        abort(404)

    form = NoteForm(obj=note)

    if form.validate_on_submit():
        note.title = form.title.data
        note.content = form.content.data

        db.session.commit()

        flash("Note updated successfully.", "success")
        return redirect(url_for("notes.list_notes"))

    return render_template("notes/edit.html", form=form)


@notes_bp.route("/<int:id>/delete")
@login_required
def delete_note(id):
    note = Note.query.get_or_404(id)

    # Verify ownership
    if note.user_id != current_user.id:
        abort(404)

    db.session.delete(note)
    db.session.commit()

    flash("Note deleted.", "info")
    return redirect(url_for("notes.list_notes"))