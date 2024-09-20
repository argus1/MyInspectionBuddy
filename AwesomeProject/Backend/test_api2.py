import pytest
import requests
from app import app  # Import the Flask app instance


@pytest.fixture
def client():
    """Pytest fixture to create a test client."""
    app.config["TESTING"] = True  # Set the app to testing mode
    with app.test_client() as client:
        yield client


def test_search_maude_success(client, monkeypatch):
    """
    Test the /maude endpoint for a successful MAUDE search.
    """

    # Mock MAUDE API response
    maude_mock_response = {
        "meta": {"results": {"total": 1}},
        "results": [
            {
                "event_key": "123456",
                "device": {"generic_name": "Test Device"},
                "firm_name": "Test Firm",
            }
        ],
    }

    def mock_get(url, *args, **kwargs):
        """Mock requests.get method for MAUDE API"""

        class MockResponse:
            def raise_for_status(self):
                pass

            def json(self):
                return maude_mock_response

        return MockResponse()

    # Mock the MAUDE API call
    monkeypatch.setattr(requests, "get", mock_get)

    # Send a POST request to /maude endpoint
    response = client.post("/maude", json={"deviceName": "Test Device"})

    # Assert successful response and data
    assert response.status_code == 200
    response_data = response.get_json()
    assert response_data["results"][0]["device"]["generic_name"] == "Test Device"


def test_search_maude_missing_parameters(client):
    """
    Test the /maude endpoint for missing parameters.
    """

    response = client.post("/maude", json={})

    # Assert a 400 Bad Request status when no search parameters are provided
    assert response.status_code == 400
    assert response.get_json()["error"] == "At least one search parameter is required"


def test_search_openhistorical_success(client, monkeypatch):
    """
    Test the /openhistorical endpoint for a successful historical document search.
    """

    # Mock OpenHistorical API response
    openhistorical_mock_response = {
        "meta": {"results": {"total": 1}},
        "results": [
            {
                "num_of_pages": 10,
                "year": 2023,
                "text": "Sample document text",
                "doc_type": "FDA report",
            }
        ],
    }

    def mock_get(url, *args, **kwargs):
        """Mock requests.get method for OpenHistorical API"""

        class MockResponse:
            def raise_for_status(self):
                pass

            def json(self):
                return openhistorical_mock_response

        return MockResponse()

    # Mock the OpenHistorical API call
    monkeypatch.setattr(requests, "get", mock_get)

    # Send a POST request to /openhistorical endpoint
    response = client.post("/openhistorical", json={"keyword": "Sample"})

    # Assert successful response and data
    assert response.status_code == 200
    response_data = response.get_json()
    assert response_data[0]["doc_type"] == "FDA report"
    assert response_data[0]["text"] == "Sample document text"


def test_search_openhistorical_missing_keyword(client):
    """
    Test the /openhistorical endpoint for missing keyword.
    """

    response = client.post("/openhistorical", json={})

    # Assert a 400 Bad Request status when keyword is missing
    assert response.status_code == 400
    assert response.get_json()["error"] == "Keyword is required"


def test_search_ca_business_entity_success(client, monkeypatch):
    """
    Test the /ca-business-entity endpoint for successful business entity search.
    """

    # Mock CA business entity search results
    ca_business_mock_results = [
        {
            "entityInformation": "Test Business Entity",
            "initialFilingDate": "2023-01-01",
            "status": "Active",
            "entityType": "Corporation",
            "formedIn": "California",
            "agent": "Test Agent",
        }
    ]

    def mock_get(url, *args, **kwargs):
        """Mock requests.get method for CA business entity search"""

        class MockResponse:
            def raise_for_status(self):
                pass

            def json(self):
                return ca_business_mock_results

        return MockResponse()

    # Mock the CA business entity search call
    monkeypatch.setattr(requests, "get", mock_get)

    # Send a POST request to /ca-business-entity endpoint
    response = client.post("/ca-business-entity", json={"searchTerm": "Test Business"})

    # Assert successful response and data
    assert response.status_code == 200
    response_data = response.get_json()
    assert response_data[0]["entityInformation"] == "Test Business Entity"


def test_search_ca_business_entity_missing_search_term(client):
    """
    Test the /ca-business-entity endpoint for missing search term.
    """

    response = client.post("/ca-business-entity", json={})

    # Assert a 400 Bad Request status when no search term is provided
    assert response.status_code == 400
    assert response.get_json()["error"] == "Search term is required"
