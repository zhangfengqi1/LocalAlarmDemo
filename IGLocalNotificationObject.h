//
//  IGLocalNotificationObject.h
//  闹钟
//
//  Created by 九安医疗 on 2017/7/17.
//  Copyright © 2017年 九安医疗. All rights reserved.
//

#import <Realm/Realm.h>

@interface IGLocalNotificationObject : RLMObject
/**
 identifer: 主键
 */
@property NSString * identifer;

/**
 userName: 用户的名字
 */
@property NSString * userName;

/**
 fireDate: 建立闹钟的时间，精确到时分秒，不需要星期
 */
@property NSDate * fireDate;

/**
 alertBody: 闹钟的主要显示文字
 */
@property NSString * alertBody;

/**
 isTest: 任务--测试
 */
@property BOOL isTest;

/**
 isInsulin: 任务--注射胰岛素
 */
@property BOOL isInsulin;
/**
 isInsulin: 任务--吃药
 */
@property BOOL isMedicine;

/**
 soundName: 闹钟的声音 不填为默认声音
 */
@property NSString * soundName;

/**
 alertAction:闹钟的滑动文字
 */
@property NSString * alertAction;

/**
 repeatForWeek：是否重复通知，按星期排序，例星期一，星期三，星期五重复通知，则赋“1,3,5”，用逗号分隔，不重复则不传
 */
@property NSString * repeatForWeek;

/**
 title：only iOS10 通知的标题
 */
@property NSString * title;

/**
 subtitle：only iOS10 通知的副标题
 */

@property NSString * subtitle;

/**
 isSnooze:是否开启小睡
 */
@property BOOL isSnooze;

/**
 isOpen:是否开启闹钟
 */
@property BOOL isOpen;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<IGLocalNotitcationObject>
RLM_ARRAY_TYPE(IGLocalNotificationObject)
