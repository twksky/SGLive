//
//  SGHttpRequest.m
//  twksky
//
//  Created by twksky on 16-2-4.
//  Copyright (c) 2014年 twksky. All rights reserved.
//

#import "SGHttpRequest.h"

@interface SGHttpRequest ()

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
        
        x = [[SGHttpRequest alloc] initWithBaseURL:url sessionConfiguration:nil];
        
        x.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/plain", nil];
        x.requestSerializer = [AFJSONRequestSerializer serializer];
        x.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return x;
}

- (void)asyncPostRequestWithEncrypt:(NSString *)url content:(NSMutableDictionary *)content successBlock:(void (^)(NSData *))successBlock failedBlock:(void (^)(NSError *))failedBlock{
    
    [self.requestSerializer setValue:[[self parseStatusMessage:[self getRequestHeaderWithEncrypt]] encryptString] forHTTPHeaderField:@"headKey"];
    [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"ios"];
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Content-type"];

    NSString *str = [self ObjectToJsonString:content];
    
//    NSData *bodyData = [[str encryptString] dataUsingEncoding:NSUTF8StringEncoding];
    
    [self POST:url parameters:[str encryptString] progress:^(NSProgress * _Nonnull uploadProgress) {
        
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

- (NSString *)ObjectToJsonString:(id)_object
{
    
    NSData      *dataJson = [self ObjectToJsonData:_object];
    NSString    *jsonStr = [self JsonDataToNSString:dataJson];
    
    return jsonStr;
}

- (NSData *)ObjectToJsonData:(id)_object
{
    
    NSError *error = nil;
    
    if ([NSJSONSerialization isValidJSONObject:_object]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_object options:NSJSONWritingPrettyPrinted error:&error];
        
        if ((jsonData != nil) && (error == nil)) {
            return jsonData;
        } else {
            NSLog(@"json error:%@", error);
        }
    }
    
    return nil;
}

- (NSString *)JsonDataToNSString:(NSData *)jsonData
{
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (jsonString != nil) {
#if !__has_feature(objc_arc)
        return [jsonString autorelease];
        
#else
        return jsonString;
#endif
    } else {
        return nil;
    }
    
    return nil;
}

/**
 *	@brief	设置请求头部信息
 */
- (NSMutableDictionary *)getRequestHeaderWithEncrypt
{
    /* http头部信息 */
    
    /*
     *   String uid      (用户id)
     *   String loginKey (loginKey)
     *   String gender   (性别)
     *   String osType   (系统类型)
     *   String version  (版本)
     *   String channel  (渠道)
     *   String imei     (串号)
     */
    
//    NSString *version = [SuanGuoVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    
//    NSString *imei = [SGAppUtils getIDFAOrMac];
    
//    NSString *isBroken = nil;
    
//    if ([SGAppUtils isJailBrokeDevice]) {
//        isBroken = @"2";
//    } else {
//        isBroken = @"1";
//    }
    
    /*    NSInteger netWorkStatus = 0;    //未知网络 */
    
    /*
     *    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
     *    switch ([r currentReachabilityStatus])
     *    {
     *        case NotReachable:// 没有网络连接
     *            netWorkStatus = 6;
     *            break;
     *        case ReachableViaWWAN:// 使用3G网络
     *            netWorkStatus = 5;
     *            break;
     *        case ReachableViaWiFi:// 使用WiFi网络
     *            netWorkStatus = 1;
     *            break;
     *        default:
     *            break;
     *    }
     */
    
    /*    NSString *uid = [[LoginInfoModel shareInstance] userId]; */
    
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"1236568", @"uid",
                                       @"", @"loginKey",
                                       @"", @"imei",
                                       @(1), @"gender",
                                       @(1), @"osType",
                                       @(240), @"version",
                                       [[UIDevice currentDevice] systemVersion], @"mobileVersion",
                                       @"suanguo", @"channel",
                                       @"twksky", @"deviceModel",
                                       nil];
    
//    [self.requestSerializer setValue:@"1236568" forHTTPHeaderField:@"uid"];
//    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"loginKey"];
//    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"imei"];
//    [self.requestSerializer setValue:@"1" forHTTPHeaderField:@"gender"];
//    [self.requestSerializer setValue:@"1" forHTTPHeaderField:@"osType"];
//    [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"mobileVersion"];
//    [self.requestSerializer setValue:@"suanguo" forHTTPHeaderField:@"channel"];
//    [self.requestSerializer setValue:@"twksky" forHTTPHeaderField:@"deviceModel"];
    
    return httpHeader;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}


@end
