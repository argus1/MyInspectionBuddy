# This Python script uses SQLite to create a Data Base File
# The database table is populated with contact info collected from an Excel file

import sqlite3
import pandas as pd

# Read .xlsx file containing column names
info = pd.read_excel('CA District Attorney.xlsx', header=0)

# Remove leading and trailing whitespace using strip()
# Apply strip() to each element of `info` for strings only
info = info.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# Create new database and open database connection
con = sqlite3.connect("contact_info.db")

# Execute SQL statements and fetch results with database cursor object
cur = con.cursor()

# Drop table if already exists to avoid errors
cur.execute("DROP TABLE IF EXISTS contact")

# Create contact table in database 
cur.execute("CREATE TABLE contact(County TEXT, Name TEXT, Address TEXT, Phone TEXT, Fax TEXT, Link_to_Website TEXT)")


# List of data to store in the contact table of the database
contact_list = [tuple(row) for row in info.values]


# Insert multiple rows into contact_list
cur.executemany("INSERT INTO contact VALUES(?, ?, ?, ?, ?, ?)", contact_list)

# Commit transaction to save inserted data and changes
con.commit()

# Print
for i in cur.execute("SELECT  * FROM contact"):
    print(i)

# Close existing connection
con.close()