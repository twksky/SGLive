//
//  NSData+Code.h
//  twksky
//
//  Created by twksky on 16-2-4.
//  Copyright (c) 2014年 twksky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (Code)

- (NSData *)tripleDES;
- (NSData *)decodeTripleDES;

@end
