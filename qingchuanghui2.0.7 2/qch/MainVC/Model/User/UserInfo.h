//
//  UserInfo.h
//  qch
//
//  Created by 苏宾 on 15/12/31.
//  Copyright © 2015年 qch. All rights reserved.
//

#import <ShareSDKExtension/SSEBaseUser.h>

/**
 *  用户信息，用于保存和管理用户的基本信息，继承自SSEBaseUser，可以更好地结合第三方登录助手在用户信息方面的维护处理。
 */
@interface UserInfo : SSEBaseUser

/**
 *  头像
 */
@property (nonatomic, copy) NSString *avatar;

/**
 *  昵称
 */
@property (nonatomic, copy) NSString *nickname;

/**
 *  描述
 */
@property (nonatomic, copy) NSString *aboutMe;

@end
