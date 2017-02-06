//
//  SGHttpRequest.m
//  twksky
//
//  Created by twksky on 16-2-4.
//  Copyright (c) 2014年 twksky. All rights reserved.
//

#import "SGHttpRequest.h"

@interface SGHttpRequest ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation SGHttpRequest

static SGHttpRequest *x = nil;

+ (SGHttpRequest *)instance
{
    if (x == nil) {
//        x = [[SGHttpRequest alloc] init];
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
        
        NSURL *url = [NSURL URLWithString:@""];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        
        [config setHTTPAdditionalHeaders:getRequestHeader()];
        
        
        x = [[SGHttpRequest alloc] initWithBaseURL:url sessionConfiguration:config];
        
        x.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/plain", nil];
        x.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    
    return x;
}

NSMutableDictionary *getRequestHeader()
{
//    NSString *version = [SuanGuoVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
//    NSString *imei = [SGAppUtils getIDFAOrMac];
    
//    NSString *isBroken = nil;
    
//    if ([SGAppUtils isJailBrokeDevice]) {
//        isBroken = @"2";
//    } else {
//        isBroken = @"1";
//    }
    
//    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       [SGUserInfoManager instance].uid ?[SGUserInfoManager instance].uid : @"", @"uid",
//                                       [SGUserInfoManager instance].loginKey ?[SGUserInfoManager instance].loginKey : @"", @"loginKey",
//                                       imei ? imei : @"", @"imei",
//                                       @([SGUserInfoManager instance].userInfo.gender), @"gender",
//                                       @([isBroken integerValue]), @"osType",
//                                       @([version integerValue]), @"version",
//                                       [[UIDevice currentDevice] systemVersion], @"mobileVersion",
//                                       [SGChannelManager channelName], @"channel",
//                                       [SGAppUtils deviceString], @"deviceModel",
//                                       nil];
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @(240), @"version",
                                       nil];
    return httpHeader;
}


- (void)asyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *))successBlock failedBlock:(void (^)(NSError *))failedBlock{
    
    [self POST:url parameters:content progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failedBlock(error);
        
    }];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSURLSessionDataTask *task = [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSInteger statusCode = [self parseStatusCode:responseObject];
        
//        [self dealWith403WithStatusCode:statusCode];
        if (statusCode == 0) {
            
            success(task, responseObject);
        } else if (statusCode == 403) {
//            [LoginManager sharedInstance].loginStatus = LOGINSTATUS_NONE;
            
        } else {
            
            failure(task, [self localErrorWithMsg:[self parseStatusMessage:responseObject] withCode:-200]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSString *msg = @"";
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || !task.response) {
            
            msg = @"网络异常，请稍后重试";
        } else {
            
            msg = @"服务器异常，请稍后重试";
        }
        
        failure(task, [self localErrorWithMsg:msg withCode:-100]);
        
    }];
    
    return task;
}

- (NSError *)localErrorWithMsg:(NSString *)msg withCode:(NSInteger)code {
    
    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
    [errorDetails setValue:msg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:kHostName code:code userInfo:errorDetails];
}

- (NSInteger)parseStatusCode:(NSDictionary *)jsonData {
    
    NSInteger statusCode = -1;
    
    if ([jsonData objectForKey:@"status_code"] && jsonData[@"status_code"] != [NSNull null]) {
        
        statusCode = [[jsonData objectForKey:@"status_code"] integerValue];
    }
    return statusCode;
}

- (NSString *)parseStatusMessage:(NSDictionary *)jsonData {
    
    NSString *statusMsg = @"未知错误";
    if ([jsonData objectForKey:@"status_message"] && [jsonData objectForKey:@"status_message"] != [NSNull null]) {
        
        statusMsg = [jsonData objectForKey:@"status_message"];
    }
    
    return statusMsg;
}

@end
