from flask import Flask, redirect, url_for
from markupsafe import Markup
import mistune

from app.config import Config
from app.extensions import db, login_manager, csrf, migrate
from app.models import User

_md = mistune.create_markdown(
    plugins=['strikethrough', 'table', 'task_lists'],
    escape=True,
)

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Initialize extensions
    db.init_app(app)
    login_manager.init_app(app)
    csrf.init_app(app)
    migrate.init_app(app, db)

    # Markdown filter — safe because mistune escape=True
    @app.template_filter('markdown')
    def markdown_filter(text):
        return Markup(_md(text or ''))

    # Login manager configuration
    login_manager.login_view = "auth.login"

    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.notes import notes_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(notes_bp)

    @app.route("/")
    def index():
        return redirect(url_for("auth.login"))

    from app.commands import init_db
    app.cli.add_command(init_db)

    return app