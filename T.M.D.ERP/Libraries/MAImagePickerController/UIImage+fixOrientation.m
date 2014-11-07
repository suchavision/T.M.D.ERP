//
//  UIImage+fixOrientation.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/11/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "UIImage+fixOrientation.h"

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation
{
    UIImage *src = [[UIImage alloc] initWithCGImage: self.CGImage
                                                         scale: 1.0
                                                   orientation: UIImageOrientationRight];

    return src;
//    if (self.imageOrientation == UIImageOrientationUp) return self;
//    
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
//    [self drawInRect:(CGRect){0, 0, self.size}];
//    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return normalizedImage;
}

+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    //    CGContextRotateCTM(UIGraphicsGetCurrentContext(), M_PI_4);
    //    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), newSize.width, 0);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

@end
