import { render, fireEvent, waitFor, screen } from '@testing-library/react-native';
import { Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';

import CAEntitySearchScreen from '../src/screens/CAEntitySearchScreen';

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

jest.mock("@react-navigation/native", () => {
  const actualNav = jest.requireActual("@react-navigation/native");
  return {
    ...actualNav,
    useNavigation: () => ({
      navigate: jest.fn(),
      dispatch: jest.fn(),
    }),
  };
});


jest.mock("expo-font", () => {
  const expoFont = jest.requireActual("expo-font");
  return {
    ...expoFont,
    isLoaded: jest.fn(() => true),
  };
});


describe('<CAEntityResultsScreen />', () => {
  test("CA Entity Search Screen Loaded Correctly", () => {
    const { getByText } = render(<CAEntitySearchScreen />);

    getByText("CA Business Entity Search");
  });

  test("input search term in text input", () => {
    const { getByPlaceholderText } = render(<CAEntitySearchScreen />);
    const searchInput = getByPlaceholderText('Enter business name or number');
  
    fireEvent.changeText(searchInput, 'Test Search Term');
  
    expect(searchInput.props.value).toBe('Test Search Term');
  });

  test("API network error upon search", async () => {
    global.fetch = jest.fn(() =>
      Promise.reject(new Error('Network error'))
    );
    const alertSpy = jest.spyOn(Alert, 'alert');

    const { getByText, getByTestId } = render(<CAEntitySearchScreen />);
    const searchInput = getByTestId('searchInput');
  
    fireEvent.changeText(searchInput, 'heart');
    fireEvent.press(getByText('Search'));

    await waitFor(() => {
      expect(alertSpy).toHaveBeenCalledWith(
        'Error',
        'Failed to fetch data from the server'
      );
    });
  });

  test("navigate to result screen after API response", async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({ results: 'mock results' }),
      })
    );

    const navigateSpy = jest.spyOn(useNavigation(), 'navigate');

    const { getByText, getByTestId } = render(<CAEntitySearchScreen />);
    const searchInput = getByTestId('searchInput');
  
    fireEvent.changeText(searchInput, 'heart');
    fireEvent.press(getByText('Search'));

    await waitFor(() => {
      expect(navigateSpy).toHaveBeenCalledTimes(1);
    });

  });

});