//
//  RootViewController.m
//  JJ
//
//  Created by Henry Chan on 9/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "Constants.h"
#import "JJAppDelegate.h"


#define kImageTag 999
#define kTitleTag 998
#define kDescriptionTag 997
#define kpostDateTag 996

//@implementation UINavigationBar (UINavigationBarCategory)
//- (void)drawRect:(CGRect)rect {
//    UIColor *color = [UIColor blackColor];
//    UIImage *img  = [UIImage imageNamed: @"custom_navigationbar.png"];
//    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    self.tintColor = color;
//}
//@end

@implementation RootViewController


@synthesize feedParser = _feedParser;
@synthesize feedArray = _feedArray;
@synthesize currentPageLink = _currentPageLink;
@synthesize currentPageNumber = _currentPageNumber;
@synthesize postItem = _postItem;
@synthesize loadItemCount = _loadItemCount;
@synthesize referenceID = _referenceID;
@synthesize lastItemIDFound = _lastItemIDFound;
@synthesize cacheDirectory = _cacheDirectory;
@synthesize detailedRootView = _detailedRootView;
@synthesize filePath = _filePath;
@synthesize documentsDirectory = _documentsDirectory;
@synthesize currentRefreshPageNumber = _currentRefreshPageNumber;
@synthesize firstItemIDFound = _firstItemIDFound;
@synthesize refreshPlacementPosition = _refreshPlacementPosition;
@synthesize lastSelectedDetailedRootViewItemNumber = _lastSelectedDetailedRootViewItemNumber;
@synthesize selectedRow = _selectedRow;
@synthesize lastRefreshDate = _lastRefreshDate;
@synthesize loading = _loading;
@synthesize loadMoreAI = _loadMoreAI;
-(void)loadFeed {
    self.loading = YES;
    if ([jjAppDelegate.reachability isReachable]) {
        if (_feedArray == nil) { // page 1
            UIApplication *app = [UIApplication sharedApplication]; // called twice? // future reference, should only be called once, unless removed
            
            //REMOVE NOTIFICATIONS
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:self];
             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:self];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIRootViewControllerLoadMore object:app];
            
            //ADD NOTIFICATIONS
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification  object:app];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification  object:app];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFeed) name:UIRootViewControllerLoadMore  object:app];
            
            
            _objMan = [[HJObjManager alloc] init];
            //if you are using for full screen images, you'll need a smaller memory cache:
            //objMan = [[HJObjManager alloc] initWithLoadingBufferSize:2 memCacheSize:2]];
            
            self.cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/"] ;
            HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:_cacheDirectory] autorelease];
            _objMan.fileCache = fileCache;
            
            self.currentRefreshPageNumber = 1; // for refresh 
            self.firstItemIDFound = NO; // for refresh
            self.refreshPlacementPosition = 0; // for refresh
            self.loading = YES;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            NSLog(@"if (_feedArray == nil)");
            self.feedArray = [[NSMutableArray alloc] init];
            self.feedParser = [[FeedParser alloc] init];
            self.loadItemCount = 0;
            self.currentPageNumber = 1;
            self.currentPageLink = [NSString stringWithFormat:@"%@%i",feedURLString,_currentPageNumber];
            [_feedParser parseFeed:_currentPageLink numItemsLoaded:_loadItemCount initialLoadReferenceID:nil];
            [_feedParser setDelegate:self];
        }
        else if (_feedArray != nil) {
            if (_currentPageNumber < 3) { // to page 3
                //        NSLog(@"else if (_feedArray != nil && _currentPageNumber < 3)");
                self.feedParser = [[FeedParser alloc] init];
                self.currentPageNumber += 1;
                self.referenceID = [[ _feedArray objectAtIndex:_feedArray.count-1]postID];
                self.currentPageLink = [NSString stringWithFormat:@"%@%i",feedURLString,_currentPageNumber];
                [_feedParser parseFeed:_currentPageLink numItemsLoaded:_loadItemCount initialLoadReferenceID:_referenceID];
                [_feedParser setDelegate:self];
            }
            else if (_currentPageNumber >= 3) { // page 3 and after
                //        NSLog(@"else if (_feedArray != nil && _currentPageNumber >= 3)");
                self.feedParser = [[FeedParser alloc] init];
                self.currentPageNumber += 1;
                self.referenceID = [[ _feedArray objectAtIndex:_feedArray.count-1]postID];
                NSLog(@"Reference: %@",_referenceID);
                self.currentPageLink = [NSString stringWithFormat:@"%@%i",feedURLString,_currentPageNumber-1];
                NSLog(@"LOADING FEED:%@",_currentPageLink);
                
                [_feedParser parseFeed:_currentPageLink numItemsLoaded:_loadItemCount loadingMoreReferenceID:_referenceID loadingMoreReferenceIDFound:_lastItemIDFound];
                [_feedParser setDelegate:self];
            }
        }
        
        else {
            NSLog(@"YOU FORGOT A CONDITION");
        }
    }
}
-(void)refreshFeed {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.feedParser = [[FeedParser alloc] init];
    self.currentPageLink = [NSString stringWithFormat:@"%@%i",feedURLString,_currentRefreshPageNumber];
    NSLog(@"REFRESHING: %@",_currentPageLink);
    [_feedParser refreshFeed:_currentPageLink refreshReferenceID:_referenceID refreshReferenceIDFound:_firstItemIDFound];
    [_feedParser setDelegate:self];
}
#pragma mark - Feed Parser Delegates
// refresh delegates
-(void)finishedRefreshingItem:(PostItem *)theItem {
    [_feedArray insertObject:theItem atIndex:_refreshPlacementPosition];
    [self.tableView reloadData];
    NSLog(@"Adding %i: %@",_refreshPlacementPosition,[theItem postTitle]);
    self.refreshPlacementPosition += 1;
}
-(void)firstIDItemFound:(BOOL)found {
    self.firstItemIDFound = found;
    [self performSelector:@selector(doneLoadingTableViewData)];// keep this here for refresh
}
-(void)finishedRefreshingPage {
    if (!_firstItemIDFound) {
        self.currentRefreshPageNumber += 1;
        self.currentPageNumber += 1; // if a page worth of content has been added, increase current page count by 1
        [self refreshFeed];
    }
    else {
        self.refreshPlacementPosition = 0;
        self.currentRefreshPageNumber = 1;
        self.firstItemIDFound = NO;
        self.currentPageLink = nil;//added 9-13
    } 
}
// load more delegates
-(void)finishedParsingItem:(PostItem *)theItem {
    [_feedArray addObject:theItem];
    
    self.loadItemCount += 1;
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIRootViewControllerFinishedLoadingItem object:app];
    [self.tableView reloadData];
    
}

-(void)finishedParsingNumberOfItems:(NSInteger)numOfItems {
    
    if (_loadItemCount < 20) {
        self.loadItemCount = numOfItems;
        [self loadFeed];
    }
    else {
        self.loadItemCount = 0;
        self.lastItemIDFound = NO;
        if (_currentPageNumber > 3) self.currentPageNumber -= 1;
        [self performSelector:@selector(doneLoadingTableViewData)];
        UIApplication *app = [UIApplication sharedApplication];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIRootViewControllerFinishedLoadingMore object:app];
        
    }
    self.feedParser = nil;
    self.referenceID = nil;
    self.currentPageLink = nil;
    
}
-(void)lastIDItemFound:(BOOL)found {
    self.lastItemIDFound = found;
}
// error delegate
-(void)errorParsingFeed:(NSError *)error {
    NSLog(@"not reachable: %@",error);
    [self performSelector:@selector(doneLoadingTableViewData)];
}
#pragma mark - DetailedRootViewController Delegates
-(PostItem*)getItemAtIndexPathRow:(NSInteger)row {
    return [_feedArray objectAtIndex:row];
}
-(NSInteger)getFeedArraySize {
    return _feedArray.count;
}
-(void)passIndexPathToRootView:(NSInteger)itemNumber{
    self.lastSelectedDetailedRootViewItemNumber = itemNumber;
}
-(BOOL)isRootLoading {
    return  _loading;
}

#pragma mark - Data Persistence Methods

- (NSString *)dataFilePath:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    return [_documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)writeFeedDataTo:(NSString*)fileName {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (PostItem *item in _feedArray) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[item postTitle] forKey:titleKey];
        [dic setValue:[item postDescription] forKey:descriptionKey];
        [dic setValue:[item postDate] forKey:postDateKey];
        [dic setValue:[item postLeadImageLink] forKey:leadImageLinkKey];
        [dic setValue:[item postID] forKey:postIDKey];
        [dic setValue:[item postEntryContent] forKey:entryContentKey];
        [dic setValue:[item postLink]  forKey:postLinkKey];
        [dic setValue:[NSNumber numberWithBool:[item miniGalleryExists]] forKey:miniGalleryExistsKey];
        
        [array addObject:dic];
        [dic release];
        
    }
    
    [array writeToFile:[self dataFilePath:fileName] atomically:YES];
    
    [array release];
}

- (void)retreiveDataFrom:(NSString*)fileName {
    self.filePath = [self dataFilePath:feedPlistFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:_filePath];
        _feedArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *dic in array) {
            PostItem *item = [[PostItem alloc] init];
            item.postTitle = [dic valueForKey:titleKey];
            item.postDescription = [dic valueForKey:descriptionKey];
            item.postDate = [dic valueForKey:postDateKey];
            item.postLeadImageLink = [dic valueForKey:leadImageLinkKey];
            item.postID = [dic valueForKey:postIDKey];
            item.postEntryContent = [dic valueForKey:entryContentKey];
            item.postLink = [dic valueForKey:postLinkKey];
            item.miniGalleryExists = [[dic valueForKey:miniGalleryExistsKey]boolValue];
            
            [_feedArray addObject:item];
            [item release];
        }
        
        [array release];
        
    }
    _objMan = [[HJObjManager alloc] init];
    //if you are using for full screen images, you'll need a smaller memory cache:
    //objMan = [[HJObjManager alloc] initWithLoadingBufferSize:2 memCacheSize:2]];
    
    self.cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache/"] ;
    HJMOFileCache* fileCache = [[[HJMOFileCache alloc] initWithRootPath:_cacheDirectory] autorelease];
    _objMan.fileCache = fileCache;
    
    [self.tableView reloadData];
    
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    
    [self writeFeedDataTo:feedPlistFileName];
    
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    //for devices that don't support multitask
    [self writeFeedDataTo:feedPlistFileName];
    
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    
    // Release any cached data, images, etc that aren't in use.
    self.feedParser = nil;
    self.currentPageLink = nil;
    self.referenceID = nil;
    self.postItem = nil;
    self.referenceID = nil;
    self.cacheDirectory = nil;
    self.filePath = nil;
    self.documentsDirectory = nil;
    self.selectedRow = nil;
    
    

}
- (void)dealloc {

    
    [_feedParser release];
    [_feedArray release];
    [_currentPageLink release];
    [_postItem release];
    [_referenceID release];
    [_objMan release];
    [_filePath release];
    [_refreshHeaderView release];
    [_selectedRow release];
    [_lastRefreshDate release];
    [_loadMoreAI release];
    [super dealloc];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //SHOULDN"T PUT NOTIFICATIONS HERE IF NOT GOING TO REMOVE
    
    
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
    jjAppDelegate = (JJAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (_feedArray == nil && [jjAppDelegate.reachability isReachable]) [self loadFeed];
    else if (_feedArray == nil && ![jjAppDelegate.reachability isReachable]) [self retreiveDataFrom:feedPlistFileName];
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    _refreshHeaderView = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (_detailedRootView) {
        self.selectedRow = [[NSIndexPath indexPathWithIndex:0]indexPathByAddingIndex:_lastSelectedDetailedRootViewItemNumber];
 
        [self.tableView selectRowAtIndexPath:_selectedRow animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }                          
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_detailedRootView) {
        [self.tableView deselectRowAtIndexPath:_selectedRow animated:YES];
        self.selectedRow = nil;
        self.detailedRootView = nil;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView deselectRowAtIndexPath:_selectedRow animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.referenceID = [[ _feedArray objectAtIndex:0]postID];
    _reloading = YES;
    self.loading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSLog(@"Seconds since last refresh:%f",[[NSDate date] timeIntervalSinceDate:_lastRefreshDate]);
    if ([[NSDate date] timeIntervalSinceDate:_lastRefreshDate] > 60.0*60.0) { // 1 hour
        NSLog(@"YOU HAVENT REFRESHED IN A WHILE, RELOADING A NEW ARRAY");
        self.feedArray = nil;
        [self loadFeed];
    }
    else [self refreshFeed];
    self.lastRefreshDate = [NSDate date];
}

- (void)doneLoadingTableViewData {
    
	//  model should call this when its done loading
	_reloading = NO;
    self.loading = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
    [self reloadTableViewDataSource]; 
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    return _feedArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = [indexPath row];
    
    //last cell for load more
    if (row == _feedArray.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lastCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lastCell"] autorelease];
        }
        UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(70, -5, 180, 60)]autorelease];
        title.textColor = [UIColor grayColor];
        title.text = @"Loading More...";
        title.font = [UIFont boldSystemFontOfSize:20.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell addSubview:title];
        self.loadMoreAI = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadMoreAI setFrame:CGRectMake(220, 10, 25, 25)];
        [_loadMoreAI startAnimating];
        [cell addSubview:_loadMoreAI];
        [_loadMoreAI release];
        
        return cell;
    }
    [_loadMoreAI stopAnimating];
    static NSString *CellIdentifier = @"Cell";
    
	HJManagedImageV* mi;
    UILabel *title, *description, *postDate;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//Create a managed image view and add it to the cell (layout is very naieve)
		mi = [[[HJManagedImageV alloc] initWithFrame:CGRectMake(10,10,90,90)] autorelease];
		mi.tag = kImageTag;
		[cell addSubview:mi];
		
        title = [[[UILabel alloc] initWithFrame:CGRectMake(110, 10, 180, 60)]autorelease];
        title.tag = kTitleTag;
        //        title.backgroundColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:15.0];
        title.numberOfLines = 3;
        [cell addSubview:title];
        
        postDate = [[[UILabel alloc] initWithFrame:CGRectMake(110, 70, 180, 10)]autorelease];
        postDate.tag = kpostDateTag;
        //        postDate.backgroundColor = [UIColor greenColor];
        postDate.textColor = [UIColor grayColor];
        postDate.font = [UIFont systemFontOfSize:10.0];
        postDate.numberOfLines = 1;
        [cell addSubview:postDate];
        
        description = [[[UILabel alloc] initWithFrame:CGRectMake(110, 80, 180, 100)]autorelease];
        description.tag = kDescriptionTag;
        //        description.backgroundColor = [UIColor blueColor];
        description.font = [UIFont systemFontOfSize:12.0];
        description.numberOfLines = 7;
        [cell addSubview:description];
        
    } else {
		//Get a reference to the managed image view that was already in the recycled cell, and clear it
		mi = (HJManagedImageV*)[cell viewWithTag:kImageTag];
		[mi clear];
        
        title = (UILabel*)[cell viewWithTag:kTitleTag];
        postDate = (UILabel*)[cell viewWithTag:kpostDateTag];
        description = (UILabel*)[cell viewWithTag:kDescriptionTag];
        
	}
    
    
	
	//set the URL that we want the managed image view to load
    mi.url = [NSURL URLWithString:[[_feedArray objectAtIndex:row] postLeadImageLink]];
    
	//tell the object manager to manage the managed image view, 
	//this causes the cached image to display, or the image to be loaded, cached, and displayed
	[_objMan manage:mi];
    
    title.text = [[_feedArray objectAtIndex:row] postTitle];
    postDate.text = [[_feedArray objectAtIndex:row] postDate];
    description.text = [[_feedArray objectAtIndex:row] postDescription];
    
    return cell;
}



#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _feedArray.count) return 44;
    return 190;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSInteger row = [indexPath row];
    
    if (row == _feedArray.count && _feedArray.count > 2 && !_loading && [jjAppDelegate.reachability isReachable]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.loading = YES;
        [self loadFeed];

    }
    else if (_feedArray.count > 6 && row != _feedArray.count){
        
        
        DetailedRootViewController *_detailedView = [[DetailedRootViewController alloc] init];
        
        _detailedView.currentItemNumber = row;
        _detailedView.item = [_feedArray objectAtIndex:row];
        
        _detailedView.hidesBottomBarWhenPushed = YES;
       
        
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:nil]autorelease];
        
        self.detailedRootView = _detailedView;
        [_detailedRootView setDelegate:self];
        [self.navigationController pushViewController:_detailedRootView animated:YES];
        
        [_detailedRootView release];
        
        self.selectedRow = indexPath; //set selected row
    }
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _feedArray.count-3 && _feedArray.count > 2 && !_loading &&[jjAppDelegate.reachability isReachable]) {
        
        NSLog(@"CELL BEING SHOWN, LOADING MORE");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.loading = YES;
        [self loadFeed];
        
    }
    
}


@end
