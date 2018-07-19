//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkRequest.h"

#import "NSBundle+SRGNetwork.h"
#import "NSHTTPURLResponse+SRGNetwork.h"
#import "SRGNetworkError.h"

@interface  SRGNetworkRequest ()

@property (nonatomic) NSURLRequest *URLRequest;
@property (nonatomic) NSURLSessionTask *sessionTask;

@end

@implementation SRGNetworkRequest

#pragma marl Object lifecycle

- (instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;
{
    if (self = [super init]) {
        self.URLRequest = request;
        self.sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                    if ((options & SRGNetworkRequestOptionIgnoreCancellationErrors) == 0) {
                        return;
                    }
                }
                
                completionBlock(nil, response, error);
                return;
            }
            
            if ((options & SRGNetworkRequestOptionIgnoreHTTPErrors) == 0) {
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
                    NSInteger HTTPStatusCode = HTTPURLResponse.statusCode;
                    
                    // Properly handle HTTP error codes >= 400 as real errors
                    if (HTTPStatusCode >= 400) {
                        NSError *HTTPError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                                                 code:SRGNetworkErrorHTTP
                                                             userInfo:@{ NSLocalizedDescriptionKey : [NSHTTPURLResponse srg_localizedStringForStatusCode:HTTPStatusCode],
                                                                         NSURLErrorKey : response.URL,
                                                                         SRGNetworkHTTPStatusCodeKey : @(HTTPStatusCode) }];
                        completionBlock(nil, response, HTTPError);
                        return;
                    }
                }
            }
            
            completionBlock(data, response, nil);
        }];
    }
    return self;
}

- (instancetype)initWithJSONDictionaryRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable, NSURLResponse * _Nullable response, NSError * _Nullable))completionBlock
{
    return [self initWithRequest:request session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONDictionary || ! [JSONDictionary isKindOfClass:[NSDictionary class]]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONDictionary, response, nil);
    }];
}

- (instancetype)initWithJSONArrayRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable, NSURLResponse * _Nullable response, NSError * _Nullable))completionBlock
{
    return [self initWithRequest:request session:session options:options completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, response, error);
            return;
        }
        
        id JSONArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONArray || ! [JSONArray isKindOfClass:[NSArray class]]) {
            completionBlock(nil, response, [NSError errorWithDomain:SRGNetworkErrorDomain
                                                               code:SRGNetworkErrorInvalidData
                                                           userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONArray, response, nil);
    }];
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithRequest:[NSURLRequest new] session:[NSURLSession new] options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Nothing
    }];
}

#pragma mark Request management

- (void)resume
{
    [self.sessionTask resume];
}

- (void)cancel
{
    [self.sessionTask cancel];
}

@end
