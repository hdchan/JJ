//
//  Constants.m
//  JJ
//
//  Created by Henry Chan on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const feedPlistFileName = @"feedData.plist";
NSString *const feedURLString =@"http://justjared.buzznet.com/page/";

NSString *const titleKey = @"title";
NSString *const descriptionKey = @"description";
NSString *const postDateKey = @"postDate";
NSString *const leadImageLinkKey = @"leadImageLink";
NSString *const postIDKey = @"id";
NSString *const entryContentKey = @"entryContent";
NSString *const postLinkKey = @"postLink";
NSString *const miniGalleryExistsKey = @"miniGalleryBool";

NSString * const idAttribute = @"id";
NSString * const postClass = @"post";
NSString * const entryClass = @"entry";
NSString * const dateClass = @"post-date";
NSString * const leadingImageClass = @"lead-img";
NSString * const imageTag = @"img";
NSString * const srcAttribute = @"src";
NSString * const relAttribute = @"rel";
NSString * const pTag = @"p";
NSString * const ulTag = @"ul";
NSString * const hrefAttribute = @"href";
NSString * const titleTag = @"title";
NSString * const miniGalleryClass = @"minigallery";
NSString * const moreLinkClass = @"more-link";
NSString * const tnClass = @"tn";
NSString * const aTag = @"a";
NSString * const thumbsPath = @"/thumbs";

NSString * const UIRootViewControllerLoadMore = @"UIRootViewControllerLoadMore";
NSString * const UIRootViewControllerFinishedLoadingMore = @"UIRootViewControllerFinishedLoadingMore";
NSString * const UIRootViewControllerFinishedLoadingItem = @"UIRootViewControllerFinishedLoadingItem";

float const statusBarHeight = 20.0;
float const navigationBarHeight = 44.0;
float const toolBarHeight = 44.0;

float const photoGalleryHeight = 480-20;
@end
