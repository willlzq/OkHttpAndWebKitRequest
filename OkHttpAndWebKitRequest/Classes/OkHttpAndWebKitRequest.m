//
//  NovelRequestApi.m
//  BQWebSearch
//
//  Created by lzqmac on 2022/8/11.
//

#import "OkHttpAndWebKitRequest.h"
#import "NSData+GZIP.h"
#import <CommonCrypto/CommonDigest.h>
#import "UniversalDetector.h"

@implementation NSData (Encoding)
- (NSString *)ChinaString
{
    // int bodyLength = [self parseHeader:self];//解析数据长度
    unsigned  char *pData =(unsigned  char *)[self bytes];
    int returnLen = 0;
    returnLen = pData[3];
    returnLen = (returnLen<<8)+pData[2];
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//解决中文乱码
    NSData * subData=self;
    if(returnLen<=([self length]-5)){
        subData= [self subdataWithRange:NSMakeRange(5, returnLen)];//读取body
    }
    return   [[NSString alloc] initWithData:subData encoding:strEncode];
    
}
- (NSString *)GBKString
{
    
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//解决中文
    return   [[NSString alloc] initWithData:self encoding:strEncode];
    
}
- (NSString *)GB2312KString
{
    return   [[NSString alloc] initWithData:self encoding: -2147481296];
    
}
//解析信息长度
-(int) parseHeader:(NSData*)data{
    unsigned  char *pData =(unsigned  char *)[data bytes];
    int returnLen = 0;
    returnLen = pData[3];
    returnLen = (returnLen<<8)+pData[2];
    return returnLen;
}

- (NSString *)utf8String {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8Data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

//              https://zh.wikipedia.org/wiki/UTF-8
//              https://www.w3.org/International/questions/qa-forms-utf-8
//
//            $field =~
//                    m/\A(
//            [\x09\x0A\x0D\x20-\x7E]            # ASCII
//            | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
//            |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
//            | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
//            |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
//            |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
//            | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
//            |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
//            )*\z/x;
//- (NSMutableArray<NSData*>*)DataSplit:(NSString*)charTxt{
//
//}
- (NSData *)UTF8Data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;
    
    long dataLength = (long) self.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
        // 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    return resData;
}
@end


@implementation NSURL(Tools)
-(NSString*)UrlDomain{
    NSString *domain=self.host;
    NSArray *segments=[domain componentsSeparatedByString:@"."];
    if ([segments count]>=3) {
        domain=[NSString stringWithFormat:@"%@.%@",[segments objectAtIndex:[segments count]-2],[segments objectAtIndex:[segments count]-1]];
    }
    return domain==nil?@"":domain;
}
@end
@implementation NSString (OkHttpAndWebKitRequestMD5)
- (NSString *)toMD5String
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    NSString *md5string= [NSString stringWithFormat:
                              @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
    ];
    
    return md5string;
}
+(NSString*)loadBundleResource:(NSString*)fileName ofType:(NSString*)ofType{
    NSBundle *bundle = [NSBundle bundleForClass:OkHttpAndWebKitRequest.class];
    NSURL *bundleURL = [bundle URLForResource:@"OkHttpAndWebKitRequest" withExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
    NSString *filePath =  [resourceBundle pathForResource:fileName ofType:ofType];
    NSString*text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return text;
}
@end

@implementation OkHttpAndWebKitRequest
static  AFHTTPSessionManager *sharedmanager;
static  NSString* sharedUserAgent;
static NSMutableDictionary<NSString*,NovelWebKitRequest *>* sharedWebviewDictionary;
static  NSString* sharedFilterHtmlJS;
static  NSString* sharedautoSearchJS;

+(NSURLSessionDataTask *)Request:(NSInteger)page   query:(NSString*)query   htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion{
    return [OkHttpAndWebKitRequest  Request: page   query:query postString:nil WebKitParas:nil  htmlCompletion:htmlCompletion] ;
}
+(NSURLSessionDataTask *)Request:(NSInteger)page    query:(NSString*)query  postString:(NSString*)postString WebKitParas:(NSDictionary*)webKitParas  htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion{
    AFHTTPSessionManager *http=[OkHttpAndWebKitRequest   defualtSessionManager];
    NSString *requestUrl=query;
    webLog(@"requestUrl=%@",requestUrl);
    NSURL *URL  = [NSURL URLWithString:requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    if (postString!=nil) {
        [request setHTTPMethod:@"POST"];
        //  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type" ];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" forHTTPHeaderField:@"Accept" ];
        [request setHTTPBody:[postString  dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [OkHttpAndWebKitRequest  ApplyHttpHeaders:request];
    if(webKitParas && [webKitParas objectForKey:kWebKit_customUserAgent]){
        [request setValue:[webKitParas objectForKey:kWebKit_customUserAgent]  forHTTPHeaderField:@"User-Agent" ];
        
    }
    if(webKitParas && [webKitParas objectForKey:kWebKit_Referer]){
        [request setValue:[webKitParas objectForKey:kWebKit_Referer]  forHTTPHeaderField:@"Referer" ];
    }
    NSURLSessionDataTask *dataTask  =[http dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(htmlCompletion==nil){return ;}
        
        if (error) {
            if (responseObject) {
                NSHTTPURLResponse *rep=(NSHTTPURLResponse *)response;
                NSData *unzipDT=(NSData *)responseObject;
                NSDictionary *headers=rep.allHeaderFields;
                if ( [[headers objectForKey:@"Content-Encoding"]  isEqualToString:@"gzip"] ) {
                    unzipDT= [(NSData*)responseObject gunzippedData];
                }
                NSString *html=nil;
                NSString *contenttype=[[headers objectForKey:@"Content-Type"] lowercaseString] ;
                if ([contenttype containsString:@"utf-8"]){
                    html=[unzipDT utf8String];
                }else if ([contenttype containsString:@"gb2312"] || [contenttype containsString:@"gbk"]){
                    html=[unzipDT GBKString];
                }
                if(html==nil){
                    html=[unzipDT GBKString];
                }
                if(html==nil){
                    html=[unzipDT utf8String];
                }
                NSArray<NSHTTPCookie *> *cookies=  [NSHTTPCookie cookiesWithResponseHeaderFields:rep.allHeaderFields  forURL:response.URL];
                NSHTTPCookieStorage *httpcookie=[NSHTTPCookieStorage sharedHTTPCookieStorage];
                for (NSHTTPCookie *cookie in cookies) {
                    [httpcookie setCookie:cookie];
                }
                NSString *location=nil;
                if (html) {
                    location=[OkHttpAndWebKitRequest  checkWindowLocation:html baseUlr:requestUrl];
                }
                if (location.length>7) {
                    //主动跳转
                    webLog(@"location=%@",location);
                    if (page<=10) {
                        //跳转次数不能大于10次
                        [OkHttpAndWebKitRequest    Request:page+1   query:location htmlCompletion:htmlCompletion];
                    }else{
                        htmlCompletion(requestUrl,(NSHTTPURLResponse*)response,html,error);
                    }
                }else{
                    htmlCompletion(requestUrl,(NSHTTPURLResponse*)response,html,error);
                }
                
            }else{
                htmlCompletion(requestUrl,(NSHTTPURLResponse*)response,nil,error);
            }
            return;
        }else{
            NSHTTPURLResponse *rep=(NSHTTPURLResponse *)response;
            
            NSData *unzipDT=(NSData *)responseObject;
            NSDictionary *headers=rep.allHeaderFields;
            if ( [[headers objectForKey:@"Content-Encoding"]  isEqualToString:@"gzip"] ) {
                unzipDT= [(NSData*)responseObject gunzippedData];
            }
            NSString *html=nil;
            NSString *contenttype=[[headers objectForKey:@"Content-Type"] lowercaseString] ;
            if ([contenttype containsString:@"utf-8"]){
                html=[unzipDT utf8String];
            }else if ([contenttype containsString:@"gb2312"] || [contenttype containsString:@"gbk"]){
                html=[unzipDT GBKString];
                if(html==nil){
                    html=[unzipDT GB2312KString];
                }
            }
            if(html==nil){
                html=[unzipDT GBKString];
            }
            if(html==nil){
                NSStringEncoding enc=NSUTF8StringEncoding;
                @try {
                    CFStringEncodings encode= [UniversalDetector encodingWithData:unzipDT];
                    enc=    CFStringConvertEncodingToNSStringEncoding(encode);
                }
                @catch (NSException *exception) {
                    
                }
                //utf8String
                if(enc==NSUTF8StringEncoding){
                    html =[unzipDT utf8String];
                }else{
                    html = [[NSString alloc] initWithData:unzipDT encoding:enc];
                }
            }
            NSArray<NSHTTPCookie *> *cookies=  [NSHTTPCookie cookiesWithResponseHeaderFields:rep.allHeaderFields  forURL:response.URL];
            NSHTTPCookieStorage *httpcookie=[NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *cookie in cookies) {
                [httpcookie setCookie:cookie];
            }
            htmlCompletion(rep.URL.absoluteString,rep,html,nil);
        }
        
    }];
    [dataTask resume];
    
    return  dataTask;
}
//head请求
+(NSURLSessionDataTask *)HeadRequest:(NSString*)requestUrl htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion{
    AFHTTPSessionManager *http=[OkHttpAndWebKitRequest   defualtSessionManager];
    webLog(@"head requestUrl=%@",requestUrl);
    NSURL *URL  = [NSURL URLWithString:requestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"HEAD";
    
    [OkHttpAndWebKitRequest  ApplyHttpHeaders:request];
    NSURLSessionDataTask *dataTask  =[http dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *rep=(NSHTTPURLResponse *)response;
        htmlCompletion(rep.URL.absoluteString,rep,nil,nil);
    }];
    [dataTask resume];
    
    return  dataTask;
}
+(NSString*)RegexTheFirstMatchValue:(NSRegularExpression*)regex  input:(NSString*)input{
    if (regex==nil || input.length==0) {
        return @"";
    }
    NSTextCheckingResult *firstMatch=[regex firstMatchInString:input  options:NSMatchingReportProgress range:NSMakeRange(0, [input length])];
    return [input substringWithRange:firstMatch.range];
}
+(NSString*)checkWindowLocation:(NSString*)html baseUlr:(NSString*)requestURL{
    NSString* location=  [OkHttpAndWebKitRequest RegexTheFirstMatchValue: [NSRegularExpression regularExpressionWithPattern:@"((self|this|parent|window|)[.]){0,1}location.href(\\s){0,}=(\\s){0,}\"(.)*?\"" options:NSRegularExpressionCaseInsensitive error:nil]   input:html];
    if (location.length>=2 ) {
        NSString* href=  [OkHttpAndWebKitRequest RegexTheFirstMatchValue:[NSRegularExpression regularExpressionWithPattern:@"\"(.)*?\"" options:NSRegularExpressionCaseInsensitive error:nil] input:location];
        href= [[href stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (href.length>1) {
            NSURL *relativeURL=[NSURL URLWithString: requestURL];
            href= [NSURL URLWithString: href relativeToURL:relativeURL].absoluteString;
            return href;
        }
    }
    return nil;
}
+(void)webRequestByURL:(BOOL)isHttpMode requestUrl:(NSString*)requestUrl WebKitParas:(NSDictionary*)webKitParas  htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion cancelBlock:(NetCancelBlock)cancelBlock{
    if (isHttpMode) {
        NSURLSessionDataTask * datatask=  [OkHttpAndWebKitRequest   Request:0   query:requestUrl postString:nil WebKitParas:webKitParas  htmlCompletion:htmlCompletion];
        if (cancelBlock(datatask)) {
            [datatask cancel];
        }
    }else{
        //web浏览器
        webLog(@"使用webkit 获取内容:%@",requestUrl);
        if (sharedWebviewDictionary==nil) {
            sharedWebviewDictionary=[NSMutableDictionary dictionary];
            NSBundle *bundle = [NSBundle bundleForClass:OkHttpAndWebKitRequest.class];
            NSURL *bundleURL = [bundle URLForResource:@"OkHttpAndWebKitRequest" withExtension:@"bundle"];
            NSBundle *resourceBundle = [NSBundle bundleWithURL: bundleURL];
            NSString *filePath =  [resourceBundle pathForResource:@"removeNoDisplayHtml" ofType:@"js"];
            sharedFilterHtmlJS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NovelWebKitRequest *webKitObj=nil;
            NSString *webkey=requestUrl.toMD5String;
            if (![sharedWebviewDictionary objectForKey:webkey]) {
                webKitObj=[NovelWebKitRequest new];
                [sharedWebviewDictionary setObject:webKitObj forKey:webkey];
                webKitObj.htmlCompletion =htmlCompletion;
                webKitObj.webKitParas =webKitParas;
                [webKitObj requestWeb: requestUrl endHandler:^(BOOL isend) {
                    //用完即清除对象
                    [[sharedWebviewDictionary objectForKey:webkey] cancel];
                    [sharedWebviewDictionary removeObjectForKey:webkey];
                }];
                if (cancelBlock(webKitObj)) {
                    [webKitObj cancel];
                    [sharedWebviewDictionary removeObjectForKey:webkey];
                }
            }else{
                //已经存在
                webKitObj=[sharedWebviewDictionary objectForKey:webkey];
                [webKitObj  evaluateHtml:htmlCompletion];
                return;
            }
            
        });
        
    }
}

+(void)ApplyHttpHeaders:(NSMutableURLRequest *)request{
    request.timeoutInterval=120;
    [request setValue:[OkHttpAndWebKitRequest  CurrentUserAgent]  forHTTPHeaderField:@"User-Agent" ];
    [request setValue:@"gzip, deflate, sdch" forHTTPHeaderField:@"Accept-Encoding" ];
    [request setValue:@"zh-CN,zh;q=0.8" forHTTPHeaderField:@"Accept-Language" ];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" forHTTPHeaderField:@"Accept" ];
    //    NSString *key=[NSString stringWithFormat:@"%@://%@",request.URL.scheme,request.URL.host];
    //    [request setValue: key forHTTPHeaderField:@"Referer"];
    [request setHTTPShouldHandleCookies:YES];
    @synchronized (sharedUserAgent) {
        if (request.URL) {
            NSArray<NSHTTPCookie *> *cookies=[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL ];
            NSMutableString *cookiestr=[NSMutableString string];
            for (NSHTTPCookie *cookie in cookies) {
                //   webLog(@"%@-->cookie:%@=%@",cookie.domain,[cookie name], [cookie value]);
                [cookiestr appendFormat:@"%@=%@;", [cookie name], [cookie value]];
            }
            if (cookiestr.length>0) {
                [request setValue:cookiestr forHTTPHeaderField:@"Cookie"];
            }
        }
    }
}
+(AFHTTPSessionManager *)defualtSessionManager{
    static dispatch_once_t onceSogouDataPredicate;
    dispatch_once(&onceSogouDataPredicate, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies =YES;
        configuration.HTTPShouldUsePipelining = NO;
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        configuration.allowsCellularAccess = YES;
        configuration.timeoutIntervalForRequest = 120.0;
        sharedmanager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        AFHTTPResponseSerializer *Serializer=[AFHTTPResponseSerializer serializer];
        Serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",@"application/octet-stream",@"application/x-gzip",@"application/zip", @"audio/wav" ,@"audio/mp3",@"audio/x-mpegurl",@"application/x-rar-compressed", @"*.*",nil];
        
        sharedmanager.responseSerializer = Serializer;
        sharedmanager.securityPolicy.allowInvalidCertificates = YES;
        [sharedmanager.securityPolicy setValidatesDomainName:NO];
        [sharedmanager setCompletionQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    });
    return sharedmanager;
}
+(NSString*)CurrentUserAgent{
    static dispatch_once_t onceSogouDataPredicate;
    dispatch_once(&onceSogouDataPredicate, ^{
        NSArray *users=[OkHttpAndWebKitRequest  UserAgentList];
        sharedUserAgent=[users objectAtIndex:arc4random_uniform(users.count-1)];
    });
    return sharedUserAgent;
}
+ (NSArray<NSString*>*)UserAgentList{
    return @[
        @"Mozilla/5.0 (Macintosh; Intel Mac OS X 13_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36",
        @"Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.4896.60 Safari/537.36 Edg/100.0.1185.29",
        @"Mozilla/5.0 (Windows NT 11.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36 SLBrowser/8.0.0.2242 SLBChan/105",
        @"Mozilla/5.0 (Windows NT 11.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36 OPR/85.0.4341.60"
    ];
}

@end
static  WKContentRuleList* sharedWKContentRuleList;
@implementation WKWebView (ContentRule)

-(void)addNoImageContentRule{
    WKUserContentController *userContentController=self.configuration.userContentController;
    if(sharedWKContentRuleList==nil){
        NSString*jsonStr = [NSString loadBundleResource:@"WebKitNoImageAndMedia" ofType:@"json"];
        [[WKContentRuleListStore defaultStore] compileContentRuleListForIdentifier:@"__WKWebView__NoNoImageAndMediaContentRule__" encodedContentRuleList: jsonStr completionHandler:^(WKContentRuleList *contentRuleList, NSError *error) {
            if (error==nil){
                sharedWKContentRuleList=contentRuleList;
                [userContentController addContentRuleList:sharedWKContentRuleList];
                webLog(@"启动无图模式成功-->%@",contentRuleList);
            }else{
                webLog(@"启动无图模式失败-->%@",error);
            }
        }];
    }else{
        [userContentController addContentRuleList:sharedWKContentRuleList];
        webLog(@"启动无图模式成功");
    }
}
-(void)AddAutoClickUserScript{
    WKUserContentController *userContentController=self.configuration.userContentController;
    NSString*jsStr = [NSString loadBundleResource:@"clickPageListMulu" ofType:@"js"];
    WKUserScript *clickHiddenAllMuluScript = [[WKUserScript alloc] initWithSource:jsStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:clickHiddenAllMuluScript];
    webLog(@"启动隐藏目录自动点击成功");
}
@end
@interface NovelWebKitRequest ()<WKNavigationDelegate>
@property (nonatomic, strong) WKNavigationResponse * navigationResponse;
@property(nonatomic,copy)  webkit_End_Completion endHandler ;
@property (nonatomic, strong)  WKWebView *webview;
@property (nonatomic, assign)  bool isEnd;
@property (nonatomic, assign)  bool isHomeUrl;
@end
@implementation NovelWebKitRequest
-(void)requestWeb:(NSString*)url endHandler:(webkit_End_Completion)endHandler{
    self.isEnd=NO;
    self.webview=[WKWebView  new];
    [self.webview addNoImageContentRule];
    if([self ValueByWebKitParas:kWebKit_isAutoClickMulu]){
        [self.webview AddAutoClickUserScript];
    }
    if(self.webKitParas && [self.webKitParas objectForKey:kWebKit_customUserAgent]){
        self.customUserAgent=[self.webKitParas objectForKey:kWebKit_customUserAgent];
    }
    if(self.webKitParas && [self.webKitParas objectForKey:kWebKit_Referer]){
        self.referer=[self.webKitParas objectForKey:kWebKit_Referer];
    }
    
    self.endHandler=endHandler;
    self.webview.navigationDelegate=self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (  (int)[window.subviews indexOfObject:self.webview]<0) {
        self.webview.bounds= CGRectMake([UIApplication sharedApplication].keyWindow.bounds.size.width*2.25, [UIApplication sharedApplication].keyWindow.bounds.size.height*2.25, window.bounds.size.width, window.bounds.size.height) ;
        self.webview.hidden=YES;
        [window addSubview:self.webview];
        [window sendSubviewToBack: self.webview];
    }
    self.webview.customUserAgent=self.customUserAgent.length>0?self.customUserAgent:[OkHttpAndWebKitRequest  CurrentUserAgent];
    NSMutableURLRequest *webrequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [OkHttpAndWebKitRequest  ApplyHttpHeaders:webrequest];
    if(self.referer.length>0){
        [webrequest setValue: self.referer forHTTPHeaderField:@"Referer"];
    }
    self.isHomeUrl=((webrequest.URL.path.length==0 ||[webrequest.URL.path isEqualToString:@"/"] ) && webrequest.URL.query.length==0);
    [self.webview loadRequest: webrequest];
}
-(BOOL)ValueByWebKitParas:(NSString*)key{
    if(self.webKitParas && [[self.webKitParas objectForKey:key] boolValue]){
        return YES;
    }
    return NO;
}
#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    webLog(@"didStartProvisionalNavigation=%@",webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    webLog(@"didCommitNavigation=%@",webView.title);
    if (self.htmlCompletion==nil || self.isEnd) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(SendHtml) object:nil];
    if([self ValueByWebKitParas:kWebKitRequest_amplifyAfterDelayTime]){
        [self performSelector:@selector(SendHtml) withObject:nil afterDelay:20];
    }else{
        [self performSelector:@selector(SendHtml) withObject:nil afterDelay:15];
    }
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    webLog(@"didFinishNavigation=%@ isLoading=%@",webView.title,webView.isLoading?@"YES":@"NO");
    if (self.htmlCompletion==nil || self.isEnd) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if([self ValueByWebKitParas:kWebKitRequest_amplifyAfterDelayTime]){
        [self performSelector:@selector(SendHtml) withObject:nil afterDelay:6.0];
    }else{
        [self performSelector:@selector(SendHtml) withObject:nil afterDelay:4.0];
    }
}
-(NSString*)evaluateHtmlJS{
    NSMutableString *jsCode=[NSMutableString string];
    if([self ValueByWebKitParas:kWebKit_isLinkOnclickToHref]){
        NSString*jsStr = [NSString loadBundleResource:@"onclickToHref" ofType:@"js"];
        [jsCode appendString: jsStr];
        [jsCode appendString: @";\r\n"];
    }
    [jsCode appendString:[self ValueByWebKitParas:kWebKit_ProhibitFilterHtml]?@"document.getElementsByTagName('html')[0].outerHTML;":sharedFilterHtmlJS];
    return jsCode;
}
-(void)SendHtml{
    webLog(@"evaluateJavaScript--SendHtml >:%@",self.webview.URL);
    __weak __typeof(self) weakSelf = self;
    NSString *url=self.webview.URL.absoluteString;
    [self.webview evaluateJavaScript: self.isHomeUrl?@"document.getElementsByTagName('html')[0].outerHTML;":self.evaluateHtmlJS  completionHandler:^(id _Nullable innerHTML, NSError * _Nullable innererror) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf.htmlCompletion) {
                if ( weakSelf.isEnd) {
                    return;
                }
                weakSelf.htmlCompletion(url,(NSHTTPURLResponse*)weakSelf.navigationResponse.response,innerHTML,innererror);
                weakSelf.htmlCompletion = nil;
            }
            if (weakSelf.isEnd) {
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.isEnd=YES;
                if (weakSelf.endHandler) {
                    weakSelf.endHandler(YES);
                }
                
            });
        });
        
    }];
}
-(void)evaluateHtml:(HtmlDataCompleteHandler)completionHandler{
    __weak __typeof(self) weakSelf = self;
    NSString *url=self.webview.URL.absoluteString;
    [self.webview evaluateJavaScript:self.isHomeUrl?@"document.getElementsByTagName('html')[0].outerHTML;":self.evaluateHtmlJS    completionHandler:^(id _Nullable innerHTML, NSError * _Nullable innererror) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (completionHandler) {
                completionHandler(url,(NSHTTPURLResponse*)weakSelf.navigationResponse.response,innerHTML,innererror);
            }
        });
        
    }];
}
/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    webLog(@"didFailProvisionalNavigation=%@",error);
    if (self.htmlCompletion) {
        self.htmlCompletion(webView.URL.absoluteString,(NSHTTPURLResponse*)self.navigationResponse.response,@"",error);
        self.htmlCompletion = nil;
        self.isEnd=YES;
    }
    if (self.endHandler) {
        self.endHandler(YES);
    }
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    webLog(@"didReceiveServerRedirectForProvisionalNavigation %@", webView.URL);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    webLog(@"decidePolicyForNavigationResponse %@ forMainFrame=%d",navigationResponse.response.URL, navigationResponse.forMainFrame);
    self.navigationResponse=navigationResponse;
    NSInteger statusCode= ((NSHTTPURLResponse *)navigationResponse.response).statusCode;
    if (statusCode >=400 && [navigationResponse.response.URL.host isEqualToString:webView.URL.host]) {
        decisionHandler(WKNavigationResponsePolicyCancel);
        if (self.htmlCompletion) {
            self.htmlCompletion(webView.URL.absoluteString,(NSHTTPURLResponse*)self.navigationResponse.response,@"",[NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode  userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%ld - 找不到文件或目录或者服务器出现错误",(long)statusCode]}]);
            self.htmlCompletion = nil;
            self.isEnd=YES;
        }
        if (self.endHandler) {
            self.endHandler(YES);
        }
    }else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ((navigationAction.navigationType==WKNavigationTypeOther|| navigationAction.navigationType==WKNavigationTypeLinkActivated) && [navigationAction.request.URL.scheme.lowercaseString hasPrefix:@"http"] && ![webView.URL.UrlDomain isEqualToString: navigationAction.request.URL.UrlDomain]) {
        webLog(@"禁止跳转地址=%@ 当前地址:%@ navigationAction.navigationType=%ld navigationAction.targetFrame.isMainFrame=%d",navigationAction.request,webView.URL,(long)navigationAction.navigationType,navigationAction.targetFrame.isMainFrame);
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)){
    webLog(@"navigationAction.request=%@  navigationAction.navigationType=%ld navigationAction.targetFrame.isMainFrame=%d",navigationAction.request,(long)navigationAction.navigationType,navigationAction.targetFrame.isMainFrame);
    preferences.preferredContentMode=WKContentModeDesktop;
    decisionHandler(WKNavigationActionPolicyAllow,preferences);
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    });
}
-(void)clear{
    if(self.webview==nil){
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.webview.configuration.userContentController removeAllUserScripts];
    [self.webview.configuration.userContentController removeAllContentRuleLists];
    self.htmlCompletion = nil;
    if (!self.isEnd) {
        self.isEnd=YES;
        self.endHandler(YES);
    }
    self.endHandler  = nil;
    [self.webview stopLoading];
    [self.webview removeFromSuperview];
    self.webview=nil;
}
-(void)cancel{
    if (NSThread.isMainThread) {
        [self clear];
    }else{
        __block bool isWaitForEnd=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clear];
            isWaitForEnd=YES;
        });
        while (!isWaitForEnd) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}
-(void)dealloc{
    webLog(@"OkHttpAndWebKitRequest dealloc");
}
@end



@interface AutoSubmitSearchByWebKit ()<WKNavigationDelegate>
@property (nonatomic, strong) WKNavigationResponse * navigationResponse;
@property (nonatomic, strong)  WKWebView *webview;
@property (nonatomic, assign)  bool isHomeEnd;
@property (nonatomic, assign)  bool isRedirectEnd;
@property (nonatomic, strong)  NSURL *requestUrl;

@end
@implementation AutoSubmitSearchByWebKit

-(void)request:(NSString*)url{
    self.isHomeEnd=NO;
    self.isRedirectEnd=NO;
    self.webview=[WKWebView  new];
    [self.webview addNoImageContentRule];
    self.webview.navigationDelegate=self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ((int)[window.subviews indexOfObject:self.webview]<0) {
        self.webview.bounds= CGRectMake([UIApplication sharedApplication].keyWindow.bounds.size.width*2.25, [UIApplication sharedApplication].keyWindow.bounds.size.height*2.25, window.bounds.size.width, window.bounds.size.height) ;
        self.webview.hidden=YES;
        
        [window addSubview:self.webview];
        [window sendSubviewToBack: self.webview];
        self.webview.customUserAgent=[OkHttpAndWebKitRequest  CurrentUserAgent];
        
    }
    self.requestUrl=[NSURL URLWithString:url];
    
    NSMutableURLRequest *webrequest=[NSMutableURLRequest requestWithURL:self.requestUrl cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [OkHttpAndWebKitRequest ApplyHttpHeaders:webrequest];
    [self.webview loadRequest: webrequest];
}
#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    webLog(@"didStartProvisionalNavigation=%@",webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    if (self.isHomeEnd) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(SendHtml) object:nil];
    [self performSelector:@selector(SendHtml) withObject:nil afterDelay:7];
}
/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.isHomeEnd) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(SendHtml) withObject:nil afterDelay:1.0];
    
    
}
-(void)SendHtml{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isHomeEnd=YES;
    if (sharedautoSearchJS==nil) {
        sharedautoSearchJS = [NSString loadBundleResource:@"autoSubmitSearch" ofType:@"js"];
    }
    [self.webview evaluateJavaScript:sharedautoSearchJS  completionHandler:^(id _Nullable innerHTML, NSError * _Nullable innererror) {
    }];
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    webLog(@"didFailProvisionalNavigation=%@",error);
    if(self.redirectCompletion){
        self.redirectCompletion(webView.URL.absoluteString,(NSHTTPURLResponse*)self.navigationResponse.response,error);
        self.redirectCompletion = nil;
    }
    self.isHomeEnd=YES;
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    webLog(@"didReceiveServerRedirectForProvisionalNavigation %@", webView.URL);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    webLog(@"decidePolicyForNavigationResponse %@ forMainFrame=%d",navigationResponse.response.URL, navigationResponse.forMainFrame);
    self.navigationResponse=navigationResponse;
    NSInteger statusCode= ((NSHTTPURLResponse *)navigationResponse.response).statusCode;
    if (statusCode >=400 && [navigationResponse.response.URL.host isEqualToString:webView.URL.host]) {
        decisionHandler(WKNavigationResponsePolicyCancel);
        if(self.redirectCompletion){
            self.redirectCompletion(webView.URL.absoluteString,(NSHTTPURLResponse*)self.navigationResponse.response,[NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode  userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%ld - 找不到文件或目录或者服务器出现错误",(long)statusCode]}]);
            self.redirectCompletion = nil;
        }
        self.isHomeEnd=YES;
        
    }else {
        BOOL isHomeUrl=((navigationResponse.response.URL.path.length==0 ||[navigationResponse.response.URL.path isEqualToString:@"/"] ) && navigationResponse.response.URL.query.length==0);
        if(isHomeUrl && [navigationResponse.response.URL.host isEqualToString:self.requestUrl.host]){
            decisionHandler(WKNavigationResponsePolicyAllow);
            return;
        }else  if(!isHomeUrl && self.isHomeEnd  && !self.isRedirectEnd  && [navigationResponse.response.URL.absoluteString containsString:self.requestUrl.host]){
            //发生了站内跳转
            self.isRedirectEnd=YES;
            if(self.redirectCompletion){
                self.redirectCompletion(navigationResponse.response.URL.absoluteString,(NSHTTPURLResponse*)self.navigationResponse.response,nil);
            }
        }
        decisionHandler(WKNavigationResponsePolicyCancel);
        
    }
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    });
}
/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ((navigationAction.navigationType==WKNavigationTypeOther|| navigationAction.navigationType==WKNavigationTypeLinkActivated) && [navigationAction.request.URL.scheme.lowercaseString hasPrefix:@"http"] && ![webView.URL.UrlDomain isEqualToString: navigationAction.request.URL.UrlDomain]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)){
    webLog(@"navigationAction.request=%@  navigationAction.navigationType=%ld navigationAction.targetFrame.isMainFrame=%d",navigationAction.request,(long)navigationAction.navigationType,navigationAction.targetFrame.isMainFrame);
    preferences.preferredContentMode=WKContentModeDesktop;
    decisionHandler(WKNavigationActionPolicyAllow,preferences);
}
-(void)clear{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.webview.configuration.userContentController removeAllUserScripts];
    [self.webview.configuration.userContentController removeAllContentRuleLists];
    self.redirectCompletion = nil;
    [self.webview stopLoading];
    [self.webview removeFromSuperview];
}
-(void)cancel{
    if (NSThread.isMainThread) {
        [self clear];
    }else{
        __block bool isWaitForEnd=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clear];
            isWaitForEnd=YES;
        });
        while (!isWaitForEnd) {
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}

@end
