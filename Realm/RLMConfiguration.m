////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Realm/RLMConfiguration.h>
#import <Realm/RLMConfiguration_Dynamic.h>

#import <objc/runtime.h>

@interface RLMConfiguration ()

@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, copy, readwrite) NSString *inMemoryIdentifier;
@property (nonatomic, copy, readwrite) NSData *encryptionKey;
@property (nonatomic, readwrite)       BOOL    readonly;
@property (nonatomic, readwrite)       BOOL    dynamic;
@property (nonatomic, copy, readwrite) NSString *fileProtectionAttributes;
@property (nonatomic, copy, readwrite) RLMSchema *customSchema;

@property (nonatomic, readwrite)       NSUInteger schemaVersion;
@property (nonatomic, copy, readwrite) RLMMigrationBlock migrationBlock;

@property (nonatomic, readwrite)       BOOL deleteIfMigrationNeeded;

@end

@interface RLMConfiguration ()<RLMConfigurator>

@end

@implementation RLMConfiguration

RLMConfiguration *s_defaultConfiguration;
static NSString * const c_defaultRealmFileName = @"default.realm";

+ (NSString *)defaultRealmPath
{
    static NSString *defaultRealmPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRealmPath = [[self class] writeablePathForFile:c_defaultRealmFileName];
    });
    return defaultRealmPath;
}

+ (NSString *)writeablePathForFile:(NSString*)fileName
{
#if TARGET_OS_IPHONE
    // On iOS the Documents directory isn't user-visible, so put files there
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
#else
    // On OS X it is, so put files in Application Support. If we aren't running
    // in a sandbox, put it in a subdirectory based on the bundle identifier
    // to avoid accidentally sharing files between applications
    NSString *path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    if (![[NSProcessInfo processInfo] environment][@"APP_SANDBOX_CONTAINER_ID"]) {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        if ([identifier length] == 0) {
            identifier = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        }
        path = [path stringByAppendingPathComponent:identifier];

        // create directory
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
#endif
    return [path stringByAppendingPathComponent:fileName];
}

+ (instancetype)defaultConfiguration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_defaultConfiguration) {
            s_defaultConfiguration = [[RLMConfiguration alloc] init];
        }
    });
    return s_defaultConfiguration;
}

+ (void)setDefaultConfiguration:(RLMConfiguration *)configuration {
    s_defaultConfiguration = configuration ?: [[RLMConfiguration alloc] init];
}

+ (instancetype)configurationWithBlock:(void (^)(id<RLMConfigurator>))block {
    RLMConfiguration *configuration = [[[self class] alloc] init];
    block(configuration);
    return configuration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.path = [[self class] defaultRealmPath];
    }

    return self;
}

- (instancetype)copyWithZone:(__unused NSZone *)zone {
    return self;
}

- (instancetype)copyWithChanges:(void (^)(id<RLMConfigurator>))block {
    RLMConfiguration *configuration = [[[self class] alloc] init];
    unsigned int propertyCount;
    objc_property_t *properties = protocol_copyPropertyList(@protocol(RLMConfigurator), &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        NSString *key = @(property_getName(properties[i]));
        [configuration setValue:[self valueForKey:key] forKey:key];
    }
    block(configuration);
    return configuration;
}

@end