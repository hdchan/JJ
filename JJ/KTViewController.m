//
//  KTViewController.m
//  JJ
//
//  Created by Henry Chan on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KTViewController.h"


@implementation KTViewController
@synthesize photoSource = _photoSource;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_photoSource release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDataSource:_photoSource];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
