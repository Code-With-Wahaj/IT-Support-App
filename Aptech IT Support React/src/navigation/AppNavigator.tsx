import React from 'react';
import { NavigationContainer, DarkTheme } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { RootStackParamList } from './types';
import { SplashScreen } from '../screens/auth/SplashScreen';
import { LoginScreen } from '../screens/auth/LoginScreen';
import { SignupScreen } from '../screens/auth/SignupScreen';
import { ForgotPasswordScreen } from '../screens/auth/ForgotPasswordScreen';
import { DashboardScreen } from '../screens/dashboard/DashboardScreen';
import { ChatsScreen } from '../screens/chats/ChatsScreen';
import { ComplaintDetailScreen } from '../screens/dashboard/ComplaintDetailScreen';
import { FilterComplaintsScreen } from '../screens/dashboard/FilterComplaintsScreen';
import { LabListScreen } from '../screens/labs/LabListScreen';
import { AddEditLabScreen } from '../screens/labs/AddEditLabScreen';
import { Lab3DScreen } from '../screens/labs/Lab3DScreen';
import { ManageUsersScreen } from '../screens/admin/ManageUsersScreen';
import { AdminAddUserScreen } from '../screens/admin/AdminAddUserScreen';
import { colors } from '../theme/colors';

const Stack = createStackNavigator<RootStackParamList>();

const customDarkTheme = {
  ...DarkTheme,
  colors: {
    ...DarkTheme.colors,
    primary: colors.primary,
    background: colors.background,
    card: colors.surfaceElevated,
    text: colors.textPrimary,
    border: colors.surfaceBorder,
    notification: colors.accent,
  },
};

export const AppNavigator: React.FC = () => {
  return (
    <NavigationContainer theme={customDarkTheme}>
      <Stack.Navigator
        id="Root"
        initialRouteName="Splash"
        screenOptions={{
          headerShown: false,
          cardStyle: { backgroundColor: colors.background },
        }}
      >
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Signup" component={SignupScreen} />
        <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
        <Stack.Screen name="Dashboard" component={DashboardScreen} />
        <Stack.Screen name="Chats" component={ChatsScreen} />
        <Stack.Screen name="ComplaintDetail" component={ComplaintDetailScreen} />
        <Stack.Screen name="FilterComplaints" component={FilterComplaintsScreen} />
        <Stack.Screen name="LabList" component={LabListScreen} />
        <Stack.Screen name="AddEditLab" component={AddEditLabScreen} />
        <Stack.Screen name="Lab3D" component={Lab3DScreen} />
        <Stack.Screen name="ManageUsers" component={ManageUsersScreen} />
        <Stack.Screen name="AdminAddUser" component={AdminAddUserScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};
