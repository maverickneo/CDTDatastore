//
//  CDTEncryptionKeychainStorage.m
//  CloudantSync
//
//  Created by Enrique de la Torre Fernandez on 12/04/2015.
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

#import "CDTEncryptionKeychainStorage.h"

#import "CDTLogging.h"

#define CDTENCRYPTION_KEYCHAINSTORAGE_SERVICE_VALUE \
    @"com.cloudant.sync.CDTEncryptionKeychainStorage.keychain.service"

#define CDTENCRYPTION_KEYCHAINSTORAGE_ARCHIVE_KEY \
    @"com.cloudant.sync.CDTEncryptionKeychainStorage.archive.key"

@interface CDTEncryptionKeychainStorage ()

@property (strong, nonatomic, readonly) NSString *service;
@property (strong, nonatomic, readonly) NSString *account;

@end

@implementation CDTEncryptionKeychainStorage

#pragma mark - Init object
- (instancetype)init
{
    return [self initWithIdentifier:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        if (identifier) {
            _service = CDTENCRYPTION_KEYCHAINSTORAGE_SERVICE_VALUE;
            _account = identifier;
        } else {
            self = nil;
            
            CDTLogError(CDTDATASTORE_LOG_CONTEXT, @"identifier is mandatory");
        }
    }
    
    return self;
}

#pragma mark - Public methods
- (CDTEncryptionKeychainData *)encryptionKeyData
{
    CDTEncryptionKeychainData *encryptionData = nil;

    NSData *data =
        [CDTEncryptionKeychainStorage genericPwWithService:self.service account:self.account];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [unarchiver setRequiresSecureCoding:YES];

        encryptionData = [unarchiver decodeObjectOfClass:[CDTEncryptionKeychainData class]
                                                  forKey:CDTENCRYPTION_KEYCHAINSTORAGE_ARCHIVE_KEY];

        [unarchiver finishDecoding];
    }

    return encryptionData;
}

- (BOOL)saveEncryptionKeyData:(CDTEncryptionKeychainData *)data
{
    NSMutableData *archivedData = [NSMutableData data];
    NSKeyedArchiver *archiver =
        [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
    [archiver setRequiresSecureCoding:YES];
    [archiver encodeObject:data forKey:CDTENCRYPTION_KEYCHAINSTORAGE_ARCHIVE_KEY];
    [archiver finishEncoding];

    BOOL success = [CDTEncryptionKeychainStorage storeGenericPwWithService:self.service
                                                                   account:self.account
                                                                      data:archivedData];

    return success;
}

- (BOOL)clearEncryptionKeyData
{
    BOOL success =
        [CDTEncryptionKeychainStorage deleteGenericPwWithService:self.service account:self.account];

    return success;
}

- (BOOL)encryptionKeyDataExists
{
    NSData *data =
        [CDTEncryptionKeychainStorage genericPwWithService:self.service account:self.account];

    return (data != nil);
}

#pragma mark - Private class methods

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSData *)genericPwWithService:(NSString *)service account:(NSString *)account
{
    NSData *data = nil;

    NSMutableDictionary *query =
        [CDTEncryptionKeychainStorage genericPwLookupDictWithService:service account:account];

    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)query, (void *)&data);
    if (err != errSecSuccess) {
        if (err == errSecItemNotFound) {
            CDTLogWarn(CDTDATASTORE_LOG_CONTEXT, @"DPK doc not found in keychain");
        } else {
            CDTLogWarn(CDTDATASTORE_LOG_CONTEXT,
                       @"Error getting DPK doc from keychain, SecItemCopyMatching returned: %d",
                       err);
        }

        data = nil;
    }

    return data;
}

+ (BOOL)deleteGenericPwWithService:(NSString *)service account:(NSString *)account
{
    BOOL success = NO;

    NSMutableDictionary *dict =
        [CDTEncryptionKeychainStorage genericPwLookupDictWithService:service account:account];
    [dict removeObjectForKey:(__bridge id)(kSecMatchLimit)];
    [dict removeObjectForKey:(__bridge id)(kSecReturnAttributes)];
    [dict removeObjectForKey:(__bridge id)(kSecReturnData)];

    OSStatus err = SecItemDelete((__bridge CFDictionaryRef)dict);
    if (err == errSecSuccess || err == errSecItemNotFound) {
        success = YES;
    } else {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT,
                   @"Error getting DPK doc from keychain, SecItemDelete returned: %d", err);
    }

    return success;
}

+ (NSMutableDictionary *)genericPwLookupDictWithService:(NSString *)service
                                                account:(NSString *)account
{
    NSMutableDictionary *genericPasswordQuery = [[NSMutableDictionary alloc] init];

    [genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                             forKey:(__bridge id)kSecClass];
    [genericPasswordQuery setObject:service forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [genericPasswordQuery setObject:account forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];

    // Use the proper search constants, return only the attributes of the first match.
    [genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne
                             forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    [genericPasswordQuery setObject:(__bridge id)kCFBooleanFalse
                             forKey:(__bridge id<NSCopying>)(kSecReturnAttributes)];
    [genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue
                             forKey:(__bridge id<NSCopying>)(kSecReturnData)];

    return genericPasswordQuery;
}

+ (BOOL)storeGenericPwWithService:(NSString *)service
                          account:(NSString *)account
                             data:(NSData *)data
{
    BOOL success = NO;

    NSMutableDictionary *dataStoreDict =
        [CDTEncryptionKeychainStorage genericPwStoreDictWithService:service
                                                            account:account
                                                               data:data];

    OSStatus err = SecItemAdd((__bridge CFDictionaryRef)dataStoreDict, nil);
    if (err == errSecSuccess) {
        success = YES;
    } else if (err == errSecDuplicateItem) {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT, @"Doc already exists in keychain");
        success = NO;
    } else {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT,
                   @"Unable to store Doc in keychain, SecItemAdd returned: %d", err);
        success = NO;
    }

    return success;
}

+ (NSMutableDictionary *)genericPwStoreDictWithService:(NSString *)service
                                               account:(NSString *)account
                                                  data:(NSData *)data
{
    NSMutableDictionary *genericPasswordQuery = [[NSMutableDictionary alloc] init];

    [genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                             forKey:(__bridge id)kSecClass];
    [genericPasswordQuery setObject:service forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [genericPasswordQuery setObject:account forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];

    [genericPasswordQuery setObject:data forKey:(__bridge id<NSCopying>)(kSecValueData)];

    [genericPasswordQuery setObject:(__bridge id)(kSecAttrAccessibleAfterFirstUnlock)
                             forKey:(__bridge id<NSCopying>)(kSecAttrAccessible)];

    return genericPasswordQuery;
}

#else

+ (NSData *)genericPwWithService:(NSString *)service account:(NSString *)account
{
    NSData *data = nil;

    const char *serviceUTF8Str = service.UTF8String;
    UInt32 serviceUTF8StrLength = (UInt32)strlen(serviceUTF8Str);

    const char *accountUTF8Str = account.UTF8String;
    UInt32 accountUTF8StrLength = (UInt32)strlen(accountUTF8Str);

    void *passwordData = NULL;
    UInt32 passwordDataLength = 0;

    OSStatus err = SecKeychainFindGenericPassword(NULL, serviceUTF8StrLength, serviceUTF8Str,
                                                  accountUTF8StrLength, accountUTF8Str,
                                                  &passwordDataLength, &passwordData, NULL);
    if (err == errSecSuccess) {
        data = [NSData dataWithBytes:passwordData length:passwordDataLength];

        SecKeychainItemFreeContent(NULL, passwordData);
    } else if (err == errSecItemNotFound) {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT, @"DPK doc not found in keychain");
    } else {
        CDTLogWarn(
            CDTDATASTORE_LOG_CONTEXT,
            @"Error getting DPK doc from keychain, SecKeychainFindGenericPassword returned: %d",
            err);
    }

    return data;
}

+ (BOOL)deleteGenericPwWithService:(NSString *)service account:(NSString *)account
{
    // Finf the item
    const char *serviceUTF8Str = service.UTF8String;
    UInt32 serviceUTF8StrLength = (UInt32)strlen(serviceUTF8Str);

    const char *accountUTF8Str = account.UTF8String;
    UInt32 accountUTF8StrLength = (UInt32)strlen(accountUTF8Str);

    SecKeychainItemRef itemRef = NULL;

    OSStatus err =
        SecKeychainFindGenericPassword(NULL, serviceUTF8StrLength, serviceUTF8Str,
                                       accountUTF8StrLength, accountUTF8Str, NULL, NULL, &itemRef);
    if (err != errSecSuccess) {
        if (err == errSecItemNotFound) {
            return YES;
        }

        CDTLogWarn(
            CDTDATASTORE_LOG_CONTEXT,
            @"Error getting DPK doc from keychain, SecKeychainFindGenericPassword returned: %d",
            err);

        return NO;
    }

    // Delete the item
    BOOL success = YES;

    err = SecKeychainItemDelete(itemRef);
    if (err != errSecSuccess) {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT,
                   @"Error getting DPK doc from keychain, SecKeychainItemDelete returned: %d", err);

        success = NO;
    }

    CFRelease(itemRef);

    return success;
}

+ (BOOL)storeGenericPwWithService:(NSString *)service
                          account:(NSString *)account
                             data:(NSData *)data
{
    BOOL success = NO;

    const char *serviceUTF8Str = service.UTF8String;
    UInt32 serviceUTF8StrLength = (UInt32)strlen(serviceUTF8Str);

    const char *accountUTF8Str = account.UTF8String;
    UInt32 accountUTF8StrLength = (UInt32)strlen(accountUTF8Str);

    const void *passwordData = data.bytes;
    UInt32 passwordDataLength = (UInt32)data.length;

    OSStatus err = SecKeychainAddGenericPassword(NULL, serviceUTF8StrLength, serviceUTF8Str,
                                                 accountUTF8StrLength, accountUTF8Str,
                                                 passwordDataLength, passwordData, NULL);

    if (err == errSecSuccess) {
        success = YES;
    } else if (err == errSecDuplicateItem) {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT, @"Doc already exists in keychain");
        success = NO;
    } else {
        CDTLogWarn(CDTDATASTORE_LOG_CONTEXT,
                   @"Unable to store Doc in keychain, SecKeychainAddGenericPassword returned: %d",
                   err);
        success = NO;
    }

    return success;
}

#endif

@end