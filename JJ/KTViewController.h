//
//  KTViewController.h
//  JJ
//
//  Created by Henry Chan on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTThumbsViewController.h"
#import "KTPhotoSource.h"
@interface KTViewController : KTThumbsViewController {
    KTPhotoSource *_photoSource;
}
@property (nonatomic, retain) KTPhotoSource *photoSource;
@end
