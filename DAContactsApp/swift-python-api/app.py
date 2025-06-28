from flask import Flask, jsonify
import sqlite3

app = Flask(__name__)

@app.route('/contacts', methods=['GET'])
def get_contacts():
    con = sqlite3.connect('contact_info.db')
    cur = con.cursor()
    cur.execute("SELECT * FROM contact")
    rows = cur.fetchall()
    con.close()
    
    contacts = []
    for row in rows:
        contacts.append({
            'County': row[0],
            'Name': row[1],
            'Address': row[2],
            'Phone': row[3],
            'Fax': row[4],
            'Website': row[5],
        })
    
    return jsonify(contacts)

if __name__ == '__main__':
    app.run(debug=True)
