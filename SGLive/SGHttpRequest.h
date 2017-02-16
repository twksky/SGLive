//
//  SGHttpRequest.h
//  twksky
//
//  Created by twksky on 16-2-4.
//  Copyright (c) 2014年 twksky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Code.h"
#import "NSData+Code.h"

#define HttpPost            @ "POST"

@interface SGHttpRequest : AFHTTPSessionManager

+ (SGHttpRequest *)instance;

- (void)setHttpHeaderValue:(NSString *)value forKey:(NSString *)key;
/**
 *  异步网络请求
 */
- (void)asyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *data)) successBlock failedBlock:(void (^)(NSError *error))failedBlock;
@end
