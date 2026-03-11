import click
from flask.cli import with_appcontext

from app.extensions import db
from app.models import User, Note


@click.command("init-db")
@click.option("--seed", is_flag=True, help="Insert sample users and notes.")
@with_appcontext
def init_db(seed):
    db.create_all()
    click.echo("Database tables created.")

    if not seed:
        return

    seeded = False

    if not User.query.filter_by(username="demo_user").first():
        demo_user = User(username="demo_user", email="demo@example.com")
        demo_user.set_password("DemoPass123")
        db.session.add(demo_user)
        db.session.flush()

        db.session.add(
            Note(
                title="Welcome Note",
                content="This is a seeded note for local testing.",
                user_id=demo_user.id,
            )
        )
        seeded = True

    if not User.query.filter_by(username="alice").first():
        alice = User(username="alice", email="alice@example.com")
        alice.set_password("AlicePass123")
        db.session.add(alice)
        seeded = True

    if seeded:
        db.session.commit()
        click.echo("Seed data inserted.")
    else:
        click.echo("Seed skipped: users already exist.")
