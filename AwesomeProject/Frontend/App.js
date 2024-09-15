import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from './src/screens/HomeScreen';
import FDAScreen from './src/screens/FDAScreen';
import K510Screen from './src/screens/K510Screen';
import CDPHScreen from './src/screens/CDPHScreen';
import MaudeScreen from './src/screens/MaudeScreen';
import RecallScreen from './src/screens/RecallScreen';
import K510ResultsScreen from './src/screens/K510ResultsScreen';
import CDPHResultsScreen from './src/screens/CDPHResultsScreen';
import MaudeResultsScreen from './src/screens/MaudeResultsScreen';
import PDFViewer from './src/screens/PDFViewer';
import OpenHistoricalScreen from './src/screens/OpenHistoricalScreen';
import OpenHistoricalResultsScreen from './src/screens/OpenHistoricalResultsScreen';
import CAEntitySearchScreen from './src/screens/CAEntitySearchScreen';
import CAEntityResultsScreen from './src/screens/CAEntityResultsScreen';
import PrivacyScreen from './src/screens/PrivacyScreen';


const Stack = createNativeStackNavigator();


export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="FDA" component={FDAScreen} />
        <Stack.Screen name="K510" component={K510Screen} />
        <Stack.Screen name="CDPH" component={CDPHScreen} />
        <Stack.Screen name="Maude" component={MaudeScreen} />
        <Stack.Screen name="Recall" component={RecallScreen} />
        <Stack.Screen name="K510ResultsScreen" component={K510ResultsScreen} />
        <Stack.Screen name="CDPHResultsScreen" component={CDPHResultsScreen} />
        <Stack.Screen name="MaudeResultsScreen" component={MaudeResultsScreen} />
        <Stack.Screen name="PDFViewer" component={PDFViewer} />
        <Stack.Screen name="OpenHistoricalScreen" component={OpenHistoricalScreen} />
        <Stack.Screen name="OpenHistoricalResultsScreen" component={OpenHistoricalResultsScreen} />
        <Stack.Screen name="CAEntitySearchScreen" component={CAEntitySearchScreen} />
        <Stack.Screen name="CAEntityResultsScreen" component={CAEntityResultsScreen} />
        <Stack.Screen name="PrivacyScreen" component={PrivacyScreen} />

      </Stack.Navigator>
    </NavigationContainer>
  );
}
