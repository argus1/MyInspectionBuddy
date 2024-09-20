import pytest
import requests
from flask import Flask, jsonify
from app import app  # Import the Flask app instance from your app


@pytest.fixture
def client():
    """
    Pytest fixture to create a test client.
    This will be run before each test.
    """
    app.config["TESTING"] = True  # Set the app to testing mode
    with app.test_client() as client:
        yield client  # Provide the test client to the test functions


def test_search_fda_success(client, monkeypatch):
    """
    Test the / endpoint of the Flask app for successful FDA search request.
    """

    # Mock FDA API response
    fda_mock_response = {
        "meta": {"results": {"total": 1}},
        "results": [
            {
                "recall_number": "Z-1234-2024",
                "product_description": "Test Device",
                "recalling_firm": "Test Firm",
                "classification": "Class II",
            }
        ],
    }

    def mock_get(url, *args, **kwargs):
        """Mock requests.get method for FDA API"""

        class MockResponse:
            def raise_for_status(self):
                pass

            def json(self):
                return fda_mock_response

        return MockResponse()

    # Use monkeypatch to replace requests.get with mock_get
    monkeypatch.setattr(requests, "get", mock_get)

    # Make POST request to the / endpoint
    response = client.post("/", json={"productDescription": "Test Device"})

    # Assert that the status code is 200 OK
    assert response.status_code == 200

    # Assert that the returned JSON contains the expected FDA mock data
    response_data = response.get_json()
    assert response_data["results"][0]["recall_number"] == "Z-1234-2024"


def test_search_fda_missing_description(client):
    """
    Test the / endpoint of the Flask app for missing productDescription.
    """

    response = client.post("/", json={})

    # Assert that the response has a 400 status code for bad request
    assert response.status_code == 400

    # Assert the error message returned in the response
    assert response.get_json()["error"] == "Product description is required"


def test_search_cdph_success(client, monkeypatch):
    """
    Test the /cdph endpoint for a successful CDPH search.
    """

    # Mock CDPH search results
    cdph_mock_results = [
        {"text": "Device Recall Example", "url": "https://example.com/recall1"},
        {"text": "Another Device Recall", "url": "https://example.com/recall2"},
    ]

    # Mock perform_cdph_search function
    def mock_perform_cdph_search(device_name, firm_name):
        return cdph_mock_results

    # Use monkeypatch to replace perform_cdph_search with a mock
    monkeypatch.setattr("app.perform_cdph_search", mock_perform_cdph_search)

    # Send a POST request to /cdph endpoint
    response = client.post("/cdph", json={"deviceName": "Example Device"})

    # Assert successful response and data
    assert response.status_code == 200
    assert response.get_json() == cdph_mock_results


def test_search_cdph_missing_parameters(client):
    """
    Test the /cdph endpoint for missing parameters.
    """

    response = client.post("/cdph", json={})

    # Assert a 400 Bad Request status when no search parameters are provided
    assert response.status_code == 400
    assert response.get_json()["error"] == "At least one search parameter is required"


def test_search_k510_success(client, monkeypatch):
    """
    Test the /k510 endpoint for a successful 510k search.
    """

    # Mock K510 API response
    k510_mock_response = {
        "meta": {"results": {"total": 1}},
        "results": [
            {
                "k_number": "K123456",
                "applicant": "Test Applicant",
                "device_name": "Test Device",
            }
        ],
    }

    def mock_get(url, *args, **kwargs):
        """Mock requests.get method for K510 API"""

        class MockResponse:
            def raise_for_status(self):
                pass

            def json(self):
                return k510_mock_response

        return MockResponse()

    # Mock the K510 API call
    monkeypatch.setattr(requests, "get", mock_get)

    # Send a POST request to /k510 endpoint
    response = client.post("/k510", json={"k510Number": "K123456"})

    # Assert that the response is successful
    assert response.status_code == 200

    # Assert the response data is the same as the mock data
    response_data = response.get_json()
    assert response_data["results"][0]["k_number"] == "K123456"
