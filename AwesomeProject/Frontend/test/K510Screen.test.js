import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import K510Screen from './K510Screen'; // Adjust the import path
import DateTimePicker from '@react-native-community/datetimepicker';
import { useNavigation } from '@react-navigation/native';

// Mock useNavigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: jest.fn(),
}));

// Mock fetch globally
global.fetch = jest.fn();

// Mock DateTimePicker
jest.mock('@react-native-community/datetimepicker', () => {
  return {
    __esModule: true,
    default: jest.fn(() => null), // Mock DateTimePicker as a no-op
  };
});

const mockNavigate = jest.fn();
useNavigation.mockReturnValue({ navigate: mockNavigate });

describe('K510Screen', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    fetch.mockClear();
    mockNavigate.mockClear();
    DateTimePicker.mockClear();
  });

  test('renders correctly with initial UI elements', () => {
    const { getByText, getByPlaceholderText } = render(<K510Screen />);

    // Check for title
    expect(getByText('510K Recall Search')).toBeTruthy();

    // Check for text inputs
    expect(getByPlaceholderText('Enter 510K Number')).toBeTruthy();
    expect(getByPlaceholderText('Enter Applicant Name')).toBeTruthy();
    expect(getByPlaceholderText('Enter Device Name')).toBeTruthy();

    // Check for search button
    expect(getByText('Search')).toBeTruthy();
  });

  test('updates text inputs correctly', () => {
    const { getByPlaceholderText } = render(<K510Screen />);

    const k510Input = getByPlaceholderText('Enter 510K Number');
    const applicantInput = getByPlaceholderText('Enter Applicant Name');
    const deviceInput = getByPlaceholderText('Enter Device Name');

    // Simulate user input
    fireEvent.changeText(k510Input, 'K123456');
    fireEvent.changeText(applicantInput, 'Test Applicant');
    fireEvent.changeText(deviceInput, 'Test Device');

    // Check input values
    expect(k510Input.props.value).toBe('K123456');
    expect(applicantInput.props.value).toBe('Test Applicant');
    expect(deviceInput.props.value).toBe('Test Device');
  });

  test('displays and handles date pickers correctly', () => {
    const { getByText } = render(<K510Screen />);

    // Trigger from date picker
    fireEvent.press(getByText('Select Date', { exact: false }));

    // Verify DateTimePicker is shown (mocked as a no-op)
    expect(DateTimePicker).toHaveBeenCalled();
  });

  test('shows loading state while fetching data', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: [] }),
    });

    const { getByText, getByPlaceholderText } = render(<K510Screen />);

    // Set input values
    fireEvent.changeText(getByPlaceholderText('Enter 510K Number'), 'K123456');
    fireEvent.changeText(getByPlaceholderText('Enter Applicant Name'), 'Test Applicant');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Expect loading text to be shown
    await waitFor(() => expect(getByText('Loading...')).toBeTruthy());
  });

  test('navigates to K510ResultsScreen on successful fetch', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: ['mock result'] }),
    });

    const { getByText, getByPlaceholderText } = render(<K510Screen />);

    // Set input values
    fireEvent.changeText(getByPlaceholderText('Enter 510K Number'), 'K123456');
    fireEvent.changeText(getByPlaceholderText('Enter Applicant Name'), 'Test Applicant');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the fetch to complete and expect navigation to be called
    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('K510ResultsScreen', { results: ['mock result'] });
    });
  });

  test('displays error message when fetch fails', async () => {
    // Mock fetch to simulate a failure
    fetch.mockRejectedValueOnce(new Error('Failed to fetch'));

    const { getByText, getByPlaceholderText } = render(<K510Screen />);

    // Set input values
    fireEvent.changeText(getByPlaceholderText('Enter 510K Number'), 'K123456');
    fireEvent.changeText(getByPlaceholderText('Enter Applicant Name'), 'Test Applicant');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the error message to be shown
    await waitFor(() => {
      expect(getByText('Error: Failed to fetch')).toBeTruthy();
    });
  });
});
