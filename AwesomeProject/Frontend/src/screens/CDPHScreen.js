import React, { useState } from 'react';
import { StyleSheet, Text, View, TextInput, Button, Dimensions, Platform } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useNavigation } from '@react-navigation/native';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');



const CDPHScreen = () => {
    const [deviceName, setDeviceName] = useState('');
    const [firmName, setFirmName] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');
    const navigation = useNavigation();

    const handleSearch = async () => {
        logQuery("CDPH");
        setIsLoading(true);
        setError('');
        try {
            const response = await fetch('http://10.0.0.63:5001/cdph', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ deviceName, firmName }),
            });

            const data = await response.json();
            if (response.ok) {
                console.log("Results received:", data); // Log the received data
                navigation.navigate('CDPHResultsScreen', { results: data });
                setIsLoading(false);
            } else {
                throw new Error(data.message || 'Unable to fetch data');
            }
        } catch (error) {
            console.error('Error fetching data:', error);
            setError(error.message);
            setIsLoading(false);
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>CDPH Device Recalls Search</Text>
            
            <View style={styles.inputContainer}>
                <Text>Device Name:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={deviceName}
                    onChangeText={setDeviceName}
                />
                <Text>Firm Name:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={firmName}
                    onChangeText={setFirmName}
                />
            </View>
            
            <Button title="Search" onPress={handleSearch} />
            
            {isLoading && <Text>Loading...</Text>}
            {error && <Text>Error: {error}</Text>}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 20,
    },
    inputContainer: {
        alignSelf: 'stretch',
        marginBottom: 10,
    },
    input: {
        borderWidth: 1,
        borderColor: 'black',
        padding: 10,
        marginBottom: 10,
    },
    // Additional styles
});

export default CDPHScreen;
