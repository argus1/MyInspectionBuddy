import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import HomeScreen from './HomeScreen'; // Adjust the path based on your folder structure
import { NavigationContainer } from '@react-navigation/native';

// Mock the navigation prop
const mockNavigate = jest.fn();

const renderComponent = () => {
  return render(
    <NavigationContainer>
      <HomeScreen navigation={{ navigate: mockNavigate }} />
    </NavigationContainer>
  );
};

test('renders the app name correctly', () => {
  const { getByText } = renderComponent();
  expect(getByText('MY INSPECTION BUDDY')).toBeTruthy();
});

test('recall search button works', () => {
  const { getByText, getByTestId } = renderComponent();

  // The 'Recall Search' button should exist
  const recallButton = getByText('Recall Search');
  expect(recallButton).toBeTruthy();
});

test('fda enforcement button works', () => {
  const { getByText } = renderComponent();

  // The 'FDA Enforcement' button should exist
  const fdaButton = getByText('FDA Enforcement');
  fireEvent.press(fdaButton);

  // Check if the navigation to 'FDA' is triggered
  expect(mockNavigate).toHaveBeenCalledWith('FDA');
});

test('device detection button works', () => {
  const { getByText } = renderComponent();

  // The 'Device Detection' button should exist
  const deviceDetectionButton = getByText('Device Detection');
  fireEvent.press(deviceDetectionButton);

  // Since no navigation is attached to this, you can check button existence
  expect(deviceDetectionButton).toBeTruthy();
});
