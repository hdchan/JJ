//
//  Constants.h
//  JJ
//
//  Created by Henry Chan on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

//Root view controller constants
extern NSString * const feedPlistFileName;
extern NSString * const feedURLString;

extern NSString * const titleKey;
extern NSString * const descriptionKey;
extern NSString * const postDateKey;
extern NSString * const leadImageLinkKey;
extern NSString * const postIDKey;
extern NSString * const entryContentKey;
extern NSString * const postLinkKey;
extern NSString * const miniGalleryExistsKey;

//Feed parser constants
extern NSString * const idAttribute;
extern NSString * const postClass;
extern NSString * const entryClass;
extern NSString * const dateClass;
extern NSString * const leadingImageClass;
extern NSString * const imageTag;
extern NSString * const srcAttribute;
extern NSString * const relAttribute;
extern NSString * const pTag;
extern NSString * const ulTag;
extern NSString * const hrefAttribute;
extern NSString * const titleTag;
extern NSString * const miniGalleryClass;
extern NSString * const moreLinkClass;
extern NSString * const tnClass;
extern NSString * const aTag;
extern NSString * const thumbsPath;

//Notifications
extern NSString * const UIRootViewControllerLoadMore;
extern NSString * const UIRootViewControllerFinishedLoadingMore;
extern NSString * const UIRootViewControllerFinishedLoadingItem;

//Measurements
extern float const statusBarHeight;
extern float const navigationBarHeight;
extern float const toolBarHeight;


extern float const photoGalleryHeight;

@end
