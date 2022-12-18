/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import type {Node} from 'react';
import {
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  NativeModules,
} from 'react-native';
import {Box, NativeBaseProvider} from 'native-base';
const {CalendarModule} = NativeModules;

/* $FlowFixMe[missing-local-annot] The type annotation(s) required by Flow's
 * LTI update could not be added via codemod */
const NewModuleButton = () => {
  // const onPress = () => {
  //   CalendarModule.createCalendarEvent('Simform', 'Ahmedabad');
  //   console.log('We will invoke the native module here!');
  // };

  return (
    <Button
      title="Click to invoke your native module!"
      color="#841584"
      // onPress={onPress}
    />
  );
};

const App: () => Node = () => {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <NativeBaseProvider>
      <Box>Hello world</Box>
    </NativeBaseProvider>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
