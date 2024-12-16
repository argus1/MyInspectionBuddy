import React, { useState, useEffect } from 'react';
import {
    View,
    Text,
    TextInput,
    StyleSheet,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
    ScrollView,
    RefreshControl,
    Keyboard,
    Platform,
    Dimensions
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import UniversalSearchHistory from './UniversalSearchHistory';
import SearchHistoryService from './SearchHistoryService';
import { MaterialIcons } from '@expo/vector-icons';
import { BACKEND_URL } from '../../config.js';
import * as Location from 'expo-location';

const { width } = Dimensions.get('window');

const CAEntitySearchScreen = () => {
    const [searchTerm, setSearchTerm] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [location, setLocation] = useState(null);
    const [suggestions, setSuggestions] = useState([]);
    const [showSuggestions, setShowSuggestions] = useState(false);
    const navigation = useNavigation();

    // Reset error when screen gains focus
    useEffect(() => {
        loadHistoricalSearches();
    }, []);

    const loadHistoricalSearches = async () => {
        try {
            const history = await SearchHistoryService.getHistory('CA_ENTITY');
            setSuggestions(history);
        } catch (error) {
            console.error('Error loading historical searches:', error);
        }
    };

    const handleSearchTermChange = (text) => {
        setSearchTerm(text);
        setShowSuggestions(text.length > 0);
    };

    const handleSuggestionSelect = (historyItem) => {
        setSearchTerm(historyItem.searchTerm || '');
        setShowSuggestions(false);
    };

    const renderSuggestions = () => {
        if (!showSuggestions || !searchTerm.trim()) return null;

        const filteredSuggestions = suggestions.filter(item => 
            item.searchTerm && 
            item.searchTerm.toLowerCase().includes(searchTerm.toLowerCase())
        );

        if (filteredSuggestions.length === 0) return null;

        return (
            <View style={styles.suggestionsContainer}>
                {filteredSuggestions.map((item, index) => (
                    <TouchableOpacity
                        key={index}
                        style={styles.suggestionItem}
                        onPress={() => handleSuggestionSelect(item)}
                    >
                        <Text style={styles.suggestionPrimary}>{item.searchTerm}</Text>
                        <Text style={styles.suggestionSecondary}>
                            {`Last searched: ${new Date(item.timestamp).toLocaleDateString()}`}
                        </Text>
                    </TouchableOpacity>
                ))}
            </View>
        );
    };

    const handleHistorySelect = (historyItem) => {
        setSearchTerm(historyItem.searchTerm || '');
    };

    const validateSearch = () => {
        if (!searchTerm.trim()) {
            Alert.alert('Error', 'Please enter a search term');
            return false;
        }
        return true;
    };

    const fetchData = async () => {
        if (!validateSearch()) return;

        setIsLoading(true);

        // Store search params immediately when user searches
        const searchParams = {
            searchTerm: searchTerm.trim()
        };

        // Save to history immediately when search is initiated
        try {
            await SearchHistoryService.saveSearch('CA_ENTITY', searchParams);
            await loadHistoricalSearches();
            //console.log(`${BACKEND_URL}/ca-business-entity`);
            const response = await fetch(`${BACKEND_URL}/ca-business-entity`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(searchParams),
            });

            const result = await response.json();

            if (result.error) {
                Alert.alert('Error', result.error);
            } else {
                if (result && result.length > 0) {
                    navigation.navigate('CAEntityResultsScreen', { results: result });
                } else {
                    Alert.alert('No Results', 'No business entities found for the provided search term.');
                }
            }
        } catch (error) {
            console.error('Error fetching data:', error);
            Alert.alert('Error', 'Failed to fetch data from the server');
        } finally {
            setIsLoading(false);
        }
    };

    const getLocation = async () => {
        let { status } = await Location.requestForegroundPermissionsAsync();
        if (status !== 'granted') {
            setErrorMsg('Permission to access location was denied');
            return;
        }

        let location = await Location.getCurrentPositionAsync({});
        setLocation(location);
        console.log(location["coords"]["latitude"], location["coords"]["longitude"]);

        fetch('https://gis.cdph.ca.gov/gisadmin/rest/services/Geocoding/USA2023R4/GeocodeServer/reverseGeocode?location=' + location["coords"]["longitude"] + '%2C' + location["coords"]["latitude"] + '&langCode=&locationType=&featureTypes=locality&outSR=&preferredLabelValues=&f=pjson', {
            method: 'GET'
        })
            .then(reponse => reponse.json())
            .then(result => {
                console.log(result);
                console.log(result["address"]["City"]);
                if (result["address"]["City"] == "") {
                    setSearchTerm(result["address"]["PlaceName"]);
                } else {
                    setSearchTerm(result["address"]["City"]);
                }
            });
    };

    return (
        <ScrollView style={styles.scrollView}>
            <View style={styles.container}>
                <Text style={styles.title}>CA Business Entity Search</Text>

                <UniversalSearchHistory
                    searchType="CA_ENTITY"
                    onSelectHistory={handleHistorySelect}
                />

                <View style={styles.inputContainer}>
                    <Text style={styles.label}>Search Term: *</Text>
                    <TextInput
                        style={styles.input}
                        placeholder="Enter business name or number"
                        value={searchTerm}
                        onChangeText={handleSearchTermChange}
                        onFocus={() => setShowSuggestions(true)}
                        returnKeyType="search"
                        onSubmitEditing={fetchData}
                        testID="searchInput"
                    />
                    {renderSuggestions()}
                    <TouchableOpacity style={styles.searchButton} onPress={getLocation}>
                        <Text style={styles.searchButtonText}>Use My Location</Text>
                    </TouchableOpacity>
                </View>

                <TouchableOpacity
                    style={[styles.searchButton, isLoading && styles.searchButtonDisabled]}
                    onPress={fetchData}
                    disabled={isLoading}
                >
                    {isLoading ? (
                        <ActivityIndicator color="#FFFFFF" />
                    ) : (
                        <Text style={styles.searchButtonText}>Search</Text>
                    )}
                </TouchableOpacity>

                <Text style={styles.requiredField}>* Required field</Text>

                <Text style={styles.hint}>
                    Enter business name, entity number, or LLC name
                </Text>
            </View>

        </ScrollView>
    );
};

const styles = StyleSheet.create({
    scrollView: {
        flex: 1,
        backgroundColor: '#f5f5f5',
    },
    container: {
        flex: 1,
        padding: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 20,
        textAlign: 'center',
        color: '#333',
    },
    inputContainer: {
        width: '100%',
        marginBottom: 20,
    },
    label: {
        fontSize: 16,
        fontWeight: '500',
        color: '#333',
        marginBottom: 8,
    },
    input: {
        borderWidth: 1,
        borderColor: '#DDD',
        borderRadius: 8,
        fontSize: 16,
        padding: 12,
        backgroundColor: '#fff',
    },
    hint: {
        color: '#666',
        fontSize: 14,
        marginTop: 8,
        textAlign: 'center',
        fontStyle: 'italic',
    },
    searchButton: {
        backgroundColor: '#007AFF',
        padding: 15,
        borderRadius: 8,
        alignItems: 'center',
        marginTop: 10,
    },
    searchButtonDisabled: {
        backgroundColor: '#999',
    },
    searchButtonText: {
        color: '#FFFFFF',
        fontSize: 16,
        fontWeight: '600',
    },
    requiredField: {
        color: '#666',
        fontSize: 12,
        marginTop: 10,
        textAlign: 'center',
        fontStyle: 'italic',
    },
    suggestionsContainer: {
        marginTop: 5,
        backgroundColor: '#fff',
        borderWidth: 1,
        borderColor: '#ddd',
        borderRadius: 8,
        maxHeight: 200,
        elevation: 3,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
    },
    suggestionItem: {
        padding: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#eee',
    },
    suggestionPrimary: {
        fontSize: 16,
        color: '#007AFF',
        fontWeight: '500',
        marginBottom: 4,
    },
    suggestionSecondary: {
        fontSize: 14,
        color: '#666',
        lineHeight: 18,
    }
});

export default CAEntitySearchScreen;