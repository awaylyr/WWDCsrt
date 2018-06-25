//
//  SubtitleOCClass.m
//  WWDC.srt
//
//  Created by ponyo on 2018/6/25.
//  Copyright © 2018年 Seyed Samad Gholamzadeh. All rights reserved.
//

#import "SubtitleOCClass.h"

@implementation SubtitleOCClass

+ (NSString *)exportTranscript:(NSArray *)array {
    NSMutableString *transcript = [NSMutableString string];
    [array enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:NSString.class]) {
            NSString *rawStr = obj;
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*-->\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
            NSString *finalStr = [regular stringByReplacingMatchesInString:rawStr options:NSMatchingReportCompletion range:NSMakeRange(0, rawStr.length) withTemplate:@" "];
            [transcript appendString:finalStr];
            if ([finalStr hasSuffix:@"."]) {
                [transcript appendString:@"\n\n"];
            }
        }
    }];
    return [transcript copy];
}

@end
