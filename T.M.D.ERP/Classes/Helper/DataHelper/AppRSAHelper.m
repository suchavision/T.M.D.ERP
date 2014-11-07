#import "AppRSAHelper.h"
#import "AppRSAKeysKeeper.h"
#import "AppInterface.h"


#define AA_String @"AA"
#define ZZ_String @"ZZ"
#define R_Pwd @"00YYY"
#define W_Pwd @"an123"


@implementation AppRSAHelper

static RSABase64Cryptor* rsaEncryptor = nil;

+(void)initialize
{
    if (self == [AppRSAHelper class]) {
        rsaEncryptor = [[RSABase64Cryptor alloc] init];
        
        NSString* derString = [[AppRSAKeysKeeper derKey] stringByReplacingOccurrencesOfString:ZZ_String withString:AA_String];
        NSString* p12String = [[AppRSAKeysKeeper p12Key] stringByReplacingOccurrencesOfString:ZZ_String withString:AA_String];
        NSString* password = [[AppRSAKeysKeeper p12Password] stringByReplacingOccurrencesOfString: R_Pwd withString:W_Pwd];
        
        [rsaEncryptor loadPublicKeyFromString: derString];
        [rsaEncryptor loadPrivateKeyFromString: p12String password: password];
        RSABase64Cryptor.sharedInstance = rsaEncryptor;
    }
}


+(NSString*) encrypt:(NSString*)string
{
    if (OBJECT_EMPYT(string)) return string;
    
    NSString* result = string;
    @try {
        result = [rsaEncryptor rsaBase64EncryptString: string];
    }
    @catch (NSException *exception) {
        
    }
    return result;
}


+(NSString*) decrypt:(NSString*)string
{
    if (OBJECT_EMPYT(string)) return string;
    NSString* result = string;
    @try {
        result = [rsaEncryptor rsaBase64DecryptString: string];
    }
    @catch (NSException *exception) {
        
    }
    return result;
}


@end
