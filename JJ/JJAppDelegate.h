//
//  JJAppDelegate.h
//  JJ
//
//  Created by Henry Chan on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface JJAppDelegate : NSObject <UIApplicationDelegate> {
     Reachability *_reachability;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) Reachability *reachability;



@end
