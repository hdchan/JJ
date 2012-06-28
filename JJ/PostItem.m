//
//  FeedItem.m
//  JJ
//
//  Created by Henry Chan on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PostItem.h"

@implementation PostItem
@synthesize postID = _postID;
@synthesize postTitle = _postTitle;
@synthesize postDate = _postDate;
@synthesize postLeadImageLink = _postLeadImageLink;
@synthesize postDescription = _postDescription;
@synthesize postEntryContent = _postEntryContent;
@synthesize postLink = _postLink;
@synthesize miniGalleryExists = _miniGalleryExists;
- (void)dealloc {
    [_postEntryContent release];
    [_postID release];
    [_postTitle release];
    [_postDate release];
    [_postLeadImageLink release];
    [_postDescription release];
    [_postLink release];
    [super dealloc];
}

@end
