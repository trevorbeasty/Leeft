//
//  TJBAestheticsController.m
//  Beast
//
//  Created by Trevor Beasty on 12/25/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBAestheticsController.h"

@implementation TJBAestheticsController

#pragma mark - Singleton

+ (instancetype)singleton{
    static TJBAestheticsController *singleton;
    
    if (!singleton)
    {
        singleton = [[self alloc] initPrivate];
    }
    return singleton;
}

- (instancetype)initPrivate{
    self = [super init];
    
    return self;
}

- (instancetype)init{
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[TJBAestheticsController singleton]"
                                 userInfo: nil];
}

#pragma mark - Images

- (void)addFullScreenBackgroundViewWithImage:(UIImage *)image toRootView:(UIView *)rootView{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIImage *resizedImage = [self imageWithImage: image
                                    scaledToSize: screenSize];
    
    UIView *imageView = [[UIImageView alloc] initWithImage: resizedImage];
    
    [rootView addSubview: imageView];
    [rootView sendSubviewToBack: imageView];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

















