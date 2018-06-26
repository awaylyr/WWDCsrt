//
//  SubtitleOCClass.m
//  WWDC.srt
//
//  Created by ponyo on 2018/6/25.
//  Copyright © 2018年 Seyed Samad Gholamzadeh. All rights reserved.
//

#import "SubtitleOCClass.h"

@interface SubtitleOCClass ()

@property (nonatomic, strong) NSMutableArray *enTranscriptArray; // 英文抄本
@property (nonatomic, strong) NSMutableArray *zhTranscriptArray; // 中文抄本
@property (nonatomic, assign) NSInteger currentIndex;            // 标记当前已经完成翻译的句子索引
@property (nonatomic, copy) void (^completionHander)(NSString *);


@end

@implementation SubtitleOCClass

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static SubtitleOCClass *single = nil;
    dispatch_once(&onceToken, ^{
        single = [[SubtitleOCClass alloc] init];
    });
    return single;
}

- (instancetype)init {
    if (self = [super init]) {
        _enTranscriptArray = [NSMutableArray array];
        _zhTranscriptArray = [NSMutableArray array];
        _currentIndex = 0;
    }
    return self;
}

- (void)exportTranscriptWithRawSubtitleArray:(NSArray *)subtitleArray translateToZH:(BOOL)isTranslateToZH completionHandler:(void (^)(NSString *transcript))completionHandler {
    _enTranscriptArray = [NSMutableArray array];
    _zhTranscriptArray = [NSMutableArray array];
    _currentIndex = 0;

    [self generateEnTranscript:subtitleArray];
    // 开始翻译
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    self.completionHander = completionHandler;
    [self startSessionTaskWithSession:session];
}

- (void)startSessionTaskWithSession:(NSURLSession *)session {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://translation.googleapis.com/language/translate/v2"]];
    request.HTTPMethod = @"POST";
    NSString *body = [self generateGoogleTranslateAPIParams];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                if (error == nil) {
                                                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                                    if (error == nil && [dic valueForKeyPath:@"error"] == nil) {
                                                        // 保存翻译数据
                                                        NSArray *translateResult = [dic valueForKeyPath:@"data.translations"];
                                                        for (NSDictionary *dic in translateResult) {
                                                            NSString *result = dic[@"translatedText"];
                                                            [self.zhTranscriptArray addObject:result ?: @""];
                                                        }
                                                        if (self.currentIndex < self.enTranscriptArray.count) {
                                                            [self startSessionTaskWithSession:session];
                                                        } else {
                                                            NSString *transcript = [self generateEnAndZhTranscript];
                                                            self.completionHander(transcript);
                                                        }
                                                    } else {
                                                        // 如果一个地方出错，就停止翻译，触发回调
                                                        NSString *transcript = [self generateEnAndZhTranscript];
                                                        self.completionHander(transcript);
                                                    }
                                                } else {
                                                    // 如果一个地方出错，就停止翻译，触发回调
                                                    NSString *transcript = [self generateEnAndZhTranscript];
                                                    self.completionHander(transcript);
                                                }

                                            }];
    [dataTask resume];
}

- (NSString *)generateEnAndZhTranscript {
    NSMutableString *transcript = [NSMutableString string];
    int endIndex = 0;
    for (int i = 0; i < self.zhTranscriptArray.count && i < self.enTranscriptArray.count; i++) {
        endIndex = i;
        [transcript appendFormat:@"%@\n%@\n\n", self.enTranscriptArray[i], self.zhTranscriptArray[i]];
    }
    endIndex++;
    if (endIndex >= self.enTranscriptArray.count) {
        return [transcript copy];
    }
    for (int i = endIndex; i < self.enTranscriptArray.count; i++) {
        [transcript appendFormat:@"%@\n\n", self.enTranscriptArray[i]];
    }
    return [transcript copy];
}

- (NSString *)generateGoogleTranslateAPIParams {
    // q参数
    NSMutableString *body = [NSMutableString string];
    NSUInteger endIndex = self.currentIndex + 50 < self.enTranscriptArray.count ? self.currentIndex + 50 : self.enTranscriptArray.count;
    for (NSUInteger i = self.currentIndex; i < endIndex; i++) {
        NSString *str = self.enTranscriptArray[i];
        [body appendFormat:@"q=%@&", str ?: @""];
    }
    self.currentIndex = endIndex;
    // target、key
    [body appendFormat:@"target=zh-CN&key=AIzaSyDFUJ3ow6Cs4iPxmRjmSaUXJ0cpnPMOEY4"];
    return [body copy];
}

- (void)generateEnTranscript:(NSArray *)array {
    NSMutableString *currentSentence = [NSMutableString string];
    [array enumerateObjectsUsingBlock:^(NSString *rawStr, NSUInteger idx, BOOL *_Nonnull stop) {
        // 过滤掉字幕时间轴信息
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*-->\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        NSString *finalStr = [regular stringByReplacingMatchesInString:rawStr options:NSMatchingReportCompletion range:NSMakeRange(0, rawStr.length) withTemplate:@" "];
        // 短语拼接成句子
        [currentSentence appendString:finalStr];
        if ([finalStr hasSuffix:@"."]) {
            // 按句子来排版
            [self.enTranscriptArray addObject:[currentSentence copy]];
            [currentSentence setString:@""];
        }
    }];
    // 可能最后的部分丢失了句号
    if (currentSentence.length > 0) {
        [self.enTranscriptArray addObject:[currentSentence copy]];
        [currentSentence setString:@""];
    }
}


@end
