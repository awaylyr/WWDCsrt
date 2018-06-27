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
@property (nonatomic, copy) NSArray *rawSubtitleArray;           // 包含时间信息
@property (nonatomic, strong) NSMutableArray *enSubtitleArray;
@property (nonatomic, strong) NSMutableArray *zhSubtitleArray;


@property (nonatomic, assign) NSInteger currentIndex; // 标记当前已经完成翻译的句子索引
@property (nonatomic, copy) void (^completionHander)(NSString *, NSString *);


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

- (void)exportTranscriptWithRawSubtitleArray:(NSArray *)subtitleArray translateToZH:(BOOL)isTranslateToZH completionHandler:(void (^)(NSString *str1, NSString *str2))completionHandler {
    _enTranscriptArray = [NSMutableArray array];
    _zhTranscriptArray = [NSMutableArray array];
    _enSubtitleArray = [NSMutableArray array];
    _zhSubtitleArray = [NSMutableArray array];
    _currentIndex = 0;

    [self removeTimeInfo:subtitleArray];
    // 开始翻译
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    self.completionHander = completionHandler;
    NSLog(@"start transcript File Translate Task");
    [self startTranscriptTranslateTaskWithSession:session];
}

- (void)startTranscriptTranslateTaskWithSession:(NSURLSession *)session {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://translation.googleapis.com/language/translate/v2"]];
    request.HTTPMethod = @"POST";
    NSString *body = [self generateGoogleTranslateAPIParamsWithData:self.enTranscriptArray];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"TranscriptTranslate:%@", @(self.currentIndex));
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
                                                            [self startTranscriptTranslateTaskWithSession:session];
                                                        } else {
                                                            NSLog(@"start Subtitl File Translate Task");
                                                            self.currentIndex = 0;
                                                            [self startSubtitlFileTranslateTaskWithSession:session];
                                                        }
                                                    } else {
                                                        // 如果一个地方出错，就停止文章翻译，开始翻译字幕文件
                                                        NSLog(@"start Subtitl File Translate Task");
                                                        self.currentIndex = 0;
                                                        [self startSubtitlFileTranslateTaskWithSession:session];
                                                    }
                                                } else {
                                                    // 如果一个地方出错，就停止文章翻译，开始翻译字幕文件
                                                    NSLog(@"start Subtitl File Translate Task");
                                                    self.currentIndex = 0;
                                                    [self startSubtitlFileTranslateTaskWithSession:session];
                                                }

                                            }];
    [dataTask resume];
}

- (void)startSubtitlFileTranslateTaskWithSession:(NSURLSession *)session {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://translation.googleapis.com/language/translate/v2"]];
    request.HTTPMethod = @"POST";
    NSString *body = [self generateGoogleTranslateAPIParamsWithData:self.enSubtitleArray];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"SubtitlFileTranslate:%@", @(self.currentIndex));
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                if (error == nil) {
                                                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                                    if (error == nil && [dic valueForKeyPath:@"error"] == nil) {
                                                        NSArray *translateResult = [dic valueForKeyPath:@"data.translations"];
                                                        for (NSDictionary *dic in translateResult) {
                                                            NSString *result = dic[@"translatedText"];
                                                            [self.zhSubtitleArray addObject:result ?: @""];
                                                        }
                                                        if (self.currentIndex < self.enSubtitleArray.count) {
                                                            [self startSubtitlFileTranslateTaskWithSession:session];
                                                        } else {
                                                            NSLog(@"generte transcript and subtitle");
                                                            NSString *transcript = [self generateEnAndZhTranscript];
                                                            NSString *subTitle = [self generateEnAndZhSubtitle];
                                                            self.completionHander(transcript, subTitle);
                                                        }
                                                    } else {
                                                        NSLog(@"generte transcript and subtitle");
                                                        NSString *transcript = [self generateEnAndZhTranscript];
                                                        NSString *subTitle = [self generateEnAndZhSubtitle];
                                                        self.completionHander(transcript, subTitle);
                                                    }
                                                } else {
                                                    NSLog(@"generte transcript and subtitle");
                                                    NSString *transcript = [self generateEnAndZhTranscript];
                                                    NSString *subTitle = [self generateEnAndZhSubtitle];
                                                    self.completionHander(transcript, subTitle);
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

- (NSString *)generateEnAndZhSubtitle {
    NSMutableString *transcript = [NSMutableString string];
    int endIndex = 0;
    for (int i = 0; i < self.rawSubtitleArray.count && i < self.zhSubtitleArray.count; i++) {
        endIndex = i;
        [transcript appendFormat:@"%@\n%@\n%@\n\n\n", @(i + 1), self.rawSubtitleArray[i], self.zhSubtitleArray[i]];
    }
    endIndex++;
    if (endIndex >= self.rawSubtitleArray.count) {
        return [transcript copy];
    }
    for (int i = endIndex; i < self.rawSubtitleArray.count; i++) {
        [transcript appendFormat:@"%@\n%@\n\n\n", @(i + 1), self.rawSubtitleArray[i]];
    }
    return [transcript copy];
}

- (NSString *)generateGoogleTranslateAPIParamsWithData:(NSArray *)dataArray {
    // q参数
    NSMutableString *body = [NSMutableString string];
    NSUInteger endIndex = self.currentIndex + 50 < dataArray.count ? self.currentIndex + 50 : dataArray.count;
    for (NSUInteger i = self.currentIndex; i < endIndex; i++) {
        NSString *str = dataArray[i];
        [body appendFormat:@"q=%@&", str ?: @""];
    }
    self.currentIndex = endIndex;
    // target、key
    [body appendFormat:@"target=zh-CN&key=AIzaSyDFUJ3ow6Cs4iPxmRjmSaUXJ0cpnPMOEY4"];
    return [body copy];
}

- (void)removeTimeInfo:(NSArray *)array {
    _rawSubtitleArray = array;
    NSMutableString *currentSentence = [NSMutableString string];
    [array enumerateObjectsUsingBlock:^(NSString *rawStr, NSUInteger idx, BOOL *_Nonnull stop) {
        // 过滤掉字幕时间轴信息
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*-->\\s*([0-9]{2}:){2}[0-9]{2},[0-9]*\\s*" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        NSString *finalStr = [regular stringByReplacingMatchesInString:rawStr options:NSMatchingReportCompletion range:NSMakeRange(0, rawStr.length) withTemplate:@""];
        // 没有拼接成句子
        [self.enSubtitleArray addObject:finalStr];
        // 短语拼接成句子
        [currentSentence appendFormat:@"%@ ", finalStr];
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
