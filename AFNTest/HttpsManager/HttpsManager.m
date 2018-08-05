//
//  HttpsManager.m
//  AFNTest
//
//  Created by MrWXJ on 2018/8/5.
//  Copyright © 2018年 MrWXJ. All rights reserved.
//

#import "HttpsManager.h"

#define kTimeOutInterval 10

@implementation HttpsManager

/**
 创建请求者

 @return AFHTTPSessionManager
 */
+ (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //超时时间
    manager.requestSerializer.timeoutInterval = kTimeOutInterval;
    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
    //上传普通格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //上传json格式
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    // 声明获取到的数据格式
    // AFN不会解析,数据是data，需要自己解析
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // AFN会JSON解析返回的数据
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}

/**
 通过服务器拉取数据

 @param type 请求方式
 @param serverUrl 服务器接口
 @param parameter 请求参数
 @param cookie 是否需要cookie
 @param success 成功情况
 @param failure 失败情况
 */
+ (void)pullDataInNetWithType:(enum HTTPSType)type
                    serverUrl:(NSString *)serverUrl
                    parameter:(NSDictionary *)parameter
                       cookie:(BOOL)cookie
              AFNSuccessBlock:(AFNSuccessBlock)success
              AFNFailureBlock:(AFNFailureBlock)failure {
    AFHTTPSessionManager *manager = [self manager];
    if (cookie == true) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *cookie = [NSString stringWithFormat:@"%@", [userDefaults objectForKey:@"cookie"]];
        [manager.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
    if (type == 1) {
        [manager GET:serverUrl parameters:parameter headers:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
            //这里可以获取到目前请求的进度
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                success(obj,YES);
            } else {
                success(@{@"msg":@"暂无数据"},NO);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    } else {
        [manager POST:serverUrl parameters:parameter headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
            //这里可以获取到目前请求的进度
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                success(obj,YES);
            } else {
                success(@{@"msg":@"暂无数据"},NO);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
}


/**
 用户登录

 @param account 账号
 @param password 密码
 @param success 成功
 @param failure 失败
 */
+ (void)loginWithUserAccount:(NSString *)account
                    password:(NSString *)password
             AFNSuccessBlock:(AFNSuccessBlock)success
             AFNFailureBlock:(AFNFailureBlock)failure {
    AFHTTPSessionManager *manager = [self manager];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *cookie = [NSString stringWithFormat:@"%@", [userDefaults objectForKey:@"cookie"]];
//    [manager.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    NSDictionary *param = @{@"UserName":account,@"Password":password,@"Type":@"普通用户"};
    [manager POST:@"" parameters:param headers:@{} progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            success(obj,YES);
        } else {
            success(@{@"msg":@"暂无数据"},NO);
        }
        NSHTTPCookieStorage * storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray * cookies = [storage cookiesForURL:task.response.URL];
        NSMutableString *cookieStr = [NSMutableString string];
        for (NSHTTPCookie * cookie in cookies) {
            [cookieStr appendString:[NSString stringWithFormat:@"%@=%@;", cookie.name, cookie.value]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:cookieStr forKey:@"cookie"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


/**
 下载文件等任务

 @param serverUrl 地址
 */
- (void)downloadWithServerUrl:(NSString *)serverUrl {
    // 1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.设置请求的URL地址
    NSURL *url = [NSURL URLWithString:serverUrl];
    // 3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 4.下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        // 下载进度
        NSLog(@"当前下载进度为:%lf", 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 下载地址
        NSLog(@"默认下载地址%@",targetPath);
        // 设置下载路径,通过沙盒获取缓存地址,最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL fileURLWithPath:filePath]; // 返回的是文件存放在本地沙盒的地址
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // 下载完成调用的方法
        NSLog(@"%@---%@", response, filePath);
    }];
    //5.下载任务
    [task resume];
}


/**
 上传图片

 @param serverUrl 服务器接口
 @param userId 用户id
 @param uploadImage 图片
 @param cookie 是否需要cookie
 @param success 成功
 @param failure 失败
 */
- (void)uploadWithServerUrl:(NSString *)serverUrl
                     userId:(NSString *)userId
                uploadImage:(NSString *)uploadImage
                     cookie:(BOOL)cookie
            AFNSuccessBlock:(AFNSuccessBlock)success
            AFNFailureBlock:(AFNFailureBlock)failure {
    // 创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if (cookie == true) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *cookie = [NSString stringWithFormat:@"%@", [userDefaults objectForKey:@"cookie"]];
        [manager.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
    // 参数
    NSDictionary *param = @{@"Id":userId};
    [manager POST:@"" parameters:param headers:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if ([uploadImage length] > 0){
            /******** 1.上传已经获取到的img *******/
//            // 把图片转换成data
//            NSData *data = UIImagePNGRepresentation(upImg);
//            // 拼接数据到请求题中
//            [formData appendPartWithFileData:data name:@"file" fileName:@"123.png" mimeType:@"image/png"];
            /******** 2.通过路径上传沙盒或系统相册里的图片 *****/
            NSURL *filePath = [NSURL fileURLWithPath:uploadImage];
            [formData appendPartWithFileURL:filePath name:@"file" fileName:@"1234.png" mimeType:@"application/octet-stream" error:nil];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        // 打印上传进度
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //请求成功
//        NSDictionary *dic = responseObject;
        NSLog(@"请求成功：%@",responseObject);
        success(responseObject,YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求失败
        NSLog(@"请求失败：%@",error);
        failure(error);
    }];
}

- (void)AFNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"数据流量");
                break;
                
            default:
                break;
        }
    }];
}

@end
