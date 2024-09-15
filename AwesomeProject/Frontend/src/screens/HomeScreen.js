import React from 'react';
import { StyleSheet, Text, View, TouchableOpacity, Image, Dimensions } from 'react-native';
import analytics from '@react-native-firebase/analytics';
import AsyncStorage from '@react-native-async-storage/async-storage';


const logNavigation = async (screen) => {
  try {
    const savedValue = await AsyncStorage.getItem('dataCollectionEnabled');
    if (savedValue == "true")
      await analytics().logEvent('userNavigation' + screen);
  } catch(e) {
    console.error(e);
  }
}

const logQuery = async (screen) => {
  try {
    const savedValue = await AsyncStorage.getItem('dataCollectionEnabled');
    if (savedValue == "true")
      await analytics().logEvent('userQuery' + screen);
  } catch(e) {
    console.error(e);
  }
}

const { width, height } = Dimensions.get('window');

const HomeScreen = ({ navigation }) => {
  return (
    <View style={styles.container}>
      <View style={styles.appNameContainer}>
        <Text style={styles.appName}>MY INSPECTION BUDDY</Text>
      </View>
      <TouchableOpacity style={styles.topButton}>
        <Image source={require('../../assets/search-icon.png')} style={styles.icon} />
        <Text style={styles.buttonText}>Recall Search</Text>
      </TouchableOpacity>
      <View style={styles.middleContainer}>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={[styles.button, styles.button1]} onPress={() => {logNavigation("FDA"); navigation.navigate('FDA')}}>
            <Text style={styles.buttonText}>FDA Enforcement</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, styles.button2]} onPress={() => {logNavigation("K510"); navigation.navigate('K510')}}>
            <Text style={styles.buttonText}>510k</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={[styles.button, styles.button3]} onPress={() => {logNavigation("Maude"); navigation.navigate('Maude')}}>
            <Text style={styles.buttonText}>MAUDE</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, styles.button4]} onPress={() => {logNavigation("CDPH"); navigation.navigate('CDPH')}}>
            <Text style={styles.buttonText}>CDPH Medical Device Page</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={[styles.button, styles.button5]} onPress={() => {logNavigation("OpenHistoricalScreen"); navigation.navigate('OpenHistoricalScreen')}}>
            <Text style={styles.buttonText}>Historical Documents</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, styles.button6]} onPress={() => {logNavigation("WarningLetter"); navigation.navigate('WarningLetter')}}>
            <Text style={styles.buttonText}>FDA Warning Letter Database</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.buttonRow}>
          <TouchableOpacity style={[styles.button, styles.button7]} onPress={() => {logNavigation("CAEntitySearchScreen"); navigation.navigate('CAEntitySearchScreen')}}>
            <Text style={styles.buttonText}>CA Business Entity Search</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, styles.button8]} onPress={() => {logNavigation("PrivacyScreen");navigation.navigate('PrivacyScreen')}}>
            <Text style={styles.buttonText}>Privacy Policy</Text>
          </TouchableOpacity>
        </View>
      </View>
      <TouchableOpacity style={styles.bottomButton}>
        <Image source={require('../../assets/camera-icon.png')} style={styles.icon} />
        <Text style={styles.buttonText}>Device Detection</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: 20,
    paddingBottom: 50,
    backgroundColor: '#FFFFFF',
  },
  appNameContainer: {
    paddingVertical: 20,
  },
  appName: {
    fontSize: 40,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#FF0000', // Red color for the app name
  },
  topButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    width: width * 0.9,
    padding: 15,
    backgroundColor: '#E1F5EA',
    borderRadius: 10,
    borderColor: '#4CAF50',
    borderWidth: 1,
    marginBottom: 20,
  },
  bottomButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    width: width * 0.9,
    padding: 15,
    backgroundColor: '#E1F5EA',
    borderRadius: 10,
    borderColor: '#4CAF50',
    borderWidth: 1,
  },
  middleContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 10,
  },
  button: {
    width: width * 0.25,
    height: width * 0.2, // Make buttons more square-shaped
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 20, // Rounded edges
    marginHorizontal: 10,
    padding: 10, // Adjust padding for content inside the button
  },
  button1: {
    backgroundColor: '#FFCDD2',
  },
  button2: {
    backgroundColor: '#C8E6C9',
  },
  button3: {
    backgroundColor: '#BBDEFB',
  },
  button4: {
    backgroundColor: '#D1C4E9',
  },
  button5: {
    backgroundColor: '#FFE0B2',
  },
  button6: {
    backgroundColor: '#B2DFDB',
  },
  button7: {
    backgroundColor: '#FFEB3B',
  },
  button8: {
    backgroundColor: '#C2C3C4',
  },
  buttonText: {
    fontSize: 25,
    color: '#000000',
    fontWeight: 'bold',
    textAlign: 'center',
  },
  icon: {
    width: width * 0.1,
    height: width * 0.1,
    marginRight: 10,
  },
});

export default HomeScreen;
