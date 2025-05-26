import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

interface SignUpData {
  email: string
  password: string
  firstName: string
  lastName: string
  phoneNumber?: string
  address?: string
  city?: string
  country?: string
  postalCode?: string
  timezone?: string
  language?: string
  notificationPreferences?: {
    email: boolean
    push: boolean
    sms: boolean
  }
}

export async function signUp({
  email,
  password,
  firstName,
  lastName,
  phoneNumber,
  address,
  city,
  country,
  postalCode,
  timezone = 'UTC',
  language = 'en',
  notificationPreferences = {
    email: true,
    push: true,
    sms: false
  }
}: SignUpData) {
  try {
    // 1. Sign up the user with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          first_name: firstName,
          last_name: lastName,
          signup_source: 'web' // or 'mobile', 'api', etc.
        }
      }
    })

    if (authError) throw authError

    // 2. Update the user profile with additional information
    const { error: profileError } = await supabase
      .from('users')
      .update({
        first_name: firstName,
        last_name: lastName,
        phone_number: phoneNumber,
        address,
        city,
        country,
        postal_code: postalCode,
        timezone,
        language,
        notification_preferences: notificationPreferences,
        is_active: true,
        last_login: new Date().toISOString()
      })
      .eq('id', authData.user?.id)

    if (profileError) throw profileError

    return { success: true, user: authData.user }
  } catch (error) {
    console.error('Error during signup:', error)
    return { success: false, error }
  }
}

// Example of how to update user data
export async function updateUserProfile(userId: string, updates: Partial<SignUpData>) {
  try {
    // Convert camelCase to snake_case for database fields
    const dbUpdates = {
      first_name: updates.firstName,
      last_name: updates.lastName,
      phone_number: updates.phoneNumber,
      address: updates.address,
      city: updates.city,
      country: updates.country,
      postal_code: updates.postalCode,
      timezone: updates.timezone,
      language: updates.language,
      notification_preferences: updates.notificationPreferences
    }

    const { error } = await supabase
      .from('users')
      .update(dbUpdates)
      .eq('id', userId)

    if (error) throw error
    return { success: true }
  } catch (error) {
    console.error('Error updating profile:', error)
    return { success: false, error }
  }
}

// Example of how to fetch user data
export async function getUserProfile(userId: string) {
  try {
    const { data, error } = await supabase
      .from('users')
      .select(`
        id,
        email,
        first_name,
        last_name,
        phone_number,
        address,
        city,
        country,
        postal_code,
        timezone,
        language,
        notification_preferences,
        signup_source,
        signup_date,
        last_login,
        is_active,
        connected_devices,
        number_of_rooms,
        created_at,
        updated_at
      `)
      .eq('id', userId)
      .single()

    if (error) throw error

    // Convert snake_case to camelCase for frontend
    const formattedData = {
      id: data.id,
      email: data.email,
      firstName: data.first_name,
      lastName: data.last_name,
      phoneNumber: data.phone_number,
      address: data.address,
      city: data.city,
      country: data.country,
      postalCode: data.postal_code,
      timezone: data.timezone,
      language: data.language,
      notificationPreferences: data.notification_preferences,
      signupSource: data.signup_source,
      signupDate: data.signup_date,
      lastLogin: data.last_login,
      isActive: data.is_active,
      connectedDevices: data.connected_devices,
      numberOfRooms: data.number_of_rooms,
      createdAt: data.created_at,
      updatedAt: data.updated_at
    }

    return { success: true, data: formattedData }
  } catch (error) {
    console.error('Error fetching profile:', error)
    return { success: false, error }
  }
}

// Example usage:
/*
const signupResult = await signUp({
  email: 'user@example.com',
  password: 'securepassword123',
  firstName: 'John',
  lastName: 'Doe',
  phoneNumber: '+1234567890',
  address: '123 Main St',
  city: 'New York',
  country: 'USA',
  postalCode: '10001'
})

if (signupResult.success) {
  // Update additional profile information
  await updateUserProfile(signupResult.user.id, {
    timezone: 'America/New_York',
    language: 'en',
    notificationPreferences: {
      email: true,
      push: true,
      sms: true
    }
  })
}
*/ 