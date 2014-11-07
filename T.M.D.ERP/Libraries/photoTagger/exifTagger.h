//
//  exifTagger.h
//  EXIFOperator
//
//  Created by bravo on 14-5-5.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface exifTagger : NSObject

+(NSData*) tagUserComment:(NSString*)comment ToImageData:(NSData*)imageData;

+(NSData*) tagLocation:(CLLocation*)location ToImageData:(NSData*)imageData;

+(NSDictionary*) getMetaDataFromImage:(NSData*)imageData;

@end
