import React, { useState } from 'react';
import { StyleSheet, Text, View, TextInput, Button, Dimensions } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useNavigation } from '@react-navigation/native';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');


const K510Screen = () => {
    const [fromDate, setFromDate] = useState(new Date());
    const [toDate, setToDate] = useState(new Date());
    const [showFromDatePicker, setShowFromDatePicker] = useState(false);
    const [showToDatePicker, setShowToDatePicker] = useState(false);
    const [k510Number, setK510Number] = useState('');
    const [applicantName, setApplicantName] = useState('');
    const [deviceName, setDeviceName] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');
    const navigation = useNavigation();


    const onChangeFrom = (event, selectedDate) => {
        const currentDate = selectedDate || fromDate;
        setShowFromDatePicker(false);
        setFromDate(currentDate);
    };

    const onChangeTo = (event, selectedDate) => {
        const currentDate = selectedDate || toDate;
        setShowToDatePicker(false);
        setToDate(currentDate);
    };

    const handleSearch = async () => {
        logQuery("K510");
        setIsLoading(true);
        setError('');
        try {
            const response = await fetch('http://10.0.0.63:5001/k510', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    k510Number,
                    applicantName,
                    deviceName,
                    fromDate: fromDate.toISOString().split('T')[0],
                    toDate: toDate.toISOString().split('T')[0],
                }),
            });

            const data = await response.json();
            if (response.ok) {
                navigation.navigate('K510ResultsScreen', { results: data.results });
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
            <Text style={styles.title}>510K Recall Search</Text>
            
            <View style={styles.inputContainer}>
                <Text>510K Number:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Enter 510K Number"
                    value={k510Number}
                    onChangeText={setK510Number}
                />
                <Text>Applicant Name:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Enter Applicant Name"
                    value={applicantName}
                    onChangeText={setApplicantName}
                />
                <Text>Device Name:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Enter Device Name"
                    value={deviceName}
                    onChangeText={setDeviceName}
                />
            </View>

            <View style={styles.dateInputContainer}>
                <Text>From Date:</Text>
                <Button title="Select Date" onPress={() => setShowFromDatePicker(true)} />
                {showFromDatePicker && (
                    <DateTimePicker
                        testID="dateTimePickerFrom"
                        value={fromDate}
                        mode="date"
                        display="default"
                        onChange={onChangeFrom}
                    />
                )}
            </View>
            <View style={styles.dateInputContainer}>
                <Text>To Date:</Text>
                <Button title="Select Date" onPress={() => setShowToDatePicker(true)} />
                {showToDatePicker && (
                    <DateTimePicker
                        testID="dateTimePickerTo"
                        value={toDate}
                        mode="date"
                        display="default"
                        onChange={onChangeTo}
                    />
                )}
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
    dateInputContainer: {
        marginBottom: 10,
    },
    // Additional styles
});

export default K510Screen;
