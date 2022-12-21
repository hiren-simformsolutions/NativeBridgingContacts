//
//  RCTContactsModule.h
//  NativeBridging
//
//  Created by Hiren Lalakiya on 18/12/22.
//


#import <React/RCTBridgeModule.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface RCTContacts : NSObject <RCTBridgeModule, CNContactViewControllerDelegate>

@end
