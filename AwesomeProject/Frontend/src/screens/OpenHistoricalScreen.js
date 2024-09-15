import React, { useState } from 'react';
import { View, Text, TextInput, Dimensions, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');


const OpenHistoricalSearchScreen = () => {
    const [keyword, setKeyword] = useState('');
    const [year, setYear] = useState('');
    const navigation = useNavigation();



    const fetchData = () => {
        const data = {
            keyword,
            year
        };

        logQuery("OpenHistorical");

        fetch('http://10.0.0.63:5001/openhistorical', { // Update with your server's IP address
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
                // Check the result and navigate if it contains data
                if (result.length > 0) {
                    navigation.navigate('OpenHistoricalResultsScreen', { results: result });
                } else {
                    Alert.alert('No Results', 'No results found for the provided search criteria.');
                }
            }
        })
        .catch(error => {
            console.error('Error fetching data:', error);
            Alert.alert('Error', 'Failed to fetch data from the server');
        });
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Open Historical Search</Text>
            
            <View style={styles.searchSection}>
                <Text>Keyword</Text>
                <TextInput
                    style={styles.searchBar}
                    placeholder="Enter Keyword"
                    value={keyword}
                    onChangeText={setKeyword}
                />
                <Text>Year</Text>
                <TextInput
                    style={styles.searchBar}
                    placeholder="Enter Year"
                    value={year}
                    onChangeText={setYear}
                />
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
});

export default OpenHistoricalSearchScreen;
