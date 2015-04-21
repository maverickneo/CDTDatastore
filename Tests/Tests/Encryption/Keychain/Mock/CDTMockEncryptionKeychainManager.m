//
//  CDTMockEncryptionKeychainManager.m
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

#import "CDTMockEncryptionKeychainManager.h"

@interface CDTMockEncryptionKeychainManager ()

@end

@implementation CDTMockEncryptionKeychainManager

#pragma mark - Init object
- (instancetype)init
{
    self = [super init];
    if (self) {
        _retrieveEncryptionKeyDataExecuted = NO;
        _retrieveEncryptionKeyDataResult = CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_RETRIEVEDATA;
        
        _generateEncryptionKeyDataExecuted = NO;
        _generateEncryptionKeyDataResult = CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_GENERATEDATA;
        
        _encryptionKeyDataAlreadyGeneratedExecuted = NO;
        _encryptionKeyDataAlreadyGeneratedResult =
            CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_ALREADYGENERATED;
        
        _clearEncryptionKeyDataExecuted = NO;
        _clearEncryptionKeyDataResult = CDTMOCKENCRYPTIONKEYCHAINMANAGER_DEFAULT_CLEARDATA;
    }

    return self;
}

#pragma mark - Public methods
- (NSData *)retrieveEncryptionKeyDataUsingPassword:(NSString *)password
{
    self.retrieveEncryptionKeyDataExecuted = YES;
    
    return self.retrieveEncryptionKeyDataResult;
}

- (NSData *)generateEncryptionKeyDataUsingPassword:(NSString *)password
{
    self.generateEncryptionKeyDataExecuted = YES;
    
    return self.generateEncryptionKeyDataResult;
}

- (BOOL)encryptionKeyDataAlreadyGenerated
{
    self.encryptionKeyDataAlreadyGeneratedExecuted = YES;
    
    return self.encryptionKeyDataAlreadyGeneratedResult;
}

- (BOOL)clearEncryptionKeyData
{
    self.clearEncryptionKeyDataExecuted = YES;
    
    return self.clearEncryptionKeyDataResult;
}

@end
