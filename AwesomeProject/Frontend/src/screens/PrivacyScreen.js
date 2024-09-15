import React, { useState, useEffect } from 'react';
import { StyleSheet, Text, View, TextInput, Button, Dimensions, Platform, Switch, Alert } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useNavigation } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';


const { width } = Dimensions.get('window');

const PrivacyScreen = () => {
    const [isEnabled, setIsEnabled] = useState(false);

    useEffect(() => {
        // Load saved preference from AsyncStorage on app start
        const loadPreference = async () => {
            try {
                const savedValue = await AsyncStorage.getItem('dataCollectionEnabled');
                if (savedValue !== null) {
                    setIsEnabled(JSON.parse(savedValue));
                }
                if (savedValue == "true")
                    console.log("saved: ", savedValue);
            } catch (e) {
                console.error("Failed to load the setting from storage.");
            }
        };
        loadPreference();
    }, []);

    const toggleSwitch = async () => {
        const newValue = !isEnabled;
        setIsEnabled(newValue);

        try {
            await AsyncStorage.setItem('dataCollectionEnabled', JSON.stringify(newValue));
        } catch (e) {
            console.error("Failed to save the setting.");
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Privacy Policy</Text>
            <Text>Effective Date: Sep 12, 2024</Text>
            <Text>This Privacy Policy outlines how we handle your personal information when you use MyInspectorBuddy. We are committed to protecting your privacy and ensuring that your data is secure.{"\n"}</Text>

            <Text>1. Information We Collect{"\n"}</Text>

            <Text>Login Information:</Text>
            <Text>Username and Password: To access the App, we collect and store your username and password. This information is used solely for authentication purposes and to provide you with access to the App's features.</Text>
            <Text>Analytics Information:</Text>
            <Text>Screen Usage Data: The App collects anonymized information about which screens or sections of the App you use. This data is used for improving the App’s functionality and user experience. We do not collect any additional personal or sensitive data through these analytics.{"\n"}</Text>

            <Text>2. How We Use Your Information</Text>
            <Text>We use the collected information for the following purposes:{"\n"}</Text>

            <Text>Authentication: To verify your identity and provide access to the App.</Text>
            <Text>App Improvement: To understand how users interact with the App and to improve its design, usability, and functionality.{"\n"}</Text>

            <Text>3. Data Security</Text>
            <Text>We take the security of your data seriously and implement various measures to protect your information from unauthorized access, alteration, or disclosure. This includes encryption of login credentials and secure storage of data.{"\n"}</Text>

            <Text>4. Third-Party Services</Text>
            <Text>The App does not share any personal information, including usernames and passwords, with third-party services. The analytics data collected is also not shared with any third-party providers and is used solely for internal purposes.{"\n"}</Text>

            <Text>5. Data Retention</Text>
            <Text>Login Information: Your username and password are stored securely and retained for as long as you continue to use the App.</Text>
            <Text>Analytics Data: Anonymized screen usage data is retained for as long as necessary to improve the App’s functionality and user experience.{"\n"}</Text>

            <Text>6. Your Rights</Text>
            <Text>You have the right to:{"\n"}</Text>

            <Text>Request access to the personal data we collect.</Text>
            <Text>Request corrections to your personal information.</Text>
            <Text>Request the deletion of your account and associated data.</Text>
            <Text>To exercise any of these rights, please contact us at Argus.Sun@cdph.ca.gov{"\n"}</Text>

            <Text>7. Changes to This Privacy Policy</Text>
            <Text>We may update this Privacy Policy from time to time. Any changes will be posted within the App and will become effective upon posting.{"\n"}</Text>

            <Text>8. Contact Information</Text>
            <Text>If you have any questions about this Privacy Policy, please contact us at: Argus.Sun@cdph.ca.gov{"\n"}</Text>

            <Text>By using the Medical Inspector App, you agree to the terms of this Privacy Policy. If you do not agree with this policy, please discontinue the use of the App.{"\n"}</Text>

            <Text>Last updated: Sep 12, 2024{"\n"}{"\n"}</Text>

            <Text>Enable Data Collection</Text>
            <Switch
                trackColor={{ false: "#767577", true: "#81b0ff" }}
                thumbColor={isEnabled ? "#f5dd4b" : "#f4f3f4"}
                onValueChange={toggleSwitch}
                value={isEnabled}
            />
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

export default PrivacyScreen;
