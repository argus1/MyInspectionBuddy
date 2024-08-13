from dotenv import load_dotenv
import mysql.connector
import os
import pandas as pd
from datetime import datetime

# Directory containing the CSV files
csv_directory = "csv"

# Initialize an empty DataFrame to store the combined data
combined_df = pd.DataFrame()

# Iterate over each file in the directory
for filename in os.listdir(csv_directory):
    if filename.endswith(".csv"):
        file_path = os.path.join(csv_directory, filename)
        # Read the data from the current file
        df = pd.read_csv(file_path)
        # Concatenate the data to the combined DataFrame
        combined_df = pd.concat([combined_df, df], ignore_index=True)

# Strip whitespace from string columns and replace NaN with ""
df_contact = combined_df.drop_duplicates().fillna('').map(lambda x: x.strip() if isinstance(x, str) else x)
df_contact['ExpirationDate'] = pd.to_datetime(df_contact['ExpirationDate'], format='%m/%d/%Y %I:%M:%S %p')
# NaN stored as float in mysql

# Database connection parameters from environment variables
load_dotenv()
db_config = {
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD'],
    'host': os.environ['DB_HOST'],
    'raise_on_warnings': True
}

# Create new database connection
con = mysql.connector.connect(**db_config)
cur = con.cursor()

try:
    # Create a new database
    cur.execute("DROP DATABASE IF EXISTS test")
    cur.execute("CREATE DATABASE test")
    cur.execute("USE test")

    # Create 'contact' table in the database
    cur.execute("""
        CREATE TABLE contact(
            license_address_id INT PRIMARY KEY,
            license_id INT,
            license_number INT,
            license_code_description VARCHAR(80),
            application_form_type_id TEXT,
            license_type_id INT,
            license_type_code VARCHAR(80),
            license_status_id INT,
            license_status_code VARCHAR(80),
            license_classification_id VARCHAR(80),
            license_classification_code VARCHAR(80),
            license_classification_description VARCHAR(80),
            expiration_date DATETIME,
            firm_id INT,
            corporate_name VARCHAR(80),
            business_name TEXT,
            doing_business_as VARCHAR(80),
            state_incorporation VARCHAR(80),
            address_line_1 VARCHAR(80),
            address_line_2 VARCHAR(80),
            city VARCHAR(80),
            state VARCHAR(80),
            zip VARCHAR(80),
            county_id TEXT,
            county_code VARCHAR(80),
            license_address_type_id INT,
            license_address_type_code VARCHAR(80),
            license_address_type_description VARCHAR(80),
            exemptee_last_name VARCHAR(80),
            exemptee_first_name VARCHAR(80)
        )
    """)

    query = """
        INSERT INTO contact (license_address_id, license_id, license_number, license_code_description, application_form_type_id,
            license_type_id, license_type_code, license_status_id, license_status_code, license_classification_id,
            license_classification_code, license_classification_description, expiration_date, firm_id, corporate_name,
            business_name, doing_business_as, state_incorporation, address_line_1, address_line_2,
            city, state, zip, county_id, county_code,
            license_address_type_id, license_address_type_code, license_address_type_description, exemptee_last_name, exemptee_first_name)
        VALUES (
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s
        )
    """
    contact_list = [tuple(row) for row in df_contact.values]

    cur.executemany(query, contact_list)
    con.commit()
    print("Data inserted")
except mysql.connector.Error as err:
    print(f"Error:{err}")
finally:
    cur.close()
    con.close()
