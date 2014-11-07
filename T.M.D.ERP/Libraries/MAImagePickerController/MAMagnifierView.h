//
//  MAMagnifierView.h
//  instaoverlay
//
//  Copyright (c) 2014年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMagnifierView :  UIView

@property (nonatomic) UIView *viewToMagnify;
@property (nonatomic) CGPoint pointToMagnify;
@property(nonatomic, assign)CGContextRef ctx;

@end
