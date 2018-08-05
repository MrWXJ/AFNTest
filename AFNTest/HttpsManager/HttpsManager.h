//
//  HttpsManager.h
//  AFNTest
//
//  Created by MrWXJ on 2018/8/5.
//  Copyright © 2018年 MrWXJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^AFNSuccessBlock)(id data,BOOL status);
typedef void(^AFNFailureBlock)(NSError *error);

/**
 类型枚举
 */
enum HTTPSType {
    typeOfGET = 1,//GET
    typeOfPOST = 2,//POST
};

@interface HttpsManager : NSObject

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
              AFNFailureBlock:(AFNFailureBlock)failure;

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
             AFNFailureBlock:(AFNFailureBlock)failure;

/**
 下载文件等任务
 
 @param serverUrl 地址
 */
- (void)downloadWithServerUrl:(NSString *)serverUrl;

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
            AFNFailureBlock:(AFNFailureBlock)failure;

@end
