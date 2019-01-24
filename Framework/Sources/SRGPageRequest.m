//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

#import "SRGBaseRequest+Subclassing.h"
#import "SRGPage+Private.h"
#import "SRGPageRequest+Subclassing.h"

@interface SRGPageRequest ()

@property (nonatomic) SRGPage *page;

@property (nonatomic, copy) SRGObjectPageBuilder builder;
@property (nonatomic, copy) SRGObjectPageCompletionBlock pageCompletionBlock;

@end

@implementation SRGPageRequest

#pragma mark Object lifecycle

- (instancetype)initWithURLRequest:(NSURLRequest *)URLRequest
                           session:(NSURLSession *)session
                           options:(SRGRequestOptions)options
                            parser:(SRGResponseParser)parser
                              page:(SRGPage *)page
                           builder:(SRGObjectPageBuilder)builder
                   completionBlock:(SRGObjectPageCompletionBlock)completionBlock
{
    if (! page) {
        page = [[SRGPage alloc] initWithSize:SRGPageDefaultSize number:0 URLRequest:self.URLRequest];
    }
    
    SRGObjectCompletionBlock pageCompletionBlock = ^(id  _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, page, nil, response, error);
            return;
        }
        
        NSURLRequest *nextURLRequest = self.builder(object, response, page.size, page.number, URLRequest);
        SRGPage *nextPage = nextURLRequest ? [[SRGPage alloc] initWithSize:page.size number:page.number + 1 URLRequest:nextURLRequest] : nil;
        completionBlock(object, page, nextPage, response, nil);
    };
    
    if (self = [super initWithURLRequest:URLRequest session:session options:options parser:parser completionBlock:pageCompletionBlock]) {
        self.page = page;
        self.builder = builder;
        self.pageCompletionBlock = completionBlock;
    }
    return self;
}

@end
