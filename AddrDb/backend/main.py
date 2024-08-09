# Main endpoints/routes for API to access/create resources
# Define routes needed

# request object and jsonify to return json data
from flask import request, jsonify
from config import app, db 
from models import Contact

# Create: submit request to create endpoint
# GET context
# specify route/endpoint in the following decorator
@app.route("/contacts", methods=["GET"]) # specify valid method type GET method for /contacts url
def get_contacts(): # function to handle get request that is sent to /contact endpoint
    contacts = Contact.query.all() # use flask sqlalchemy to get all different contacts in db (non returnable python object)
    # `contacts` is a list of contact objects (which have the to_json method); call method for all different contacts
    json_contacts = list(map(lambda x: x.to_json(), contacts))
    # map applies lambda function to all elements in the list `contacts` and returns the following new list with json
    return jsonify({"contacts": json_contacts}) # return json object data instead of python object that says "contacts: json_contacts" 
    # "contacts" key in python dict; associated with json_contacts (list created)
    # return python dict object ({"contacts": json_contacts}) converted to json data


# run flask application
if __name__ == "__main__": # if run main.py, then exececute code
    with app.app_context(): # instantiate db by getting context of app
        db.create_all() # create all models defined in database only if not created
    # THEN run the code (app, endpoints, and API)
    app.run(debug=True) # debug only if main.py ran directly, not if main.py imported