import React, { useState } from 'react';
import { View, Text, TextInput, Dimensions, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');

const CAEntitySearchScreen = () => {
    const [searchTerm, setSearchTerm] = useState('');
    const navigation = useNavigation();

    const fetchData = () => {
        const data = {
            searchTerm
        };

        logQuery("CAEntitySearch");

        fetch('http://10.0.0.63:5001/ca-business-entity', { // Update with your server's IP address
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
                // Navigate to CAEntityResultsScreen with the fetched data
                navigation.navigate('CAEntityResultsScreen', { results: result });
            }
        })
        .catch(error => {
            console.error('Error fetching data:', error);
            Alert.alert('Error', 'Failed to fetch data from the server');
        });
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>CA Business Entity Search</Text>
            
            <View style={styles.searchSection}>
                <Text>Search Term</Text>
                <TextInput
                    style={styles.searchBar}
                    placeholder="Enter Search Term"
                    value={searchTerm}
                    onChangeText={setSearchTerm}
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

export default CAEntitySearchScreen;
