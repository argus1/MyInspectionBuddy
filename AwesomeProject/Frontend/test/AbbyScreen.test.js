import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import AbbyScreen from './AbbyScreen'; // Adjust the path based on your folder structure
import DateTimePicker from '@react-native-community/datetimepicker';

// Mock the DateTimePicker component
jest.mock('@react-native-community/datetimepicker', () => 'DateTimePicker');

test('renders the screen correctly', () => {
  const { getByText, getByPlaceholderText } = render(<AbbyScreen />);

  // Check for title
  expect(getByText("Abby's Page Recall Search")).toBeTruthy();

  // Check for text inputs
  expect(getByPlaceholderText('Search Bar')).toBeTruthy();

  // Check for date picker buttons
  expect(getByText('Select Date')).toBeTruthy();

  // Check for Search button
  expect(getByText('Search')).toBeTruthy();
});

test('shows date picker when "Select Date" button is pressed', () => {
  const { getByText, getByTestId } = render(<AbbyScreen />);

  // Press "Select Date" for fromDate
  fireEvent.press(getByText('Select Date'));

  // Check if the date picker is shown
  expect(getByTestId('dateTimePickerFrom')).toBeTruthy();

  // Press "Select Date" for toDate
  fireEvent.press(getByText('Select Date'));

  // Check if the date picker is shown
  expect(getByTestId('dateTimePickerTo')).toBeTruthy();
});

test('updates fromDate when a new date is selected', async () => {
  const { getByText, getByTestId } = render(<AbbyScreen />);

  // Open date picker
  fireEvent.press(getByText('Select Date'));

  // Simulate a date change
  fireEvent.change(getByTestId('dateTimePickerFrom'), {
    target: { value: new Date(2024, 0, 1) } // January 1, 2024
  });

  // Validate that the fromDate is updated
  // Note: This might require inspecting internal state or handling async updates
  await waitFor(() => {
    // You might need to adjust this part based on how you handle state and updates
  });
});

test('updates toDate when a new date is selected', async () => {
  const { getByText, getByTestId } = render(<AbbyScreen />);

  // Open date picker
  fireEvent.press(getByText('Select Date'));

  // Simulate a date change
  fireEvent.change(getByTestId('dateTimePickerTo'), {
    target: { value: new Date(2024, 11, 31) } // December 31, 2024
  });

  // Validate that the toDate is updated
  // Note: This might require inspecting internal state or handling async updates
  await waitFor(() => {
    // You might need to adjust this part based on how you handle state and updates
  });
});
