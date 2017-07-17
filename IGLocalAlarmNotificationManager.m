//
//  IGLocalAlarmNotificationManager.m
//  闹钟
//
//  Created by 九安医疗 on 2017/7/17.
//  Copyright © 2017年 九安医疗. All rights reserved.
//

#import "IGLocalAlarmNotificationManager.h"
#import "IGLocalNotificationObject.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#define After_iOS10 !([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)

NSString const * identifer_key = @"identifer";

@implementation IGLocalAlarmNotificationManager
+ (void)addOrUpdateLocalAlarmNotificationFireDate:(NSDate *)fireDate alertBody:(NSString *)alertBody isTest:(BOOL)isTest isInsulin:(BOOL)isInsulin isMedicine:(BOOL)isMedicine soundName:(NSString *)soundName alertAction:(NSString *)alertAction repeatForWeek:(NSString *)repeatForWeek title:(NSString *)title subtitle:(NSString *)subtitle isSnooze:(BOOL)isSnooze isOpen:(BOOL)isOpen{
    RLMRealm *realm = [RLMRealm defaultRealm];
    IGLocalNotificationObject *localNotificationObject=[[IGLocalNotificationObject alloc] init];
    localNotificationObject.identifer=[self configLocalNotificationIdentiferWithDate:fireDate withWeek:0];
    
    localNotificationObject.fireDate=fireDate;
    localNotificationObject.alertBody=alertBody;
    localNotificationObject.isTest=isTest;
    localNotificationObject.isInsulin=isInsulin;
    localNotificationObject.isMedicine=isMedicine;
    localNotificationObject.soundName=soundName;
    localNotificationObject.alertAction=alertAction;
    localNotificationObject.repeatForWeek=repeatForWeek;
    localNotificationObject.title=title;
    localNotificationObject.subtitle=subtitle;
    localNotificationObject.isSnooze=isSnooze;
    
    localNotificationObject.isOpen=isOpen;
    
    [realm beginWriteTransaction];
    [IGLocalNotificationObject createOrUpdateInRealm:realm withValue:localNotificationObject];
    [realm commitWriteTransaction];
    if (isOpen) {
        [self addLocalNotitcalionWithObject:localNotificationObject];
    }else{
        [self pauseOneLocalNotitcalionWithObject:localNotificationObject];
    }
    
}

+ (NSMutableArray *)getAllLocalAlarmNotification{
    NSMutableArray *allAlarmArray=[NSMutableArray array];
    RLMResults *allAlarms = [IGLocalNotificationObject allObjects];
    
    if (allAlarms && allAlarms.count>0) {
        for (IGLocalNotificationObject *alarmObject in allAlarms) {
            [allAlarmArray addObject:alarmObject];
        }
        [allAlarmArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            IGLocalNotificationObject *alarmObject1=(IGLocalNotificationObject *)obj1;
            IGLocalNotificationObject *alarmObject2=(IGLocalNotificationObject *)obj2;
            
            if ([alarmObject1.fireDate timeIntervalSinceDate:alarmObject2.fireDate]<0) {
                return NSOrderedDescending;
            }
            else if ([alarmObject1.fireDate timeIntervalSinceDate:alarmObject2.fireDate]>0){
                return NSOrderedAscending;
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    
    return allAlarmArray;
}

+ (void)clearAllLocalAlarmNotification{
    [self cancelAllAlarms];
    
    RLMRealm *realm= [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

+(void)removeSpecifyAlarmNotification:(NSDate *)fireDate{
    RLMRealm *realm= [RLMRealm defaultRealm];
    
    if (fireDate) {
        NSString *string=[NSString stringWithFormat:@"identifer = '%@'",[self configLocalNotificationIdentiferWithDate:fireDate withWeek:0]];
        RLMResults *specifyAlarms = [IGLocalNotificationObject objectsWhere:string];
        if (specifyAlarms && specifyAlarms.count>0) {
            IGLocalNotificationObject *specifyAlarm=[specifyAlarms objectAtIndex:0];
            [self pauseOneLocalNotitcalionWithObject:specifyAlarm];
            [realm beginWriteTransaction];
            [realm deleteObject:specifyAlarm];
            [realm commitWriteTransaction];
            
        }
        
    }else{
        NSLog(@"device为空");
    }
}
#pragma mark - 取消本地闹钟
+ (void)pauseOneLocalNotitcalionWithObject:(IGLocalNotificationObject *)obj{
    
    if (After_iOS10) {
        
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[obj.identifer]];
        
    }else{
        
        NSArray * array = [[UIApplication sharedApplication]scheduledLocalNotifications];
        
        for (UILocalNotification * loc in array) {
            
            if ([[loc.userInfo objectForKey:identifer_key] isEqualToString:obj.identifer]) {
                
                [[UIApplication sharedApplication] cancelLocalNotification:loc];
            }
            
        }
    }
    
}
#pragma mark - 添加闹钟

+ (void)addLocalNotitcalionWithObject:(nonnull IGLocalNotificationObject *)obj{
    [self pauseOneLocalNotitcalionWithObject:obj];
    NSMutableArray * weekArray = [self separatedByString:obj.repeatForWeek byComponentsSeparatedWithString:@","];
    
    if (weekArray.count > 0) {
        
        NSInteger todayWeekDay = [self weekdayWithDate:[NSDate date]];
        
        for (NSNumber * weekNum in weekArray) {
            
            NSInteger dateSeq;
            
            dateSeq = (weekNum.integerValue + 7 -todayWeekDay)%7;
            
            
            if (!dateSeq) {
                if ([obj.fireDate timeIntervalSinceDate:[NSDate date]]>0) {
                    dateSeq = 0;
                }else{
                    dateSeq = 7;
                }
                
            }
            
            NSDate * weekSigleDate = [obj.fireDate dateByAddingTimeInterval:(24*3600*dateSeq)];
            
            [self addSingleLocalNotitcalionWithObject:obj withFireDate:weekSigleDate];
        }
        
    }else{
        
        [self addSingleLocalNotitcalionWithObject:obj withFireDate:nil];
    }
}
+ (void)addSingleLocalNotitcalionWithObject:(nonnull IGLocalNotificationObject *)obj withFireDate:(nullable NSDate *)fireDate{
    
    if (After_iOS10) {
        
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:[self setLocalNotificationForAfterVersion10:obj withFireDate:fireDate] withCompletionHandler:^(NSError * _Nullable error) {
            
        }];
        
    }else{
        
        [[UIApplication sharedApplication] scheduleLocalNotification:[self setLocalNotificationForUnitVersion10:obj withFireDate:fireDate]];
    }
    
}
+ (UILocalNotification *)setLocalNotificationForUnitVersion10:(nonnull IGLocalNotificationObject *)obj withFireDate:(nullable NSDate *)fireDate{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *date=fireDate ? fireDate : obj.fireDate;
    if (!fireDate) {
        if ([obj.fireDate timeIntervalSinceDate:[NSDate date]]<=0) {
            date = [obj.fireDate dateByAddingTimeInterval:24*60*60];
        }
    }
    notification.fireDate = date ;
    notification.timeZone = [NSTimeZone localTimeZone];
    NSLog(@"提醒时间：%@",notification.fireDate);
    if (fireDate) {
        //每周重复必须用NSCalendarUnitWeekOfYear
        notification.repeatInterval = NSCalendarUnitWeekOfYear;
    }else{
        notification.repeatInterval = 0;
    }
    
    notification.alertBody = obj.alertBody;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = obj.soundName ? obj.soundName:UILocalNotificationDefaultSoundName ;
    
    NSString *identifer = [self configLocalNotificationIdentiferWithDate:obj.fireDate withWeek:0 ];
    
    NSDictionary *userDict = @{identifer_key:identifer};
    
    notification.userInfo = userDict;
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        //        notification.repeatInterval = NSCalendarUnitWeekOfYear;
    } else {
        // 通知重复提示的单位，可以是天、周、月
        //        notification.repeatInterval = NSCalendarUnitWeekOfYear;
    }
    
    
    return notification;
}
+ (UNNotificationRequest *)setLocalNotificationForAfterVersion10:(nonnull IGLocalNotificationObject *)obj withFireDate:(nullable NSDate *)fireDate{
    
    NSDate * date = fireDate ? fireDate : obj.fireDate;
    
    if (!fireDate) {
        if ([obj.fireDate timeIntervalSinceDate:[NSDate date]]<=0) {
            date = [obj.fireDate dateByAddingTimeInterval:24*60*60];
        }
    }
    NSLog(@"提醒时间：%@",date);
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
    content.title = obj.title;
    content.subtitle = obj.subtitle;
    content.body = obj.alertBody;
    content.sound = obj.soundName ? [UNNotificationSound soundNamed:obj.soundName]:[UNNotificationSound defaultSound] ;
    
    
    NSDateComponents * cmp = [self configDateComponentsWithDate:date];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:cmp repeats:fireDate ? YES : NO];
    NSLog(@"ios10提醒时间：%@",trigger);
    NSString *identifer = [self configLocalNotificationIdentiferWithDate:obj.fireDate withWeek:0];
    content.categoryIdentifier=identifer;
    content.userInfo = @{identifer_key:identifer};
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifer content:content trigger:trigger];
    
    
    return request;
    
}
/*删除所有闹钟*/
+(void)cancelAllAlarms{
    
    UIApplication *app = [UIApplication sharedApplication];//本地提醒的列表
    [app cancelAllLocalNotifications];
    
    
}
+ (NSInteger)weekdayWithDate:(NSDate *)date{
    
    NSDateComponents * cmp = [self configWeekDateComponentsWithDate:[NSDate date]];
    
    NSInteger weekday = cmp.weekday ;
    
    return weekday-1 == 0 ? 7 : weekday-1;
}
+ (NSMutableArray *)separatedByString:(NSString *)separatedString byComponentsSeparatedWithString:(NSString *)string{
    
    NSMutableArray  *listItems = [NSMutableArray arrayWithArray:[separatedString componentsSeparatedByString:string]];
    
    if (listItems.count ==1 && [listItems.firstObject isEqualToString:@"" ]) {
        
        [listItems removeAllObjects];
    }
    
    return [NSMutableArray arrayWithArray:listItems];
    
}






+ (NSString *)configLocalNotificationIdentiferWithDate:(NSDate *)date withWeek:(NSInteger )week{
    
    NSDateComponents * cmp = [self configWeekDateComponentsWithDate:date];
    
    // identifer 例 12:12:12 - 2 12点12分12秒星期2 如果不重复 星期为0
    
    return [NSString stringWithFormat:@"%ld:%ld:%ld-%ld",(long)cmp.hour,(long)cmp.minute,(long)cmp.second,(long)week];
    
}
+ (NSDateComponents *)configWeekDateComponentsWithDate:(NSDate *)date{
    NSCalendar * calender = [NSCalendar currentCalendar];
    
    NSDateComponents * cmp = [calender components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitWeekday fromDate:date];
    
    cmp.timeZone = [NSTimeZone localTimeZone];
    return cmp;
}
+ (NSDateComponents *)configDateComponentsWithDate:(NSDate *)date{
    
    NSCalendar * calender = [NSCalendar currentCalendar];
    
    NSDateComponents * cmp = [calender components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitWeekOfYear fromDate:date];
    
    cmp.timeZone = [NSTimeZone localTimeZone];
    
    return cmp;
}
@end
