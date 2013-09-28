//
//  DetailedRootViewController.m
//  JJ
//
//  Created by Henry Chan on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailedRootViewController.h"
#import "RootViewController.h"
#import "Constants.h"
#import "HTMLNode.h"
#import "KTPhotoSource.h"
 

@implementation DetailedRootViewController
@synthesize item = _item;
@synthesize webView = _webView;
@synthesize contentEncoded = _contentEncoded;
@synthesize itemTitle = _itemTitle;
@synthesize leadImageLink = _leadImageLink;
@synthesize HTMLContent = _HTMLContent;
@synthesize segmentedControl = _segmentedControl; 
@synthesize currentItemNumber = _currentItemNumber;
@synthesize delegate = _delegate;
@synthesize loading = _loading;
@synthesize galleryButton = _galleryButton;
@synthesize socialButton = _socialButton;
@synthesize scrollView = _scrollView;
@synthesize photoGallery = _photoGallery;
@synthesize urlConnection = _urlConnection;
@synthesize receivedData = _receivedData;
@synthesize photoLinkArray = _photoLinkArray;
@synthesize ktViewController = _ktViewController;
@synthesize linksArrayLoaded = _linksArrayLoaded;

-(IBAction)presentSocialActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet This",@"Share on Facebook", @"Email This", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showFromBarButtonItem:_socialButton animated:YES];
    [actionSheet release];
}

-(IBAction)photos:(id)sender {
    if (_linksArrayLoaded) {
        KTViewController *pushController = [[KTViewController alloc] init];
        KTPhotoSource *source = [[KTPhotoSource alloc] init];
        source.images = _photoLinkArray;
        pushController.photoSource = source;
        
        self.ktViewController = pushController;
        [self.navigationController pushViewController:_ktViewController animated:YES];
        [pushController release];
    }
    else NSLog(@"Links not loaded yet!");
}

#pragma mark - Get Gallery Link
-(void)getPhotoGalleryLinks {
    self.receivedData = [[NSMutableData alloc] init];
    self.urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_item.postLink]] delegate:self];
    [_urlConnection start];
}

#pragma mark - HTML Parsing
-(void) parseReceivedData {
    
    HTMLParser *htmlParser = [[HTMLParser alloc] initWithData:_receivedData error:nil];
    NSArray *tnArray = [[NSArray alloc] initWithArray:[[htmlParser body] findChildrenOfClass:tnClass]];
    self.receivedData = nil;
    
    self.photoLinkArray = [[NSMutableArray alloc] init];
    for (HTMLNode *tn in tnArray) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[tn findChildTag:imageTag]getAttributeNamed:srcAttribute]];//thumb
        [array addObject:[[[tn findChildTag:imageTag]getAttributeNamed:srcAttribute] stringByReplacingOccurrencesOfString:thumbsPath withString:@""]]; //full-size

        [_photoLinkArray addObject:array];
        [array release];
        
    }
    
    
    
    
    _galleryButton.enabled = YES;
    self.linksArrayLoaded = YES;

    [htmlParser release];
    [tnArray release];
    
}
#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.urlConnection = nil;
    [self parseReceivedData];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.urlConnection = nil;
}

#pragma mark - Load Web View Content
- (void)loadWebContent {
    
    _galleryButton.enabled = NO;
    
    NSLog(@"Item number: %i",_currentItemNumber+1);

    if (_urlConnection) {
        [_urlConnection cancel];
        self.urlConnection = nil;
        self.receivedData = nil;
    }
    
    self.linksArrayLoaded = NO;
    
    self.itemTitle = [_item postTitle];
    self.contentEncoded = [_item postEntryContent];
    self.leadImageLink = [_item postLeadImageLink];
    
    self.HTMLContent = [NSString stringWithFormat:@"<html><head><link href='DetailedRootViewStyle.css'rel='stylesheet' type='text/css'></head><body><div id='title'>%@</div><br/><div id='leadImage'><img src='%@'/></div>%@</body></html>",_itemTitle,_leadImageLink,_contentEncoded];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_webView loadHTMLString:_HTMLContent baseURL:baseURL];

    [_webView setDelegate:self];
    
}
#pragma mark - UIWebView Delegates
-(void)webViewDidStartLoad:(UIWebView *)webView {
    
    [self performSelector:@selector(checkPageNavigation)];    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    self.itemTitle = nil;
    self.leadImageLink = nil;
    self.contentEncoded = nil;
    self.HTMLContent = nil;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    [_webView setFrame:CGRectMake(0, 0, screenWidth, screenHeight-statusBarHeight-navigationBarHeight-toolBarHeight)];
    [_scrollView setContentSize:CGSizeMake(screenWidth, screenHeight-statusBarHeight-navigationBarHeight-toolBarHeight)];

   
    
    float height;

    NSString *heightString = [_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];

    height = [heightString floatValue];
    _webView.frame = CGRectMake(0, 0, screenWidth, height);

    [_scrollView setContentSize:CGSizeMake(screenWidth, height)];
    if (_item.miniGalleryExists) [self getPhotoGalleryLinks];
    
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if (navigationType == 0) return NO;
    return YES;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

#pragma mark - Setup View
- (void)setUpDetailedView {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
   
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-statusBarHeight-navigationBarHeight-toolBarHeight)];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-statusBarHeight-navigationBarHeight-toolBarHeight)];
    [[[_webView subviews] lastObject] setScrollEnabled:NO];
    [self.scrollView addSubview:_webView];
    [self.view addSubview:_scrollView];
    [self loadWebContent];
}

#pragma mark - Detailed View Navigation
- (void) checkPageNavigation {
    
    _segmentedControl.selectedSegmentIndex = -1;
    
    if (_currentItemNumber >= [[self delegate]getFeedArraySize]-3) {
        if (!_loading && ![[self delegate]isRootLoading] && [jjAppDelegate.reachability isReachable]) {
            NSLog(@"SENDING NOTIFICATION TO LOAD MORE"); //need to get bool from root so it doesnt conincide
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            UIApplication *app = [UIApplication sharedApplication];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIRootViewControllerLoadMore object:app];
            self.loading = YES;
        }
    }
    
    if (_currentItemNumber == 0)[_segmentedControl setEnabled:NO forSegmentAtIndex:0];
    else [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
    
    if (_currentItemNumber == [[self delegate]getFeedArraySize]-1)[_segmentedControl setEnabled:NO forSegmentAtIndex:1];
    else [_segmentedControl setEnabled:YES forSegmentAtIndex:1];
    

}
-(void)finishedLoadingItem {
    [self checkPageNavigation];
}
-(void)finishedLoadingMore {
    self.loading = NO;
}

-(IBAction)nav:(id)sender {
    
    NSInteger selectedSeg = [(UISegmentedControl*)sender selectedSegmentIndex];
    
    if (selectedSeg == 0){
        self.currentItemNumber -= 1;
        self.item = [[self delegate]getItemAtIndexPathRow:_currentItemNumber];
        [self loadWebContent];
    }
    else if (selectedSeg == 1 ){
        self.currentItemNumber += 1;
        self.item = [[self delegate]getItemAtIndexPathRow:_currentItemNumber];
        [self loadWebContent];
    }
    
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    jjAppDelegate = (JJAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIRootViewControllerFinishedLoadingMore object:app];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIRootViewControllerFinishedLoadingItem object:app];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoadingMore) name:UIRootViewControllerFinishedLoadingMore  object:app];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoadingItem) name:UIRootViewControllerFinishedLoadingItem  object:app];
    
    [self checkPageNavigation];
    [self setUpDetailedView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
 
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (_ktViewController) self.ktViewController = nil;
    
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[self delegate]passIndexPathToRootView:_currentItemNumber];
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.

}

- (void)dealloc {
    [_item release];
    [_segmentedControl release];
    [_itemTitle release];
    [_leadImageLink release];
    [_contentEncoded release];
    [_webView release];
    [_galleryButton release];
    [_socialButton release];
    [_scrollView release];
    [_photoGallery release];
    [_urlConnection release];
    [_receivedData release];
    [_photoLinkArray release];
    [_ktViewController release];
    [super dealloc];
}


@end
