//
//  RCTContacts.m
//  NativeBridging
//
//  Created by Hiren Lalakiya on 18/12/22.
//

@import Foundation;
#import "RCTContacts.h"
@interface RCTContacts()

@property(nonatomic, retain) RCTPromiseResolveBlock _resolve;
@property(nonatomic, retain) RCTPromiseRejectBlock _reject;

@end


@implementation RCTContacts
CNContactStore * contactStore;
RCT_EXPORT_MODULE(SelectContact);

RCT_EXPORT_METHOD(openContactSelection:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  self._resolve = resolve;
  self._reject = reject;
  
  UIViewController *picker = [[CNContactPickerViewController alloc] init];
  ((CNContactPickerViewController *)picker).delegate = self;
  
  // Launch Contact Picker
  UIViewController *root = [[[UIApplication sharedApplication] delegate] window].rootViewController;
  while(root.presentedViewController) {
    root = root.presentedViewController;
  }
  [root presentViewController:picker animated:YES completion:nil];
}

- (NSMutableDictionary *) emptyContactDict {
  NSMutableArray *phones = [[NSMutableArray alloc] init];
  NSMutableArray *emails = [[NSMutableArray alloc] init];
  NSMutableArray *addresses = [[NSMutableArray alloc] init];
  return [[NSMutableDictionary alloc] initWithObjects:@[@"", @"", @"", @"", phones, emails, addresses]
                                              forKeys:@[@"name", @"givenName", @"middleName", @"familyName", @"phones", @"emails", @"postalAddresses"]];
}

#pragma mark - CNContactPickerDelegate
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
  
  /* Return NSDictionary ans JS Object to RN, containing basic contact data
   This is a starting point, in future more fields should be added, as required.
   */
  NSMutableDictionary *contactData = [self emptyContactDict];
  
  [contactData setValue:contact.identifier forKey:@"recordId"];
  //Return name
  NSString *fullName = [self getFullNameForFirst:contact.givenName middle:contact.middleName last:contact.familyName ];
  [contactData setValue:fullName forKey:@"name"];
  [contactData setValue:contact.givenName forKey:@"givenName"];
  [contactData setValue:contact.middleName forKey:@"middleName"];
  [contactData setValue:contact.familyName forKey:@"familyName"];
  
  //Return phone numbers
  NSMutableArray* phoneEntries = [contactData valueForKey:@"phones"];
  for (CNLabeledValue<CNPhoneNumber*> *phone in contact.phoneNumbers) {
    CNPhoneNumber* phoneNumber = [phone value];
    NSString* phoneLabel = [phone label];
    NSMutableDictionary<NSString*, NSString*>* phoneEntry = [[NSMutableDictionary alloc] initWithCapacity:2];
    [phoneEntry setValue:[phoneNumber stringValue] forKey:@"number"];
    [phoneEntry setValue:[CNLabeledValue localizedStringForLabel:phoneLabel] forKey:@"type"];
    [phoneEntries addObject:phoneEntry];
  }
  
  //Return email addresses
  NSMutableArray* emailEntries = [contactData valueForKey:@"emails"];
  for (CNLabeledValue<NSString*> *email in contact.emailAddresses) {
    NSString* emailAddress = [email value];
    NSString* emailLabel = [email label];
    NSMutableDictionary<NSString*, NSString*>* emailEntry = [[NSMutableDictionary alloc] initWithCapacity:2];
    [emailEntry setValue:emailAddress forKey:@"address"];
    [emailEntry setValue:[CNLabeledValue localizedStringForLabel:emailLabel] forKey:@"type"];
    [emailEntries addObject:emailEntry];
  }
  
  // Return postal addresses
  NSMutableArray* addressEntries = [contactData valueForKey:@"postalAddresses"];
  for (CNLabeledValue<CNPostalAddress*> *postalAddress in contact.postalAddresses) {
    CNPostalAddress* addressInfo = [postalAddress value];
    NSMutableDictionary<NSString*, NSString*>* addressEntry = [[NSMutableDictionary alloc] init];
    [addressEntry setValue:[addressInfo street] forKey:@"street"];
    [addressEntry setValue:[addressInfo city] forKey:@"city"];
    [addressEntry setValue:[addressInfo state] forKey:@"state"];
    [addressEntry setValue:[addressInfo postalCode] forKey:@"postalCode"];
    [addressEntry setValue:[addressInfo ISOCountryCode] forKey:@"isoCountryCode"];
    [addressEntries addObject:addressEntry];
  }
  
  self._resolve(contactData);
}

-(NSString *) getFullNameForFirst:(NSString *)fName middle:(NSString *)mName last:(NSString *)lName {
  //Check whether to include middle name or not
  NSArray *names = (mName.length > 0) ? [NSArray arrayWithObjects:fName, mName, lName, nil] : [NSArray arrayWithObjects:fName, lName, nil];
  return [names componentsJoinedByString:@" "];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
  self._reject(@"E_CONTACT_CANCELLED", @"Cancelled", nil);
}

RCT_EXPORT_METHOD(addContact:(NSDictionary *)contactData resolver:(RCTPromiseResolveBlock) resolve
    rejecter:(RCTPromiseRejectBlock) reject)
{
    CNContactStore* contactStore = [self contactsStore:reject];
    if(!contactStore)
        return;

    CNMutableContact * contact = [[CNMutableContact alloc] init];

    [self updateRecord:contact withData:contactData];

    @try {
        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request addContact:contact toContainerWithIdentifier:nil];

        [contactStore executeSaveRequest:request error:nil];

        NSDictionary *contactDict = [self contactToDictionary:contact withThumbnails:false];

        resolve(contactDict);
    }
    @catch (NSException *exception) {
        reject(@"Error", [exception reason], nil);
    }
}

-(CNContactStore*) contactsStore: (RCTPromiseRejectBlock) reject {
    if(!contactStore) {
        CNContactStore* store = [[CNContactStore alloc] init];

        contactStore = store;
    }
    if(!contactStore.defaultContainerIdentifier) {
        RCTLog(@"warn - no contact store container id");

        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (authStatus == CNAuthorizationStatusDenied || authStatus == CNAuthorizationStatusRestricted){
            reject(@"Error", @"denied", nil);
        } else {
            reject(@"Error", @"undefined", nil);
        }

        return nil;
    }

    return contactStore;
}
@end
