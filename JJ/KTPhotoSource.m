//
//  KTPhotoSource.m
//  JJ
//
//  Created by Henry Chan on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KTPhotoSource.h"
#import "KTPhotoView+SDWebImage.h"
#import "KTThumbView+SDWebImage.h"

#define FULL_SIZE_INDEX 1
#define THUMBNAIL_INDEX 0

@implementation KTPhotoSource
@synthesize images = _images;

- (UIImage *)imageWithURLString:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

-(NSInteger)numberOfPhotos {

    return _images.count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    NSArray *imageUrls = [_images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:FULL_SIZE_INDEX];
    [photoView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    NSArray *imageUrls = [_images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:THUMBNAIL_INDEX];
    [thumbView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)dealloc {
    [_images release];
    [super dealloc];
}
@end
