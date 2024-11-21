# Flask API
# Contain Database models and layout the different types of data we are working with
# How we interact with database and we use Flask alchemy to interact with database
# Create python class to represent db entry as well as define the datayprd that the object will be storing

from config import db # relative import from config.py
from datetime import datetime

# db model (Fields) represented as a python class
class Contact(db.Model):
    license_address_id = db.Column(db.Integer, primary_key=True) # specify type of field
    license_id = db.Column(db.Integer) # unique
    license_number = db.Column(db.Integer) # unique
    license_code_description = db.Column(db.String(10), unique=True, nullable=True)
    application_form_type_id = db.Column(db.Integer)
    license_type_id = db.Column(db.Integer)
    license_type_code = db.Column(db.String(2), unique=True, nullable=True)
    license_status_id = db.Column(db.Integer)
    license_status_code = db.Column(db.String(2), unique=True, nullable=True) # String
    license_classification_id = db.Column(db.Integer) # edited (db.Datetime, nullable=True, default=datetime.now)
    license_classification_code = db.Column(db.String(80), unique=False, nullable=True) 
    license_classification_description = db.Column(db.String(80), unique=False, nullable=True) 
    expiration_date = db.Column(db.DateTime, nullable=True)
    firm_id = db.Column(db.Integer) # unique
    corporate_name = db.Column(db.String(80), unique=False, nullable=True)
    business_name = db.Column(db.String(80), unique=False, nullable=True)
    doing_business_as = db.Column(db.String(80), unique=False, nullable=True)
    state_incorporation = db.Column(db.String(80), unique=False, nullable=True)
    address_line_1 = db.Column(db.String(80), unique=True, nullable=True) # unique
    address_line_2 = db.Column(db.String(80), unique=False, nullable=True) 
    city = db.Column(db.String(80), unique=False, nullable=True) 
    state = db.Column(db.String(80), unique=False, nullable=True) 
    zip = db.Column(db.String(80), unique=False, nullable=True) 
    county_id = db.Column(db.Integer)
    county_code = db.Column(db.String(80), unique=False, nullable=True) 
    license_address_type_id = db.Column(db.Integer)
    license_address_type_code = db.Column(db.String(80), unique=False, nullable=True) 
    license_address_type_description = db.Column(db.String(80), unique=False, nullable=True) 
    exemptee_last_name = db.Column(db.String(80), unique=False, nullable=True) 
    exemptee_first_name = db.Column(db.String(80), unique=False, nullable=True)
 

    # Fields on class object into python dict
    def to_json(self): # convert to json object (to be passed from API to frontend)
        return { # return python dict
            "licenseAddressId": self.license_address_id,
            "licenseId": self.license_id,
            "licenseNumber": self.license_number,
            "licenseCodeDescription": self.license_code_description,
            "applicationFormTypeId": self.application_form_type_id,
            "licenseTypeId": self.license_type_id,
            "licenseTypeCode": self.license_type_code,
            "licenseStatusId": self.license_status_id,
            "licenseStatusCode": self.license_status_code,
            "licenseClassificationId": self.license_classification_id,
            "licenseClassificationCode": self.license_classification_code,
            "licenseClassificationDescription": self.license_classification_description,
            "expirationDate": self.expiration_date.strftime('%m/%d/%Y') if self.expiration_date else '',
            "firmId": self.firm_id,
            "corporateName": self.corporate_name,
            "businessName": self.business_name,
            "doingBusinessAs": self.doing_business_as,
            "stateIncorporation": self.state_incorporation,
            "addressLine1": self.address_line_1,
            "addressLine2": self.address_line_2,
            "city": self.city,
            "state": self.state,
            "zip": self.zip,
            "countyId": self.county_id,
            "countyCode": self.county_code,
            "licenseAddressTypeId": self.license_address_type_id,
            "licenseAddressTypeCode": self.license_address_type_code,
            "licenseAddressTypeDescription": self.license_address_type_description,
            "exempteeLastName": self.exemptee_last_name,
            "exempteeFirstName": self.exemptee_first_name
        }