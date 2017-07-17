//
//  IGLocalAlarmNotificationManager.h
//  闹钟
//
//  Created by 九安医疗 on 2017/7/17.
//  Copyright © 2017年 九安医疗. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGLocalAlarmNotificationManager : NSObject
/**
 
 开启一个闹钟
 
 @param fireDate 闹钟时间
 @param soundName 声音
 @param alertBody 弹框内容
 @param isTest 测试
 @param isInsulin 注射胰岛素
 @param isMedicine 吃药
 @param alertAction 闹钟的滑动文字
 @param repeatForWeek 周几重复通知
 @param title iOS10 通知的标题
 @param subtitle iOS10 通知的副标题
 @param isSnooze 是否开启小睡功能
 @param isOpen 是否正在开启
 */

+ (void)addOrUpdateLocalAlarmNotificationFireDate:(NSDate *)fireDate alertBody:(NSString *)alertBody isTest:(BOOL)isTest isInsulin:(BOOL)isInsulin isMedicine:(BOOL)isMedicine soundName:(NSString *)soundName alertAction:(NSString *)alertAction repeatForWeek:(NSString *)repeatForWeek title:(NSString *)title subtitle:(NSString *)subtitle isSnooze:(BOOL)isSnooze isOpen:(BOOL)isOpen;
/**
 获取所有的闹钟实例
 
 @return 所有的闹钟实例
 */
+ (NSMutableArray *)getAllLocalAlarmNotification;
/**
 清楚所有的闹钟
 */
+ (void)clearAllLocalAlarmNotification;
/**
 移除某个闹钟
 
 @param fireDate 闹钟时间
 */
+(void)removeSpecifyAlarmNotification:(NSDate *)fireDate;
@end
