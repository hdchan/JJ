//
//  KTPhotoSource.h
//  JJ
//
//  Created by Henry Chan on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"
@interface KTPhotoSource : NSObject <KTPhotoBrowserDataSource> {
    NSArray *_images;
}
@property (nonatomic, retain) NSArray *images;    
@end
