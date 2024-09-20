import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import CDPHScreen from './CDPHScreen'; // Adjust the path based on your folder structure
import { useNavigation } from '@react-navigation/native';

// Mock useNavigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: jest.fn(),
}));

// Mock fetch globally
global.fetch = jest.fn();

// Mock Alert (if used in your app)
jest.mock('react-native', () => {
  const actualReactNative = jest.requireActual('react-native');
  return {
    ...actualReactNative,
    Alert: {
      alert: jest.fn(),
    },
  };
});

const mockNavigate = jest.fn();
useNavigation.mockReturnValue({ navigate: mockNavigate });

describe('CDPHScreen', () => {
  beforeEach(() => {
    // Clear mocks before each test
    fetch.mockClear();
    mockNavigate.mockClear();
  });

  test('renders correctly with initial UI elements', () => {
    const { getByText, getByPlaceholderText } = render(<CDPHScreen />);

    // Check for title
    expect(getByText('CDPH Device Recalls Search')).toBeTruthy();

    // Check for text inputs
    expect(getByPlaceholderText('Search Bar')).toBeTruthy();

    // Check for Search button
    expect(getByText('Search')).toBeTruthy();
  });

  test('updates text inputs correctly', () => {
    const { getAllByPlaceholderText } = render(<CDPHScreen />);
    const [deviceInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Simulate text input change for Device Name
    fireEvent.changeText(deviceInput, 'Test Device');
    expect(deviceInput.props.value).toBe('Test Device');

    // Simulate text input change for Firm Name
    fireEvent.changeText(firmInput, 'Test Firm');
    expect(firmInput.props.value).toBe('Test Firm');
  });

  test('shows loading state while fetching data', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: 'mock results' }),
    });

    const { getByText, getAllByPlaceholderText } = render(<CDPHScreen />);
    const [deviceInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(deviceInput, 'Device Name');
    fireEvent.changeText(firmInput, 'Firm Name');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Expect loading text to be shown
    await waitFor(() => expect(getByText('Loading...')).toBeTruthy());
  });

  test('navigates to CDPHResultsScreen on successful fetch', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: 'mock results' }),
    });

    const { getByText, getAllByPlaceholderText } = render(<CDPHScreen />);
    const [deviceInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(deviceInput, 'Test Device');
    fireEvent.changeText(firmInput, 'Test Firm');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the fetch call to complete and expect navigation to be called
    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('CDPHResultsScreen', { results: { results: 'mock results' } });
    });
  });

  test('displays error message when fetch fails', async () => {
    // Mock fetch to simulate a failure
    fetch.mockRejectedValueOnce(new Error('Failed to fetch'));

    const { getByText, getAllByPlaceholderText } = render(<CDPHScreen />);
    const [deviceInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(deviceInput, 'Test Device');
    fireEvent.changeText(firmInput, 'Test Firm');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the error message to be shown
    await waitFor(() => {
      expect(getByText('Error: Failed to fetch')).toBeTruthy();
    });
  });
});
