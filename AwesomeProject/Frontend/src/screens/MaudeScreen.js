import React, { useState } from 'react';
import { View, Text, TextInput, Dimensions, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useNavigation } from '@react-navigation/native';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');


const MaudeScreen = () => {
  const [deviceName, setDeviceName] = useState('');
  const [selectedYear, setSelectedYear] = useState('ALL YEARS');
  const navigation = useNavigation();

  

  const fetchData = () => {
    const fromDate = selectedYear !== 'ALL YEARS' ? `${selectedYear}-01-01` : '';
    const toDate = selectedYear !== 'ALL YEARS' ? `${selectedYear}-12-31` : '';
    
    const data = {
      deviceName,
      fromDate,
      toDate
    };
    logQuery("Maude");

    fetch('http://10.0.0.63:5001/maude', { 
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    })
    .then(response => response.json())
    .then(result => {
      if (result.error) {
        Alert.alert('Error', result.error);
      } else {
        // Navigate to MaudeResultsScreen with the fetched data
        navigation.navigate('MaudeResultsScreen', { results: result.results });
      }
    })
    .catch(error => {
      console.error('Error fetching data:', error);
      Alert.alert('Error', 'Failed to fetch data from the server');
    });
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>MAUDE Recall Search</Text>
      
      <View style={styles.searchSection}>
        <Text>Device Generic Name</Text>
        <TextInput
          style={styles.searchBar}
          placeholder="Enter Device Generic Name"
          value={deviceName}
          onChangeText={setDeviceName}
        />
        <Picker
          selectedValue={selectedYear}
          style={styles.yearPicker}
          onValueChange={(itemValue, itemIndex) => setSelectedYear(itemValue)}
        >
          <Picker.Item label="ALL YEARS" value="ALL YEARS" />
          <Picker.Item label="2024" value="2024" />
          <Picker.Item label="2023" value="2023" />
          <Picker.Item label="2022" value="2022" />
          <Picker.Item label="2021" value="2021" />
          <Picker.Item label="2020" value="2020" />
          <Picker.Item label="2019" value="2019" />
          <Picker.Item label="2018" value="2018" />
          <Picker.Item label="2017" value="2017" />
          <Picker.Item label="2016" value="2016" />
          <Picker.Item label="2015" value="2015" />
          <Picker.Item label="2014" value="2014" />
        </Picker>
      </View>

      <TouchableOpacity style={styles.searchButton} onPress={fetchData}>
        <Text>Search</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'space-around',
    alignItems: 'center',
    padding: 10,
  },
  title: {
    fontWeight: 'bold',
    fontSize: 30,
    marginBottom: 20,
  },
  searchSection: {
    width: '80%', // Adjust width as needed
  },
  searchBar: {
    borderWidth: 1,
    borderColor: 'black',
    paddingHorizontal: 10,
    padding: 10,
    marginBottom: 20,
  },
  searchButton: {
    backgroundColor: '#ddd',
    paddingHorizontal: 40,
    paddingVertical: 10,
    borderRadius: 5,
    marginBottom: 20,
    marginTop: 10,
  },
  pickerContainer: {
    width: '100%', // Adjust width as needed
    flex: 1,
    justifyContent: 'space-between',
    height: 50,
    marginTop: 50,
  },
  yearPicker: {
    width: '100%',
    height: 50,
  },
});

export default MaudeScreen;
