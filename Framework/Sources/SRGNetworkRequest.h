//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Rquest options.
 */
typedef NS_OPTIONS(NSUInteger, SRGNetworkRequestOptions) {
    /**
     *  By default, cancelled requests will not call the associated completion block. If this flag is set, though,
     *  cancelled requests will call the completion block with an associated error.
     */
    SRGNetworkRequestOptionCancellationErrorsProcessed = (1UL << 0),
    /**
     *  By default, and unlike `NSURLSession` tasks, requests return an `NSError` when an HTTP error status code has
     *  been received. If this flag is set, though, this mechanism is disabled, and the behavior is similar to the
     *  one of `NSURLSession` tasks (the status code can be retrieved from the response).
     */
    SRGNetworkRequestOptionHTTPErrorsDisabled = (1UL << 1),
    /**
     *  By default, certificate trust issues are described as probably related to a public WiFi being used. This
     *  behavior can be disabled, in which case the original error message is returned. The error domain and code
     *  and left unaltered.
     */
    SRGNetworkRequestPublicWiFiIssuesDisabled = (1UL << 2)
};

/**
 *  A simple network request. Can be created from any thread.
 */
@interface SRGNetworkRequest : NSObject

/**
 *  Create a request from a URL request, and for a given session.
 *
 *  @param request         The request to execute.
 *  @param session         The session for which the request is executed.
 *  @param options         Options to apply (0 if none).
 *  @param completionBlock The completion block which will be called when the request ends. Beware that the block might be
 *                         called on a background thread, depending on how the session has been configured.
 */
- (instancetype)initWithURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock NS_DESIGNATED_INITIALIZER;

/**
 *  Same as `-initWithURLRequest:session:options:completionBlock:`, returning the response as a JSON dictionary.
 *
 *  @discussion An error is returned if the response is not a valid JSON dictionary.
 */
- (instancetype)initWithJSONDictionaryURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

/**
 *  Same as `-initWithURLRequest:session:options:completionBlock:`, returning the response as a JSON array.
 *
 *  @discussion An error is returned if the response is not a valid JSON array.
 */
- (instancetype)initWithJSONArrayURLRequest:(NSURLRequest *)request session:(NSURLSession *)session options:(SRGNetworkRequestOptions)options completionBlock:(void (^)(NSArray * _Nullable JSONArray, NSURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

/**
 *  The original URL request.
 */
@property (nonatomic, readonly) NSURLRequest *URLRequest;

/**
 *  Start the request.
 */
- (void)resume;

/**
 *  Cancel the request.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
