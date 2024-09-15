import React, { useState } from 'react';
import { StyleSheet, Text, View, TextInput, Button, Dimensions } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import analytics from '@react-native-firebase/analytics';
import { logQuery } from './HomeScreen';


const { width } = Dimensions.get('window');


const FDAScreen = ({ navigation }) => {
    const [fromDate, setFromDate] = useState(new Date());
    const [toDate, setToDate] = useState(new Date());
    const [productDescription, setProductDescription] = useState('');
    const [recallingFirm, setRecallingFirm] = useState('');
    const [recallNumber, setRecallNumber] = useState('');
    const [recallClass, setRecallClass] = useState('');
    const [showFromDatePicker, setShowFromDatePicker] = useState(false);
    const [showToDatePicker, setShowToDatePicker] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');


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
        logQuery("FDA");
        setIsLoading(true);
        setError('');
        try {
            const response = await fetch('http://10.0.0.63:5001', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    productDescription,
                    recallingFirm,
                    recallNumber,
                    recallClass,
                    fromDate: fromDate.toISOString().split('T')[0],
                    toDate: toDate.toISOString().split('T')[0],
                })
            });

            console.log('Response Status:', response.status);
            console.log('Response Headers:', response.headers);

            const data = await response.json();
            console.log('Response Data:', data);

            if (response.ok) {
                navigation.navigate('Recall', { results: data.results || [] });
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
            <Text style={styles.title}>FDA Enforcement Recall Search</Text>
            <View style={styles.inputContainer}>
                <Text>Product Description:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={productDescription}
                    onChangeText={setProductDescription}
                />
                <Text>Recalling Firm:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={recallingFirm}
                    onChangeText={setRecallingFirm}
                />
                <Text>Recall Number:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={recallNumber}
                    onChangeText={setRecallNumber}
                />
                <Text>Recall Class:</Text>
                <TextInput
                    style={styles.input}
                    placeholder="Search Bar"
                    value={recallClass}
                    onChangeText={setRecallClass}
                />
            </View>
            <View style={styles.dateInputContainer}>
                <Text>Classified From Date:</Text>
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
                <Text>Classified To Date:</Text>
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

export default FDAScreen;
