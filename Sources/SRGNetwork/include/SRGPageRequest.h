//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGBaseRequest.h"
#import "SRGPage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request for a page of results.
 */
@interface SRGPageRequest : SRGBaseRequest

/**
 *  The page which is requested.
 */
@property (nonatomic, readonly) SRGPage *page;

@end

NS_ASSUME_NONNULL_END
