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
    @try {
        
//        [self.requestSerializer setValue:[[[self getRequestHeaderWithEncrypt] yy_modelToJSONString] encryptString]forHTTPHeaderField:@"headKey"];
        [self.requestSerializer setValue:nil forHTTPHeaderField:@"headKey"];
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"ios"];
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Content-type"];
        
        NSString *str = [self ObjectToJsonString:content];
        
        //    NSData *bodyData = [[str encryptString] dataUsingEncoding:NSUTF8StringEncoding];
        
        [self POST:url parameters:[str encryptString] progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock) {
                successBlock(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failedBlock) {
                failedBlock(error);
            }
            
        }];
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    NSURLSessionDataTask *task = [super POST:URLString parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = [self JsonDataToObject:responseObject];
        
        NSInteger statusCode = [(NSHTTPURLResponse *)task.response statusCode];
        
        if (statusCode == 200) {
            
            success(task, responseObject);
            
        } else {
            
            failure(task, [self localErrorWithMsg:[self parseStatusMessage:dic] withCode:statusCode]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSString *msg = @"";
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || !task.response) {
            
            msg = @"网络异常，请稍后重试";
        } else {
            msg = @"服务器异常，请稍后重试...";
        }
        
        failure(task, [self localErrorWithMsg:msg withCode:-100]);
        
    }];
    return task;
}

- (NSError *)localErrorWithMsg:(NSString *)msg withCode:(NSInteger)code {
    
    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
    [errorDetails setValue:msg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"twksky" code:code userInfo:errorDetails];
}

- (NSString *)parseStatusMessage:(NSDictionary *)jsonData {
    
    NSString *statusMsg = @"未知错误";
    if ([jsonData objectForKey:@"msg"] && [jsonData objectForKey:@"msg"] != [NSNull null]) {
        
        statusMsg = [jsonData objectForKey:@"msg"];
    }
    return statusMsg;
}

/*同步的http请求 */
- (NSData *)sendRequestSyncWithEncrypt:(NSString *)url andMethod:(NSString *)method andContent:(NSMutableDictionary *)content andTimeout:(int)seconds andError:(NSError **)error
{
    /* /////////////////////////////////////////////////////////////////////////////// */
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:seconds];
    
    /*
     *    [NSMutableURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[[NSURL URLWithString:url] host]];
     * 设置请求方式
     */
    [request setHTTPMethod:method];
    
    /*
     * 添加用户会话id
     *    DebugLog(@"url:%@", url);
     * /////////////////////////
     */
    
    NSMutableDictionary *headerFields = [self getRequestHeaderWithEncrypt];
    
    NSString *headJSONString = [self ObjectToJsonString:headerFields];
    /*    DebugLog(@"headJSON:%@", headJSONString); */
    
    if (headJSONString.length && headJSONString) {
        [request setValue:[headJSONString encryptString] forHTTPHeaderField:@"headKey"];
        [request setValue:@"ios" forHTTPHeaderField:@"ios"];
    }
    
    [request setValue:@"" forHTTPHeaderField:@"Content-type"];
    
    /************************** 加密内容／发送文件流 *************************************************/
    
    NSString *str = [self ObjectToJsonString:content];
    /*    DebugLog(@"PostJson:%@", str); */
    
    NSData *bodyData = [[str encryptString] dataUsingEncoding:NSUTF8StringEncoding];
    
    /*
     *    [request setValue:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5" forHTTPHeaderField:@"User-Agent"];
     * /////////////////////////
     */
    
    /* 设置Content-Length 目前不需要了. */
    if (bodyData && [bodyData length]) {
        /*        [request setValue:[NSString stringWithFormat:@"%zd", [bodyData length]] forHTTPHeaderField:@"Content-Length"]; */
        [request setHTTPBody:bodyData];
    }
    
    /* /////////////////////////////////////////////////////////////////////////////// */
    
    /* 发送同步请求, data就是返回的数据 */
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    if (*error) {
        if ([*error code] == -1001) {
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器超时,请稍候再试."] code:-1001 userInfo:nil];
        }
        
        /*同步请求出错,直接返回空 */
        return nil;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    /* 判断服务器是否返回404 */
    if ((([httpResponse statusCode] / 100) != 2)) {
//        DebugLog(@"SGHttpRequest sync connection didReceiveResponse:%zd andUrl:%@", [httpResponse statusCode], url);
        return nil;
    }
    
    if ((data == nil) || ([data length] == 0)) {
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"连接服务器出错,请稍候再试."] code:0 userInfo:nil];
//        DebugLog(@"data length is 0, or send request failed:url is:%@", url);
        return nil;
    }
    
    return data;
}


/**
 *	@brief	设置请求头部信息
 */
- (NSMutableDictionary *)getRequestHeaderWithEncrypt
{
//    /* http头部信息 */
//    
//    /*
//     *   String uid      (用户id)
//     *   String loginKey (loginKey)
//     *   String gender   (性别)
//     *   String osType   (系统类型)
//     *   String version  (版本)
//     *   String channel  (渠道)
//     *   String imei     (串号)
//     */
//    
//    NSString *version = [SuanGuoVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
//    
////    NSString *imei = [SGAppUtils getIDFAOrMac];
//    
//    NSString *isBroken = nil;
//    
//    if ([SGAppUtils isJailBrokeDevice]) {
//        isBroken = @"2";
//    } else {
//        isBroken = @"1";
//    }
//    
//    /*    NSInteger netWorkStatus = 0;    //未知网络 */
//    
//    /*
//     *    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//     *    switch ([r currentReachabilityStatus])
//     *    {
//     *        case NotReachable:// 没有网络连接
//     *            netWorkStatus = 6;
//     *            break;
//     *        case ReachableViaWWAN:// 使用3G网络
//     *            netWorkStatus = 5;
//     *            break;
//     *        case ReachableViaWiFi:// 使用WiFi网络
//     *            netWorkStatus = 1;
//     *            break;
//     *        default:
//     *            break;
//     *    }
//     */
//    
//    /*    NSString *uid = [[LoginInfoModel shareInstance] userId]; */
//    
    NSMutableDictionary *httpHeader = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       [SGUserInfoManager instance].uid ?[SGUserInfoManager instance].uid : @"", @"uid",
//                                       [SGUserInfoManager instance].loginKey ?[SGUserInfoManager instance].loginKey : @"", @"loginKey",
//                                       imei ? imei : @"", @"imei",
//                                       @([SGUserInfoManager instance].userInfo.gender), @"gender",
//                                       @([isBroken integerValue]), @"osType",
                                       @(1), @"version",
//                                       [[UIDevice currentDevice] systemVersion], @"mobileVersion",
//                                       [SGChannelManager channelName], @"channel",
//                                       [SGAppUtils deviceString], @"deviceModel",
                                       nil];
    return httpHeader;
}

#pragma mark 

- (id)JsonDataToObject:(NSData *)jsonData
{
    if ((jsonData == nil) || ([jsonData length] == 0)) {
//        DebugLog(@"JsonDataToObject error jsonData lenght is 0");
        return nil;
    }
    
    NSError *error = nil;
    id      jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if ((jsonObject != nil) && (error == nil)) {
        return jsonObject;
    } else {
//        DebugLog(@"NSJSONSerialization error:%@ \n error Str %@", error, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        return nil;
    }
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

@end
