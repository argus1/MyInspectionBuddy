# Import necessary modules
from flask import request, jsonify
from config import app, db 
from models import Contact

# Define route to get all contacts
@app.route("/contacts", methods=["GET"])
def get_contacts():
    # Query all contacts from the database
    contacts = Contact.query.all()  # Fetch all contacts from the DB
    json_contacts = [contact.to_json() for contact in contacts]  # Convert each contact to JSON
    return jsonify({"contacts": json_contacts})  # Return JSON response


# Define route to search/filter contacts
@app.route("/search", methods=["GET"])
def get_data():
    # Capture query parameters from the request
    business_name = request.args.get('businessName')
    license_code_description = request.args.get('licenseCodeDescription')
    license_status_code = request.args.get('licenseStatusCode')
    license_address_type_description = request.args.get('licenseAddressTypeDescription')
    address_line1 = request.args.get('addressLine1')
    city = request.args.get('city')
    state = request.args.get('state')
    zip_code = request.args.get('zip')
    county_code = request.args.get('countyCode')
    expiration_date = request.args.get('expirationDate')

    # Query the database and apply filtering dynamically using SQLAlchemy
    query = Contact.query  # Start with the base query
    
    # Apply filters dynamically only if the parameter exists
    if business_name:
        query = query.filter(Contact.businessName == business_name)
    if license_code_description:
        query = query.filter(Contact.licenseCodeDescription == license_code_description)
    if license_status_code:
        query = query.filter(Contact.licenseStatusCode == license_status_code)
    if license_address_type_description:
        query = query.filter(Contact.licenseAddressTypeDescription == license_address_type_description)
    if address_line1:
        query = query.filter(Contact.addressLine1 == address_line1)
    if city:
        query = query.filter(Contact.city == city)
    if state:
        query = query.filter(Contact.state == state)
    if zip_code:
        query = query.filter(Contact.zip == zip_code)
    if county_code:
        query = query.filter(Contact.countyCode == county_code)
    if expiration_date:
        query = query.filter(Contact.expirationDate == expiration_date)

    # Execute the query and get all matching contacts
    filtered_contacts = query.all()
    
    # Convert filtered results to JSON
    json_contacts = [contact.to_json() for contact in filtered_contacts]
    
    return jsonify(json_contacts)  # Return filtered JSON contacts


# Run the Flask application
if __name__ == "__main__":
    with app.app_context():  # Ensure the app context is available
        db.create_all()  # Create the tables if they don't exist
    app.run(debug=True)  # Run the app in debug mode
