//
//  FeedItem.h
//  JJ
//
//  Created by Henry Chan on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostItem : NSObject {
    NSString *_postID;
    NSString *_postTitle;
    NSString *_postDate;
    NSString *_postLeadImageLink;
    NSString *_postDescription;
    NSString *_postEntryContent;
    NSString *_postLink;
    BOOL _miniGalleryExists;
    
}
@property (nonatomic, retain) NSString *postID;
@property (nonatomic, retain) NSString *postTitle;
@property (nonatomic, retain) NSString *postDate;
@property (nonatomic, retain) NSString *postLeadImageLink;
@property (nonatomic, retain) NSString *postDescription;
@property (nonatomic, retain) NSString *postEntryContent;
@property (nonatomic, retain) NSString *postLink;
@property (nonatomic, assign) BOOL miniGalleryExists;
@end
