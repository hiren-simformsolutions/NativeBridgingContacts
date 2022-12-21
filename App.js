/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  Button,
  StyleSheet,
  NativeModules,
  SafeAreaView,
  StatusBar,
  Text,
} from 'react-native';
const {SelectContact} = NativeModules;

const fetchContacts = async () => {
  console.log('SelectContact', SelectContact);
  const selection = await SelectContact.openContactSelection();
  if (!selection) {
    console.log('no Selection', selection);
    return null;
  }

  console.log('selection', selection);
  // let {contact, selectedPhone} = selection;
  // console.log(
  //   `Selected ${selectedPhone.type} phone number ${selectedPhone.number} from ${contact.name}`,
  // );
  // return selectedPhone.number;
};

const GetContacts = () => {
  return <Button title="Contacts" color="#841584" onPress={fetchContacts} />;
};

const App = () => {
  return (
    <SafeAreaView style={styles.center}>
      <GetContacts />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default App;
