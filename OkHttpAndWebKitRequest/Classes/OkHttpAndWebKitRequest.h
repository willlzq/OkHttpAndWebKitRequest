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

typedef void (^HtmlDataCompleteHandler)(NSString* url,NSHTTPURLResponse *httpResponse, id  jsonDocument, NSError *error);
typedef BOOL(^NetCancelBlock)(id obj);
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
@end
@interface OkHttpAndWebKitRequest : NSObject
+(NSURLSessionDataTask *)Request:(NSInteger)page     query:(NSString*)query htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;
+(NSURLSessionDataTask *)Request:(NSInteger)page     query:(NSString*)query  postString:(NSString*)postString htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;

+(NSURLSessionDataTask *)HeadRequest:(NSString*)requestUrl htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion;
+(void)webRequestByURL:(BOOL)isHttpMode requestUrl:(NSString*)requestUrl htmlCompletion: (HtmlDataCompleteHandler)htmlCompletion cancelBlock:(NetCancelBlock)cancelBlock;

+(void)ApplyHttpHeaders:(NSMutableURLRequest *)request;
+(AFHTTPSessionManager *)defualtSessionManager;
+(NSString*)CurrentUserAgent;
@end
typedef void (^webkit_End_Completion)(BOOL isend);

@interface NovelWebKitRequest : NSObject
@property(nonatomic,copy) HtmlDataCompleteHandler htmlCompletion;
-(void)requestWeb:(NSString*)url endHandler:(webkit_End_Completion)endHandler;
-(void)evaluateHtml:(HtmlDataCompleteHandler)completionHandler;
-(void)cancel;
@end

//@interface FetchPCSiteSearchWithWebKit : NSObject
//@property(nonatomic,copy) PCSiteSearch_UrlCompletion htmlCompletion;
//-(void)requestWeb:(NSString*)url;
//-(void)cancel;
//@end
NS_ASSUME_NONNULL_END
