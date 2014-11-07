#import <UIKit/UIKit.h>
#import "NormalLabel.h"
#import "JRViewProtocal.h"


#define JSON_FONT_N_COLOR           @"JS_FONT_N_COLOR"        // Normal Color
#define JSON_FONT_H_COLOR           @"JS_FONT_H_COLOR"        // Highlit Color
#define JSON_FONT_S_COLOR           @"JS_FONT_S_COLOR"        // Shadow Color


@interface JRLabel : NormalLabel <JRComponentProtocal>

@property (strong) NSString* cnSpace;
@property (strong) NSString* enSpace;

// ______________

@property (assign) BOOL isReserveCenter;       // when adjust to the text length,
                                            // the center will be changed.


@property (assign) BOOL disableChangeTextTransition;

@end
