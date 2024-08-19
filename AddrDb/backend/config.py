# Main configuration of app
# Build API first with flask

import os
from dotenv import load_dotenv


from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS # Cross Origin Request: send request here [backend] from a different url

# allow CORS for all domains on all routes
app = Flask(__name__)
CORS(app) # wrap app in CORS

load_dotenv()
db_user = os.environ['DB_USER']
db_password = os.environ['DB_PASSWORD']
db_name = os.environ['DB_NAME']

# Initialize database
app.config["SQLALCHEMY_DATABASE_URI"] = "mysql://{db_user}:{db_password}@localhost/{db_name}".format(
    db_user=db_user, db_password=db_password, db_name=db_name
    )
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Instance of the database
db = SQLAlchemy(app)