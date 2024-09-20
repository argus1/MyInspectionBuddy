import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import CAEntitySearchScreen from './CAEntitySearchScreen'; // Adjust the path based on your folder structure
import { useNavigation } from '@react-navigation/native';

// Mock the useNavigation hook
jest.mock('@react-navigation/native', () => ({
  useNavigation: jest.fn(),
}));

// Mock Alert
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

test('renders the screen correctly', () => {
  const { getByText, getByPlaceholderText } = render(<CAEntitySearchScreen />);

  // Check for title
  expect(getByText('CA Business Entity Search')).toBeTruthy();

  // Check for text input
  expect(getByPlaceholderText('Enter Search Term')).toBeTruthy();

  // Check for search button
  expect(getByText('Search')).toBeTruthy();
});

test('updates search term on text input change', () => {
  const { getByPlaceholderText } = render(<CAEntitySearchScreen />);
  const searchInput = getByPlaceholderText('Enter Search Term');

  // Simulate text input change
  fireEvent.changeText(searchInput, 'Test Search Term');

  expect(searchInput.props.value).toBe('Test Search Term');
});

test('shows error alert on fetch failure', async () => {
  // Mock fetch to simulate a server error
  global.fetch = jest.fn(() =>
    Promise.reject(new Error('Network error'))
  );

  const { getByText } = render(<CAEntitySearchScreen />);
  fireEvent.press(getByText('Search'));

  await waitFor(() => {
    expect(global.Alert.alert).toHaveBeenCalledWith(
      'Error',
      'Failed to fetch data from the server'
    );
  });
});

test('navigates to CAEntityResultsScreen on successful fetch', async () => {
  // Mock fetch to simulate a successful server response
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({ results: 'mock results' }),
    })
  );

  const { getByText } = render(<CAEntitySearchScreen />);
  fireEvent.press(getByText('Search'));

  await waitFor(() => {
    expect(mockNavigate).toHaveBeenCalledWith('CAEntityResultsScreen', {
      results: { results: 'mock results' },
    });
  });
});
