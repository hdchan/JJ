//
//  RootViewController.h
//  JJ
//
//  Created by Henry Chan on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedParser.h"
#import "PostItem.h"
#import "HJObjManager.h"
#import "HJMOFileCache.h"
#import "HJManagedImageV.h"
#import "DetailedRootViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "JJAppDelegate.h"
@interface RootViewController : UITableViewController  <FeedParserDelegate, EGORefreshTableHeaderDelegate, DetailedRootViewControllerDelegate> {


    FeedParser *_feedParser;
    NSMutableArray *_feedArray;
    NSString *_currentPageLink;
    NSInteger _currentPageNumber;
    PostItem *_postItem;
    NSInteger _loadItemCount;
    NSString *_referenceID;
    BOOL _lastItemIDFound;
    HJObjManager *_objMan;
    NSString *_cacheDirectory;
    DetailedRootViewController *_detailedRootView;
    NSString *_filePath;
    NSString *_documentsDirectory;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    NSInteger _currentRefreshPageNumber;
    BOOL _firstItemIDFound;
    NSInteger _refreshPlacementPosition;
    NSInteger _lastSelectedDetailedRootViewItemNumber;
    NSIndexPath *_selectedRow;
    NSDate *_lastRefreshDate;
    BOOL _loading;
    
    JJAppDelegate *jjAppDelegate;
    UIActivityIndicatorView *_loadMoreAI;
}


@property (nonatomic, retain) FeedParser *feedParser;
@property (nonatomic, retain) NSMutableArray *feedArray;
@property (nonatomic, retain) NSString *currentPageLink;
@property NSInteger currentPageNumber;
@property (nonatomic, retain) PostItem *postItem;
@property NSInteger loadItemCount;
@property (nonatomic, retain) NSString *referenceID;
@property BOOL lastItemIDFound;
@property (nonatomic, retain) NSString *cacheDirectory;
@property (nonatomic, retain) DetailedRootViewController *detailedRootView;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSString *documentsDirectory;
@property NSInteger currentRefreshPageNumber;
@property BOOL firstItemIDFound;
@property NSInteger refreshPlacementPosition;
@property NSInteger lastSelectedDetailedRootViewItemNumber;
@property (nonatomic, retain) NSIndexPath *selectedRow;
@property (nonatomic, retain) NSDate *lastRefreshDate;
@property BOOL loading;
@property (nonatomic, retain) UIActivityIndicatorView *loadMoreAI;

@end
