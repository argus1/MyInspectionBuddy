# Database models
# Flask alchemy to interact with database
# Create python class to represent db entry

from config import db # relative import from config.py
from datetime import datetime

# db model as a python class
class Contact(db.Model):
    LicenseAddressId = db.Column(db.Integer, primary_key=True) # unique
    LicenseId = db.Column(db.Integer, db.ForeignKey('LicenseId')) # unique
    LicenseNumber = db.Column(db.Integer, db.ForeignKey('LicenseNumber')) # unique
    LicenseCodeDescription = db.Column(db.String(10), unique=True, nullable=True)
    ApplicationFormTypeId = db.Column(db.Integer)
    LicenseTypeId = db.Column(db.Integer)
    LicenseTypeCode = db.Column(db.String(2), unique=True, nullable=True)
    LicenseStatusId = db.Column(db.Integer)
    LicenseStatusCode = db.Column(db.String(2), unique=True, nullable=True) # String
    LicenseClassificationId = db.Column(db.Datetime, nullable=True, default=datetime.now)
    LicenseClassificationCode = db.Column(db.String(80), unique=False, nullable=True) 
    LicenseClassificationDescription = db.Column(db.String(80), unique=False, nullable=True) 
    ExpirationDate = db.Column(db.Datetime, nullable=True, default=datetime.now)
    FirmId = db.Column(db.Integer, db.ForeignKey('FirmId')) # unique
    CorporateName = db.Column(db.String(80), unique=False, nullable=True)
    BusinessName = db.Column(db.String(80), unique=False, nullable=True)
    DoingBusinessAs = db.Column(db.String(80), unique=False, nullable=True)
    StateIncorporation = db.Column(db.String(80), unique=False, nullable=True)
    AddressLine1 = db.Column(db.String(80), unique=True, nullable=True) # unique
    AddressLine2 = db.Column(db.String(80), unique=False, nullable=True) 
    City = db.Column(db.String(80), unique=False, nullable=True) 
    State = db.Column(db.String(80), unique=False, nullable=True) 
    Zip = db.Column(db.String(80), unique=False, nullable=True) 
    CountyId = db.Column(db.Integer)
    CountyCode = db.Column(db.String(80), unique=False, nullable=True) 
    LicenseAddressTypeId = db.Column(db.Integer)
    LicenseAddressTypeCode = db.Column(db.String(80), unique=False, nullable=True) 
    LicenseAddressTypeDescription = db.Column(db.String(80), unique=False, nullable=True) 
    ExempteeLastName = db.Column(db.String(80), unique=False, nullable=True) 
    ExempteeFirstName = db.Column(db.String(80), unique=False, nullable=True) 
 

    def to_json(self):
        return {
            "id": self.id,
            "firstName": self.first_name,
            "lastName": self.last_name,
            "email": self.email,
        }