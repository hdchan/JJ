//
//  FeedParser.m
//  JJ
//
//  Created by Henry Chan on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedParser.h"
#import "Constants.h"
#import "HTMLParser.h"

@implementation FeedParser
@synthesize receivedData = _receivedData;
@synthesize postItem = _postItem;
@synthesize delegate = _delgate;
@synthesize entryContent = _entryContent;
@synthesize allContent = _allContent;
@synthesize rawContent = _rawContent;
@synthesize numberOfItemsLoaded = _numberOfItemsLoaded;
@synthesize loadingMoreReferenceID = _loadingMoreReferenceID;
@synthesize lastItemIDFound = _lastItemIDFound;
@synthesize urlConnection = _urlConnection;
@synthesize refreshReferenceID = _refreshReferenceID;
@synthesize firstItemIDFound = _firstItemIDFound;
@synthesize initialLoadID = _initialLoadID;

// initial load
- (void)parseFeed:(NSString *)url numItemsLoaded:(NSInteger)num initialLoadReferenceID:(NSString *)theLastIDOfThePage{
    NSLog(@"INITIAL LOAD");
    self.receivedData = [[NSMutableData alloc] init];
    self.numberOfItemsLoaded = num;
    self.initialLoadID = theLastIDOfThePage;
    self.loadingMoreReferenceID = nil;
    self.lastItemIDFound = YES;
    
    self.urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    [_urlConnection start];
}
// load more after initial load
- (void)parseFeed:(NSString *)url numItemsLoaded:(NSInteger)num loadingMoreReferenceID:(NSString *)lastID loadingMoreReferenceIDFound:(BOOL)found{
    NSLog(@"LOAD FEED");
    self.receivedData = [[NSMutableData alloc] init];
    self.numberOfItemsLoaded = num;
    self.loadingMoreReferenceID = lastID;
    self.lastItemIDFound = found;
    self.initialLoadID = nil;

    self.urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    [_urlConnection start]; //connection doesnt start or gets delayed when mem warning
}
// refresh feed
- (void)refreshFeed:(NSString *)url refreshReferenceID:(NSString*)firstID refreshReferenceIDFound:(BOOL)found{
    NSLog(@"REFRESHING FEED");
    self.receivedData = [[NSMutableData alloc] init];
    self.refreshReferenceID = firstID;
    self.firstItemIDFound = found;
    self.initialLoadID = nil;
    
    self.urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
    [_urlConnection start];
}

- (void)dealloc {
    [_urlConnection release];
    [_entryContent release];
    [_allContent release];
    [_rawContent release];
    [_postItem release];
    [_receivedData release];
    [_loadingMoreReferenceID release];
    [_refreshReferenceID release];
    [_initialLoadID release];
    [super dealloc];
}
#pragma mark - HTML Parsing

- (void)parseReceivedData {

    HTMLParser *htmlParser = [[HTMLParser alloc] initWithData:_receivedData error:nil];
    NSArray *postArray = [[NSArray alloc] initWithArray:[[htmlParser body] findChildrenOfClass:postClass]];
    
    
    
    for (HTMLNode *post in postArray)
    {

        
            
        if (![post getAttributeNamed:idAttribute]) {// continue if there is no id attribute
            NSLog(@"if (![post getAttributeNamed:idAttribute])");
            continue; //skip remaining if there is no ID 
        }
            
        
        if (_refreshReferenceID) { // refresh
            if ([_refreshReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _firstItemIDFound == NO) {
                NSLog(@"%@ found, finished refreshing",_refreshReferenceID);
                self.firstItemIDFound = YES;
                [[self delegate]firstIDItemFound:_firstItemIDFound];
                break;
            }
        }
        
        else if(_loadingMoreReferenceID) { // loading more // cant say else if because it wont do the initial loading
            
            if (_numberOfItemsLoaded == 20) // break after loading 20 items
                break;   
            
            if(![_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == NO) { //skip if its not equal
                NSLog(@"if(![_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == NO)");
                continue;
            }
            
            else if([_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == NO) { // continue if the last item hasn't been found yet
                NSLog(@"else if([_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == NO): %@",[post getAttributeNamed:idAttribute]);
                self.lastItemIDFound = YES; // if found then set lastitemidfound to yes
                [[self delegate] lastIDItemFound:_lastItemIDFound]; // pass the bool to the rootcontroller so it can set its bool
                continue; 
            }
            else if([_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == YES) { //should add this condition to initial load
                NSLog(@"else if([_loadingMoreReferenceID isEqualToString:[post getAttributeNamed:idAttribute]] && _lastItemIDFound == YES):DUPLICATE:%@",[post getAttributeNamed:idAttribute]);
                continue;
            }
        }
        
        else if (_initialLoadID) { // initial load
            
            if (_numberOfItemsLoaded == 20) // break after loading 20 items
                break;  
            
            if ([_initialLoadID isEqualToString:[post getAttributeNamed:idAttribute]]) { // need this condition because an entry might be added while loading
                NSLog(@"if ([_initialLoadID isEqualToString:[post getAttributeNamed:idAttribute]])");
                continue;
            }
                
        }
        
        
        
        
        self.postItem = [[PostItem alloc] init];
        
        _postItem.postID = [post getAttributeNamed:idAttribute];
        
        _postItem.postDate = [[[post findChildOfClass:dateClass]allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        _postItem.postTitle =[[post findChildWithAttribute:relAttribute matchingName:@"bookmark" allowPartial:NO]getAttributeNamed:titleTag];
        
        _postItem.postLink = [[post findChildWithAttribute:relAttribute matchingName:@"bookmark" allowPartial:NO]getAttributeNamed:hrefAttribute];
        
        if ([[post findChildOfClass:entryClass]findChildTag:pTag]) { // entries that have p tags // use this condition to test what tags the entry class contains
            self.entryContent = [[post findChildOfClass:entryClass]findChildTags:pTag];
           
        }
        else if ([[post findChildOfClass:entryClass]findChildTag:ulTag]) { // entries that have ul tags
            self.entryContent = [[post findChildOfClass:entryClass]findChildTags:ulTag];

        }
        else {
            NSLog(@"TAG TYPE WASN'T FOUND");
        }

        self.allContent = [NSMutableString stringWithCapacity:10];
        self.rawContent = [NSMutableString string];
        for (HTMLNode *p in _entryContent) {
            if ([_allContent length]<170) [_allContent appendString:[p allContents]];
            [_rawContent appendString:[p rawContents]];
        }
        _postItem.postDescription = _allContent;
        _postItem.postEntryContent = [_rawContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        
        _postItem.postLeadImageLink = [[[post findChildOfClass:leadingImageClass]findChildTag:imageTag]getAttributeNamed:srcAttribute];
        
        if ([post findChildrenOfClass:miniGalleryClass].count>0 ||[post findChildrenOfClass:moreLinkClass].count>0) _postItem.miniGalleryExists = YES;
        else _postItem.miniGalleryExists = NO;
        
        
        if (!_refreshReferenceID) {
            self.numberOfItemsLoaded += 1;
            NSLog(@"%i: %@ :%@",_numberOfItemsLoaded,_postItem.postID,_postItem.postTitle);
        }
        
        if (_refreshReferenceID) [[self delegate] finishedRefreshingItem:_postItem];
        else [[self delegate] finishedParsingItem:_postItem];
         
        
        [_postItem release];
  
        self.postItem = nil;
            
    }
    
    if (_refreshReferenceID) {
        
        [[self delegate] finishedRefreshingPage];
    }
    else {
        [[self delegate] finishedParsingNumberOfItems:_numberOfItemsLoaded];
    }
    
    [postArray release];
    [htmlParser release];
    self.receivedData = nil;
    self.postItem = nil;
    self.entryContent = nil;
    self.allContent = nil;
    self.rawContent = nil;
    self.loadingMoreReferenceID = nil;
    self.refreshReferenceID = nil;
    self.initialLoadID = nil;
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
    [[self delegate] errorParsingFeed:error];
    
}


@end
