import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import FDAScreen from './FDAScreen'; // Adjust the path based on your folder structure
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

describe('FDAScreen', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    fetch.mockClear();
    mockNavigate.mockClear();
    DateTimePicker.mockClear();
  });

  test('renders correctly with initial UI elements', () => {
    const { getByText, getAllByPlaceholderText } = render(<FDAScreen />);

    // Check for title
    expect(getByText('FDA Enforcement Recall Search')).toBeTruthy();

    // Check for text inputs
    const placeholders = ['Search Bar'];
    const inputs = getAllByPlaceholderText(placeholders);
    expect(inputs.length).toBe(4); // 4 text inputs for productDescription, recallingFirm, recallNumber, recallClass

    // Check for search button
    expect(getByText('Search')).toBeTruthy();
  });

  test('updates text inputs correctly', () => {
    const { getAllByPlaceholderText } = render(<FDAScreen />);
    const [productInput, firmInput, recallNumberInput, recallClassInput] = getAllByPlaceholderText('Search Bar');

    // Update text inputs
    fireEvent.changeText(productInput, 'Test Product');
    fireEvent.changeText(firmInput, 'Test Firm');
    fireEvent.changeText(recallNumberInput, '12345');
    fireEvent.changeText(recallClassInput, 'Class I');

    // Check input values
    expect(productInput.props.value).toBe('Test Product');
    expect(firmInput.props.value).toBe('Test Firm');
    expect(recallNumberInput.props.value).toBe('12345');
    expect(recallClassInput.props.value).toBe('Class I');
  });

  test('displays and handles date pickers correctly', () => {
    const { getByText } = render(<FDAScreen />);

    // Trigger from date picker
    fireEvent.press(getByText('Select Date', { exact: false }));

    // Verify DateTimePicker is shown (although we mocked it as a no-op)
    expect(DateTimePicker).toHaveBeenCalled();
  });

  test('shows loading state while fetching data', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: 'mock results' }),
    });

    const { getByText, getAllByPlaceholderText } = render(<FDAScreen />);
    const [productInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(productInput, 'Test Product');
    fireEvent.changeText(firmInput, 'Test Firm');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Expect loading text to be shown
    await waitFor(() => expect(getByText('Loading...')).toBeTruthy());
  });

  test('navigates to Recall screen on successful fetch', async () => {
    // Mock fetch to simulate a successful response
    fetch.mockResolvedValueOnce({
      ok: true,
      json: jest.fn().mockResolvedValue({ results: ['mock result'] }),
    });

    const { getByText, getAllByPlaceholderText } = render(<FDAScreen />);
    const [productInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(productInput, 'Test Product');
    fireEvent.changeText(firmInput, 'Test Firm');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the fetch to complete and expect navigation to be called
    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('Recall', { results: ['mock result'] });
    });
  });

  test('displays error message when fetch fails', async () => {
    // Mock fetch to simulate a failure
    fetch.mockRejectedValueOnce(new Error('Failed to fetch'));

    const { getByText, getAllByPlaceholderText } = render(<FDAScreen />);
    const [productInput, firmInput] = getAllByPlaceholderText('Search Bar');

    // Set input values
    fireEvent.changeText(productInput, 'Test Product');
    fireEvent.changeText(firmInput, 'Test Firm');

    // Trigger search
    fireEvent.press(getByText('Search'));

    // Wait for the error message to be shown
    await waitFor(() => {
      expect(getByText('Error: Failed to fetch')).toBeTruthy();
    });
  });
});
