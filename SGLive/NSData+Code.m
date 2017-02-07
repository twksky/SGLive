//
//  NSData+Code.m
//  twksky
//
//  Created by twksky on 16-2-4.
//  Copyright (c) 2014年 twksky. All rights reserved.
//

#import "NSData+Code.h"
#import <AFNetworking.h>

#pragma mark - 加密

#define SuanGuo3DesKey @ "WGGXhzydkj1SuanGuo"

@implementation NSData (COde)

//- (NSData *)tripleDES
//{
//    NSData      *origData = self;
//    NSString    *key = SuanGuo3DesKey;
//
//    NSData *encryptData;
//
//    encryptData = origData;
//
//    char keyBuffer[kCCKeySize3DES + 1];     // room for terminator (unused)
//    bzero(keyBuffer, sizeof(keyBuffer));    // fill with zeroes (for padding)
//
//    [key getCString:keyBuffer maxLength:sizeof(keyBuffer) encoding:NSUTF8StringEncoding];
//
//    // encrypts in-place, since this is a mutable data object
//    size_t numBytesEncrypted = 0;
//
//    size_t returnLength = ([encryptData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
//
//    char *returnBuffer = malloc(returnLength * sizeof(uint8_t));
//
//    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding | kCCOptionECBMode,
//            keyBuffer, kCCKeySize3DES, nil,
//            [encryptData bytes], [encryptData length],
//            returnBuffer, returnLength,
//            &numBytesEncrypted);
//
//    if (ccStatus == kCCParamError) {
//        NSLog(@"PARAM ERROR");
//    } else if (ccStatus == kCCBufferTooSmall) {
//        NSLog(@"BUFFER TOO SMALL");
//    } else if (ccStatus == kCCMemoryFailure) {
//        NSLog(@"MEMORY FAILURE");
//    } else if (ccStatus == kCCAlignmentError) {
//        NSLog(@"ALIGNMENT");
//    } else if (ccStatus == kCCDecodeError) {
//        NSLog(@"DECODE ERROR");
//    } else if (ccStatus == kCCUnimplemented) {
//        NSLog(@"UNIMPLEMENTED");
//    }
//
//    //	NSMutableString *hexResult=nil;
//
//    NSData *resultData = [NSData dataWithBytes:returnBuffer length:returnLength];
//    //	if(ccStatus == kCCSuccess)
//    //    {
//    //        hexResult = [[[NSMutableString alloc] init] autorelease];
//    //
//    //		char *tmp = (char*)returnBuffer;
//    //		for (int i=0; i<numBytesEncrypted; i++) {
//    //			NSString *aString = [[NSString alloc] initWithFormat:@"%X",(*tmp)&(0xFF)];
//    //			if ([aString length] == 1) {
//    //				[hexResult appendFormat:@"0%@",aString];
//    //			} else {
//    //				[hexResult appendString:aString];
//    //			}
//    //			[aString release];
//    //			tmp++;
//    //		}
//    //	}
//
//    free(returnBuffer);
//
//    return resultData;
//}
//
//- (NSData *)decodeTripleDES
//{
//    //    NSData *origData = self;
//
//    NSData *decryptData = self;
//
//    NSString *key = SuanGuo3DesKey;
//
//    char keyBuffer[kCCKeySize3DES + 1];     // room for terminator (unused)
//
//    bzero(keyBuffer, sizeof(keyBuffer));    // fill with zeroes (for padding)
//
//    [key getCString:keyBuffer maxLength:sizeof(keyBuffer) encoding:NSUTF8StringEncoding];
//
//    // encrypts in-place, since this is a mutable data object
//    size_t numBytesEncrypted = 0;
//
//    size_t returnLength = ([decryptData length] + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
//
//    char *returnBuffer = malloc(returnLength * sizeof(uint8_t));
//    memset((void *)returnBuffer, 0x0, returnLength);
//
//    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt, kCCAlgorithm3DES, kCCOptionPKCS7Padding | kCCOptionECBMode,
//            keyBuffer, kCCKeySize3DES, nil,
//            [decryptData bytes], [decryptData length],
//            returnBuffer, returnLength,
//            &numBytesEncrypted);
//
//    if (ccStatus == kCCParamError) {
//        NSLog(@"PARAM ERROR");
//    } else if (ccStatus == kCCBufferTooSmall) {
//        NSLog(@"BUFFER TOO SMALL");
//    } else if (ccStatus == kCCMemoryFailure) {
//        NSLog(@"MEMORY FAILURE");
//    } else if (ccStatus == kCCAlignmentError) {
//        NSLog(@"ALIGNMENT");
//    } else if (ccStatus == kCCDecodeError) {
//        NSLog(@"DECODE ERROR");
//    } else if (ccStatus == kCCUnimplemented) {
//        NSLog(@"UNIMPLEMENTED");
//    }
//
//    if (ccStatus == kCCSuccess) {
//        NSInteger   bufferLength = strlen(returnBuffer);
//        NSData      *returnData = [NSData dataWithBytes:returnBuffer length:bufferLength];
//        free(returnBuffer);
//        return returnData;
//    }
//
//    return nil;
//}

@end
