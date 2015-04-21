//
//  CDTEncryptionKeychainProvider.h
//  CloudantSync
//
//  Created by Enrique de la Torre Fernandez on 21/04/2015.
//  Copyright (c) 2015 IBM Cloudant. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//  http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <Foundation/Foundation.h>

#import "CDTEncryptionKeyProvider.h"
#import "CDTEncryptionKeychainManager.h"

/**
 This class conforms to protocol CDTEncryptionKeyProvider and it can be used to create an
 encrypted datastore.
 
 Given an user-provided password, it generates a strong key and store it safely in the keychain,
 so the same key can be retrieved later provided that the user supplies the same password.
 
 Data is stored in the keychain through a CDTEncryptionKeychainManager which in turn uses a
 CDTEncryptionKeychainStorage. A CDTEncryptionKeychainStorage groups the information stored in
 the keychain with an identifier, this means that it is possible to generate & store multiple
 keys as long as a different CDTEncryptionKeychainManager with a different
 CDTEncryptionKeychainStorage is used for each of them (CDTEncryptionKeychainStorage is different
 from other if it is created with a different identifier).
 
 @see CDTEncryptionKeyProvider
 @see CDTEncryptionKeychainManager
 @see CDTEncryptionKeychainStorage
 */
@interface CDTEncryptionKeychainProvider : NSObject <CDTEncryptionKeyProvider>

/**
 Initialise a provider with a password and a CDTEncryptionKeychainManager instance.
 
 The returned provider will pass the password to the manager to generate the key or get it from the
 keychain if it already exists.
 
 @param password An user-provided password
 @param manager A manager to generate and store the resulting key
 
 @see CDTEncryptionKeychainManager
 */
- (instancetype)initWithPassword:(NSString *)password
                      forManager:(CDTEncryptionKeychainManager *)manager;

/**
 This is a convenience method that creates a CDTEncryptionKeychainManager with the provided
 identifier before calling the init method to create a provider.
 
 @param password An user-provided password
 @param identifier The data saved in the keychain will be accessed with this identifier
 
 @return A key provider
 
 @see CDTEncryptionKeychainManager
 */
+ (instancetype)providerWithPassword:(NSString *)password forIdentifier:(NSString *)identifier;

@end
