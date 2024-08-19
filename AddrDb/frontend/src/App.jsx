import { useState, useEffect } from "react";
import "./App.css";

function App() {
  // State to store contacts fetched from the server
  const [contacts, setContacts] = useState([]);

  // State to store the values selected in the dropdowns
  const [dropdownValues, setDropdownValues] = useState({
    one: "",
    two: "",
    three: "",
    four: "",
    five: "",
    six: "",
    seven: "",
    eight: "",
    nine: "",
    ten: "",
    eleven: "",
    countyCode: "",
    thirteen: "",
    fourteen: "",
    fifteen: "",
    sixteen: "",
  });
  // State to store the search results
  const [results, setResults] = useState([]);

  // Fetch contacts when the component mounts
  useEffect(() => {
    fetchContacts();
  }, []);

  // Function to fetch contacts from the server
  const fetchContacts = async () => {
    const response = await fetch("http://127.0.0.1:5000/contacts");
    const data = await response.json();
    setContacts(data.contacts);
  };

  // Handle changes in the dropdowns and input fields
  const handleDropdownChange = (e) => {
    const { name, value } = e.target;
    setDropdownValues((prevValues) => ({
      ...prevValues,
      [name]: value,
    }));
  };
  // Function to display search results based on dropdown values
  const displayAddressSearch = async () => {
    const query = new URLSearchParams(dropdownValues).toString();
    const response = await fetch(`http://127.0.0.1:5000/search?${query}`);
    const data = await response.json();
    setResults(data.results);
  };

  // Function to get unique values for a given key from contacts and sort them
  const getUniqueValues = (key) => {
    return [...new Set(contacts.map((contact) => contact[key]))].sort();
  };
  return (
    <div>
      <h2>Search</h2>
      <table>
        <tbody>
          <tr>
            <th>Firm Name</th>
            <td>
              {/* Input field for the first value */}
              <input
                type="text"
                name="one"
                value={dropdownValues.one}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>License</th>
            <td>
              {/* Dropdown for the second value */}
              <select
                name="two"
                value={dropdownValues.two}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("licenseCodeDescription").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>License Type</th>
            <td>
              {/* Dropdown for the third value */}
              <select
                name="three"
                value={dropdownValues.three}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("licenseTypeId").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>Application Form Type</th>
            <td>
              {/* Dropdown for the fourth value */}
              <select
                name="four"
                value={dropdownValues.four}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("applicationFormTypeId").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>License Status</th>
            <td>
              {/* Dropdown for the fifth value */}
              <select
                name="five"
                value={dropdownValues.five}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("licenseStatusId").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>License Classification</th>
            <td>
              {/* Dropdown for the sixth value */}
              <select
                name="six"
                value={dropdownValues.six}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("licenseClassificationId").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>License Address Type</th>
            <td>
              {/* Dropdown for the seventh value */}
              <select
                name="seven"
                value={dropdownValues.seven}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("licenseAddressTypeId").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>Address Line</th>
            <td>
              {/* Input field for the eighth value */}
              <input
                type="text"
                name="eight"
                value={dropdownValues.eight}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>City</th>
            <td>
              {/* Input field for the ninth value */}
              <input
                type="text"
                name="nine"
                value={dropdownValues.nine}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>State</th>
            <td>
              {/* Input field for the tenth value */}
              <input
                type="text"
                name="ten"
                value={dropdownValues.ten}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>Zip</th>
            <td>
              {/* Input field for the eleventh value */}
              <input
                type="text"
                name="eleven"
                value={dropdownValues.eleven}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>County</th>
            <td>
              {/* Dropdown for the twelfth value */}
              <select
                name="countyCode"
                value={dropdownValues.countyCode}
                onChange={handleDropdownChange}
              >
                <option value="">Select</option>
                {getUniqueValues("countyCode").map((value) => (
                  <option key={value} value={value}>
                    {value}
                  </option>
                ))}
              </select>
            </td>
          </tr>
          <tr>
            <th>Exemptee Last Name</th>
            <td>
              {/* Input field for the thirteenth value */}
              <input
                type="text"
                name="thirteen"
                value={dropdownValues.thirteen}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>Exemptee First Name</th>
            <td>
              {/* Input field for the fourteenth value */}
              <input
                type="text"
                name="fourteen"
                value={dropdownValues.fourteen}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>Start Expiration Date</th>
            <td>
              {/* Input field for the fifteenth value */}
              <input
                type="text"
                name="fifteen"
                value={dropdownValues.fifteen}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
          <tr>
            <th>End Expiration Date</th>
            <td>
              {/* Input field for the sixteenth value */}
              <input
                type="text"
                name="sixteen"
                value={dropdownValues.sixteen}
                onChange={handleDropdownChange}
                placeholder="Type here"
              />
            </td>
          </tr>
        </tbody>
      </table>
      {/* Button to trigger the search */}
      <button onClick={displayAddressSearch}>Search</button>
      <div>
        {/* Display search results if any */}
        {results.length > 0 && (
          <div>
            <h3>Search Results:</h3>
            <ul>
              {results.map((result, index) => (
                <li key={index}>{result}</li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;