//
//  CDTMockEncryptionKeychainManager.h
//  Tests
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

#define CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_RETRIEVEDATA       nil
#define CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_GENERATEDATA       nil
#define CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_ALREADYGENERATED   NO
#define CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_CLEARDATA          YES

@interface CDTMockEncryptionKeychainManager : NSObject

@property (assign, nonatomic) BOOL retrieveEncryptionKeyDataExecuted;
@property (strong, nonatomic) NSData *retrieveEncryptionKeyDataResult;

@property (assign, nonatomic) BOOL generateEncryptionKeyDataExecuted;
@property (strong, nonatomic) NSData *generateEncryptionKeyDataResult;

@property (assign, nonatomic) BOOL encryptionKeyDataAlreadyGeneratedExecuted;
@property (assign, nonatomic) BOOL encryptionKeyDataAlreadyGeneratedResult;

@property (assign, nonatomic) BOOL clearEncryptionKeyDataExecuted;
@property (assign, nonatomic) BOOL clearEncryptionKeyDataResult;

- (NSData *)retrieveEncryptionKeyDataUsingPassword:(NSString *)password;
- (NSData *)generateEncryptionKeyDataUsingPassword:(NSString *)password;
- (BOOL)encryptionKeyDataAlreadyGenerated;
- (BOOL)clearEncryptionKeyData;

@end
