# Flask API
# Import necessary modules
import logging
from flask import request, jsonify
from config import app, db 
from models import Contact
from datetime import datetime
# from sqlalchemy import and_

# Define route to get all contacts
@app.route("/contacts", methods=["GET"])
def get_contacts():
    # Query all contacts from the database
    contacts = Contact.query.all()  # Fetch all contacts from the DB
    json_contacts = [contact.to_json() for contact in contacts]  # Convert each contact to JSON
    return jsonify({"contacts": json_contacts})  # Return JSON response


# Define route to search/filter contacts
@app.route("/search", methods=["POST"])
def search_contacts():
    logging.info("Received a request.")  # Log request
    data = request.get_json()  # Get JSON data from the request
    logging.info(f"Request data: {data}")  # Log the received request

    # Capture query parameters from the request data
    business_name = data.get('businessName')
    license_code_description = data.get('licenseCodeDescription')
    license_status_code = data.get('licenseStatusCode')
    license_address_type_description = data.get('licenseAddressTypeDescription')
    address_line1 = data.get('addressLine1')
    city = data.get('city')
    state = data.get('state')
    zip_code = data.get('zip')
    county_code = data.get('countyCode')
    expiration_date = data.get('expirationDate')
    start_date = parse_date(data.get('fromDate'))
    end_date = parse_date(data.get('toDate'))

    # Ensure at least one parameter is provided
    if not (business_name or license_code_description or license_status_code or 
            license_address_type_description or address_line1 or city or state or 
            zip_code or county_code or expiration_date):
        return jsonify({"error": "At least one search parameter is required"}), 400

    # Build the query dynamically using SQLAlchemy's filtering
    query = Contact.query

    if business_name:
        query = query.filter(Contact.business_name.ilike(f"%{business_name}%"))
    if license_code_description:
        query = query.filter(Contact.license_code_description.ilike(f"%{license_code_description}%"))
    if license_status_code:
        query = query.filter(Contact.license_status_code == license_status_code)
    if license_address_type_description:
        query = query.filter(Contact.license_address_type_description.ilike(f"%{license_address_type_description}%"))
    if address_line1:
        query = query.filter(Contact.address_line1.ilike(f"%{address_line1}%"))
    if city:
        query = query.filter(Contact.city.ilike(f"%{city}%"))
    if state:
        query = query.filter(Contact.state == state)
    if zip_code:
        query = query.filter(Contact.zip_code == zip_code)
    if county_code:
        query = query.filter(Contact.county_code == county_code)
    # if expiration_date:
    #    query = query.filter(Contact.expiration_date == expiration_date)
    # if start_date and end_date:
    #    query = query.filter(Contact.expiration_date.between(start_date, end_date))
        
    if start_date:
        query = query.filter(Contact.expiration_date >= start_date)

    if end_date:
        query = query.filter(Contact.expiration_date <= end_date)

    # Execute the query and fetch the results
    contacts = query.all()
    
    # Convert results to JSON format
    json_contacts = [contact.to_json() for contact in contacts]

    return jsonify({
        "contacts": json_contacts,
        "fromDate": data.get('fromDate', 'Not set'),
        "toDate": data.get('toDate', 'Not set')
    })

def parse_date(date_str):
    if not date_str or date_str == 'Not set':
        return None
    try:
        return datetime.strptime(date_str, '%Y-%m-%d').date()
    except ValueError:
        return None

@app.route("/unique-values", methods=["GET"])
def get_unique_values():
    unique_status = sorted({uniq.licenseStatusCode for uniq in Contact.query.all()})
    unique_address = sorted({uniq.licenseAddressTypeDescription for uniq in Contact.query.all()})
    unique_counties = sorted({uniq.countyCode for uniq in Contact.query.all()})
   
    return jsonify({
        'status': unique_status,
        'addressType': unique_address,
        'county': unique_counties
    })


# Run the Flask application
if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(debug=True)
