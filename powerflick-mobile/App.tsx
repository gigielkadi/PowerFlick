import React, { useState } from 'react';
import { StyleSheet, View, TextInput, Button, Text, ScrollView, Alert } from 'react-native';
import { createClient } from '@supabase/supabase-js';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Initialize Supabase client
const supabase = createClient(
  'http://127.0.0.1:54321',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  {
    auth: {
      storage: AsyncStorage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
    },
  }
);

export default function App() {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    firstName: '',
    lastName: '',
    phoneNumber: '',
    address: '',
    city: '',
    country: '',
    postalCode: ''
  });
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  const handleSignUp = async () => {
    setLoading(true);
    try {
      // 1. Sign up the user with Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
        options: {
          data: {
            first_name: formData.firstName,
            last_name: formData.lastName,
            signup_source: 'mobile'
          }
        }
      });

      if (authError) throw authError;

      // 2. Update the user profile with additional information
      const { error: profileError } = await supabase
        .from('users')
        .update({
          first_name: formData.firstName,
          last_name: formData.lastName,
          phone_number: formData.phoneNumber,
          address: formData.address,
          city: formData.city,
          country: formData.country,
          postal_code: formData.postalCode,
          timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
          language: navigator.language,
          is_active: true,
          last_login: new Date().toISOString()
        })
        .eq('id', authData.user?.id);

      if (profileError) throw profileError;

      // 3. Fetch the complete user profile
      const { data: profileData, error: fetchError } = await supabase
        .from('users')
        .select('*')
        .eq('id', authData.user?.id)
        .single();

      if (fetchError) throw fetchError;

      setResult({ user: authData.user, profile: profileData });
      Alert.alert('Success', 'User signed up successfully!');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.form}>
        <Text style={styles.title}>Test Signup</Text>

        <TextInput
          style={styles.input}
          placeholder="Email"
          value={formData.email}
          onChangeText={(text) => setFormData(prev => ({ ...prev, email: text }))}
          keyboardType="email-address"
          autoCapitalize="none"
        />

        <TextInput
          style={styles.input}
          placeholder="Password"
          value={formData.password}
          onChangeText={(text) => setFormData(prev => ({ ...prev, password: text }))}
          secureTextEntry
        />

        <TextInput
          style={styles.input}
          placeholder="First Name"
          value={formData.firstName}
          onChangeText={(text) => setFormData(prev => ({ ...prev, firstName: text }))}
        />

        <TextInput
          style={styles.input}
          placeholder="Last Name"
          value={formData.lastName}
          onChangeText={(text) => setFormData(prev => ({ ...prev, lastName: text }))}
        />

        <TextInput
          style={styles.input}
          placeholder="Phone Number"
          value={formData.phoneNumber}
          onChangeText={(text) => setFormData(prev => ({ ...prev, phoneNumber: text }))}
          keyboardType="phone-pad"
        />

        <TextInput
          style={styles.input}
          placeholder="Address"
          value={formData.address}
          onChangeText={(text) => setFormData(prev => ({ ...prev, address: text }))}
        />

        <TextInput
          style={styles.input}
          placeholder="City"
          value={formData.city}
          onChangeText={(text) => setFormData(prev => ({ ...prev, city: text }))}
        />

        <TextInput
          style={styles.input}
          placeholder="Country"
          value={formData.country}
          onChangeText={(text) => setFormData(prev => ({ ...prev, country: text }))}
        />

        <TextInput
          style={styles.input}
          placeholder="Postal Code"
          value={formData.postalCode}
          onChangeText={(text) => setFormData(prev => ({ ...prev, postalCode: text }))}
          keyboardType="numeric"
        />

        <Button
          title={loading ? "Signing up..." : "Sign Up"}
          onPress={handleSignUp}
          disabled={loading}
        />

        {result && (
          <View style={styles.result}>
            <Text style={styles.resultTitle}>Signup Successful!</Text>
            <Text style={styles.resultText}>
              {JSON.stringify(result, null, 2)}
            </Text>
          </View>
        )}
    </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  form: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
  },
  input: {
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 5,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#ddd',
  },
  result: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#e8f5e9',
    borderRadius: 5,
    borderWidth: 1,
    borderColor: '#c8e6c9',
  },
  resultTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2e7d32',
    marginBottom: 10,
  },
  resultText: {
    fontSize: 12,
    color: '#1b5e20',
  },
});
