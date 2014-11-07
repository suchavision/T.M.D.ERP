//
//  exifTagger.m
//  EXIFOperator
//
//  Created by bravo on 14-5-5.
//  Copyright (c) 2014年 bravo. All rights reserved.
//

#import "exifTagger.h"

@implementation exifTagger

+(NSData*) tagUserComment:(NSString *)comment ToImageData:(NSData *)imageData{
    NSDictionary* originalMetaData = [self getMetaDataFromImage:imageData];
    NSMutableDictionary* newMeta = [originalMetaData mutableCopy];
    NSMutableDictionary* TIFF = [newMeta objectForKey:(NSString*)kCGImagePropertyTIFFDictionary];
    if (!TIFF){
        TIFF = [[NSMutableDictionary alloc] init];
    }
    [TIFF setObject:comment forKey:(NSString*)kCGImagePropertyTIFFImageDescription];
    [newMeta setObject:TIFF forKey:(NSString*)kCGImagePropertyTIFFDictionary];
    return [self writeMetadataIntoImageData:imageData metadata:newMeta];
}

+(NSData*) tagLocation:(CLLocation *)location ToImageData:(NSData *)imageData{
    NSMutableDictionary* newMeta = [[self getMetaDataFromImage:imageData] mutableCopy];
    if (location){
        newMeta[(NSString*)kCGImagePropertyGPSDictionary] = [self gpsDictionaryForLocation:location];
    }
    return [self writeMetadataIntoImageData:imageData metadata:newMeta];
}

+(NSDictionary*) getMetaDataFromImage:(NSData*)imageData{
    CGImageSourceRef originalSource =  CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    return  (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(originalSource, 0, NULL);
}

+ (NSData *)writeMetadataIntoImageData:(NSData *)imageData metadata:(NSMutableDictionary *)metadata {
    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    
    // this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);
    
    // create a new data object and write the new image into it
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) metadata);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    CFRelease(destination);
    CFRelease(source);
    return dest_data;
}

+ (NSDictionary *)gpsDictionaryForLocation:(CLLocation *)location {
    NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    
    NSDictionary *gpsDict = @{(NSString *)kCGImagePropertyGPSLatitude: @(fabs(location.coordinate.latitude)),
                              (NSString *)kCGImagePropertyGPSLatitudeRef: ((location.coordinate.latitude >= 0) ? @"N" : @"S"),
                              (NSString *)kCGImagePropertyGPSLongitude: @(fabs(location.coordinate.longitude)),
                              (NSString *)kCGImagePropertyGPSLongitudeRef: ((location.coordinate.longitude >= 0) ? @"E" : @"W"),
                              (NSString *)kCGImagePropertyGPSTimeStamp: [formatter stringFromDate:[location timestamp]],
                              (NSString *)kCGImagePropertyGPSAltitude: @(fabs(location.altitude)),
                              };
    return gpsDict;
}

@end
