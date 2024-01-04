//
//  OkHttpAndWebKitRequest.h
//
//  Created by lzqmac on 2022/8/11.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <WebKit/WebKit.h>
#ifdef DEBUG
#define webLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define webLog(...)
#endif
#define kWebKit_isAutoClickMulu @"__isAutoClickMulu__"
#define kWebKit_customUserAgent @"__customUserAgent__"
#define kWebKit_Referer @"__Referer__"

#define kWebKit_isLinkOnclickToHref @"__isLinkOnclickToHref__"
#define kWebKit_ProhibitFilterHtml @"__ProhibitFilterHtml__"
#define kWebKitRequest_amplifyAfterDelayTime @"amplifyAfterDelayTime"

typedef void (^HtmlDataCompleteHandler)(NSString* url,NSHTTPURLResponse *httpResponse, id  jsonDocument, NSError *error);
typedef BOOL(^NetCancelBlock)(id obj);
typedef void (^FetchSubmitUrlCompletionHandler)(NSString* redirectUrl,NSHTTPURLResponse *httpResponse,  NSError *error);

NS_ASSUME_NONNULL_BEGIN
@interface NSData (Encoding)
- (NSString *)utf8String;
- (NSString *)ChinaString;
- (NSString *)GBKString;
- (NSString *)GB2312KString;
- (NSData *)UTF8Data;
@end
@interface NSURL (Tools)
    //URL 根域名
-(NSString*)UrlDomain;
@end
@interface NSString (OkHttpAndWebKitRequestMD5)
- (NSString *)toMD5String;
+(NSString*)loadBundleResource:(NSString*)fileName ofType:(NSString*)ofType;
@end
@interface NSString (OkHttpAndWebKitRequestMD5)
@end
@interface OkHttpAndWebKitRequest : NSObject
+(NSURLSessionDataTask *)Request:(NSInteger)page     query:(NSString*)query htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;
+(NSURLSessionDataTask *)Request:(NSInteger)page     query:(NSString*)query  postString:(NSString*)postString WebKitParas:(NSDictionary*)webKitParas  htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;
+(NSURLSessionDataTask *)HeadRequest:(NSString*)requestUrl htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;
+(void)webRequestByURL:(BOOL)isHttpMode requestUrl:(NSString*)requestUrl WebKitParas:(NSDictionary*)webKitParas  htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion cancelBlock:(NetCancelBlock)cancelBlock;
+(void)ApplyHttpHeaders:(NSMutableURLRequest *)request;
+(AFHTTPSessionManager *)defualtSessionManager;
+(NSString*)CurrentUserAgent;
@end
typedef void (^webkit_End_Completion)(BOOL isend);
@interface WKWebView (ContentRule)
-(void)addNoImageContentRule;
-(void)AddAutoClickUserScript;
@end
@interface NovelWebKitRequest : NSObject
@property(nonatomic,copy) HtmlDataCompleteHandler _Nullable htmlCompletion;
@property(nonatomic,strong) NSString * _Nullable customUserAgent;
@property(nonatomic,strong) NSString * _Nullable referer;
@property(nonatomic,strong) NSDictionary * _Nullable webKitParas;

-(void)requestWeb:(NSString*)url endHandler:(webkit_End_Completion)endHandler;
-(void)evaluateHtml:(HtmlDataCompleteHandler)completionHandler;
-(void)cancel;
@end
//自动提交搜索，并返回搜索地址
@interface AutoSubmitSearchByWebKit : NSObject
@property(nonatomic,copy) FetchSubmitUrlCompletionHandler redirectCompletion;
-(void)request:(NSString*)url;
-(void)cancel;
@end
NS_ASSUME_NONNULL_END
