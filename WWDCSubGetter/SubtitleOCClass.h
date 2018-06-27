//
//  SubtitleOCClass.h
//  WWDC.srt
//
//  Created by ponyo on 2018/6/25.
//  Copyright © 2018年 Seyed Samad Gholamzadeh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SubtitleOCClass : NSObject
+ (instancetype)shareInstance;
// 导出中英抄本 和 中英字幕
- (void)exportTranscriptWithRawSubtitleArray:(NSArray *)subtitleArray translateToZH:(BOOL)isTranslateToZH completionHandler:(void (^)(NSString *str1, NSString *str2))completionHandler;

@end
