//
//  DetailedRootViewController.h
//  JJ
//
//  Created by Henry Chan on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostItem.h"
#import "KTViewController.h"
#import "JJAppDelegate.h"
@protocol DetailedRootViewControllerDelegate <NSObject>

@required
-(PostItem*)getItemAtIndexPathRow:(NSInteger)row;
-(NSInteger)getFeedArraySize;
-(void)passIndexPathToRootView:(NSInteger)itemNumber;
-(BOOL)isRootLoading;
@end

@interface DetailedRootViewController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate> {
    
    PostItem *_item;
    
    UIWebView *_webView;
    NSString *_contentEncoded;
    NSString *_itemTitle;
    NSString *_leadImageLink;
    NSString *_HTMLContent;
    
    NSInteger _currentItemNumber;
    
    UISegmentedControl *_segmentedControl;
    
    id<DetailedRootViewControllerDelegate>_delegate;
    
    BOOL _loading;
    
    UIBarButtonItem *_galleryButton;
    UIBarButtonItem *_socialButton;
   
    UIScrollView *_scrollView;
    UIScrollView *_photoGallery;
    
    NSURLConnection *_urlConnection;
    NSMutableData *_receivedData;
    
    NSMutableArray *_photoLinkArray;

    
    KTViewController *_ktViewController;
    BOOL _linksArrayLoaded;
    
    JJAppDelegate *jjAppDelegate;
}
@property (nonatomic, retain) PostItem *item;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *contentEncoded;
@property (nonatomic, retain) NSString *itemTitle;
@property (nonatomic, retain) NSString *leadImageLink;
@property (nonatomic, retain) NSString *HTMLContent;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property NSInteger currentItemNumber;
@property (nonatomic, retain) id delegate;
@property BOOL loading;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *galleryButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *socialButton;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIScrollView *photoGallery;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *photoLinkArray;

@property (nonatomic, retain) KTViewController *ktViewController;
@property BOOL linksArrayLoaded;
-(IBAction)nav:(id)sender;
-(IBAction)photos:(id)sender;
@end
