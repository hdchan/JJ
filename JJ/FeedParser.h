//
//  FeedParser.h
//  JJ
//
//  Created by Henry Chan on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PostItem.h"



@protocol FeedParserDelegate <NSObject>
@required
-(void)finishedParsingItem:(PostItem*)theItem;
-(void)finishedParsingNumberOfItems:(NSInteger)numOfItems;
-(void)lastIDItemFound:(BOOL)found;
-(void)firstIDItemFound:(BOOL)found;
-(void)finishedRefreshingItem:(PostItem*)theItem;
-(void)finishedRefreshingPage;
-(void)errorParsingFeed:(NSError *)error;
@end

@interface FeedParser : NSObject  {
    NSURLConnection *_urlConnection;
    NSMutableData *_receivedData;
    PostItem *_postItem;
    
    id<FeedParserDelegate> _delgate;
    
    NSArray *_entryContent;
    NSMutableString *_allContent;
    NSMutableString *_rawContent;
    
    NSInteger _numberOfItemsLoaded;
    NSString *_loadingMoreReferenceID;
    BOOL _lastItemIDFound;
    
    NSString *_refreshReferenceID;
    BOOL _firstItemIDFound;
    
    NSString *_initialLoadID;
}
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) PostItem *postItem;
@property (retain) id delegate;
@property (nonatomic, retain) NSArray *entryContent;
@property (nonatomic, retain) NSMutableString *allContent;
@property (nonatomic, retain) NSMutableString *rawContent;
@property NSInteger numberOfItemsLoaded;
@property (nonatomic, retain) NSString *loadingMoreReferenceID;
@property BOOL lastItemIDFound;
@property (nonatomic, retain) NSString *refreshReferenceID;
@property BOOL firstItemIDFound;
@property (nonatomic, retain) NSString *initialLoadID;


- (void)parseFeed:(NSString *)url numItemsLoaded:(NSInteger)num initialLoadReferenceID:(NSString*)theLastIDOfThePage;
- (void)parseFeed:(NSString *)url numItemsLoaded:(NSInteger)num loadingMoreReferenceID:(NSString*)lastID loadingMoreReferenceIDFound:(BOOL)found;
- (void)refreshFeed:(NSString *)url refreshReferenceID:(NSString*)firstID refreshReferenceIDFound:(BOOL)found;
@end
