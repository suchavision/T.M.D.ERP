//
//  MADrawRect.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/6/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//
// CGPoints Illustraition
//
//            cd
//  d   -------------   c
//     |             |
//     |             |
//  da |             |  bc
//     |             |
//     |             |
//     |             |
//  a   -------------   b
//            ab
//
// a = 1, b = 2, c = 3, d = 4

#import "MADrawRect.h"
#import "MAMagnifierView.h"
#import "MagnifierView.h"
@interface MADrawRect()

@property (strong, nonatomic) NSTimer *touchTimer;
@property (strong, nonatomic) MAMagnifierView *magnifierView;

@end
    

@implementation MADrawRect{
    int counter;
}

@synthesize pointD = _pointD;
@synthesize pointC = _pointC;
@synthesize pointB = _pointB;
@synthesize pointA = _pointA;
@synthesize bg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setPoints];
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeRedraw];
        
        _pointD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pointD setTag:4];
        [_pointD setShowsTouchWhenHighlighted:YES];
        [_pointD addTarget:self action:@selector(pointMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_pointD addTarget:self action:@selector(pointMoveEnter:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_pointD addTarget:self action:@selector(pointMoveExit:withEvent:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside];
        
        [_pointD setImage:[self squareButtonWithWidth:100] forState:UIControlStateNormal];
        [_pointD setAccessibilityLabel:@"Draggable Crop Button Upper Left hand Corner. Double tap & hold to drag and adjust image frame."];
//        _pointD.backgroundColor = [UIColor redColor];
        [self addSubview:_pointD];
        
        _pointC = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pointC setTag:3];
        [_pointC setShowsTouchWhenHighlighted:YES];
        [_pointC addTarget:self action:@selector(pointMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_pointC addTarget:self action:@selector(pointMoveEnter:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_pointC addTarget:self action:@selector(pointMoveExit:withEvent:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside];
        [_pointC setImage:[self squareButtonWithWidth:100] forState:UIControlStateNormal];
        [_pointC setAccessibilityLabel:@"Draggable Crop Button Upper Right hand Corner."];
//        _pointC.backgroundColor = [UIColor blueColor];
        [self addSubview:_pointC];
        
        _pointB = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pointB setTag:2];
        [_pointB setShowsTouchWhenHighlighted:YES];
        [_pointB addTarget:self action:@selector(pointMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_pointB addTarget:self action:@selector(pointMoveEnter:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_pointB addTarget:self action:@selector(pointMoveExit:withEvent:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside];
        [_pointB setImage:[self squareButtonWithWidth:100] forState:UIControlStateNormal];
        [_pointB setAccessibilityLabel:@"Draggable Crop Button Bottom Right hand Corner."];
        [self addSubview:_pointB];
        
        _pointA = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pointA setTag:1];
        [_pointA setShowsTouchWhenHighlighted:YES];
        [_pointA addTarget:self action:@selector(pointMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_pointA addTarget:self action:@selector(pointMoveEnter:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_pointA addTarget:self action:@selector(pointMoveExit:withEvent:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside];
        [_pointA setImage:[self squareButtonWithWidth:100] forState:UIControlStateNormal];
        [_pointA setAccessibilityLabel:@"Draggable Crop Button Bottom Left hand Corner."];
        [self addSubview:_pointA];
        
        [_pointA setShowsTouchWhenHighlighted:NO];
        [_pointB setShowsTouchWhenHighlighted:NO];
        [_pointC setShowsTouchWhenHighlighted:NO];
        [_pointD setShowsTouchWhenHighlighted:NO];
        
        [self setButtons];
        counter = 0;
        
//        UIPanGestureRecognizer* panreco = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//        [self addGestureRecognizer:panreco];
    }
    return self;
}

//-(void) handlePan:(id)sender{
//    UIPanGestureRecognizer* reco = sender;
//    
//    if (self.magnifierView == nil) {
//        self.magnifierView = [[MAMagnifierView alloc] init];
//        self.magnifierView.viewToMagnify = self.superview;
//        [self showLoupe:nil];
//    }
//    self.magnifierView.pointToMagnify = [reco locationInView:self];
//    if (counter >= 2){
//    [self.magnifierView setNeedsDisplay];
//        counter = 0;
//    }else{
//        counter++;
//    }
//}

- (UIImage *)squareButtonWithWidth:(int)width
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

- (void)setPoints
{
    a = CGPointMake(0 + 10, self.bounds.size.height - 10);
    b = CGPointMake(self.bounds.size.width - 10, self.bounds.size.height - 10);
    c = CGPointMake(self.bounds.size.width - 10, 0 + 10);
    d = CGPointMake(0 + 10, 0 + 10);
}

- (void)setButtons
{
    [_pointD setFrame:CGRectMake(d.x - kCropButtonSize / 2, d.y - kCropButtonSize / 2, kCropButtonSize, kCropButtonSize)];
    [_pointC setFrame:CGRectMake(c.x - kCropButtonSize / 2,c.y - kCropButtonSize / 2, kCropButtonSize, kCropButtonSize)];
    [_pointB setFrame:CGRectMake(b.x - kCropButtonSize / 2, b.y - kCropButtonSize / 2, kCropButtonSize, kCropButtonSize)];
    [_pointA setFrame:CGRectMake(a.x - kCropButtonSize / 2, a.y - kCropButtonSize / 2, kCropButtonSize, kCropButtonSize)];
}

- (void)bottomLeftCornerToCGPoint: (CGPoint)point
{
    a = point;
    [self needsRedraw];
}

- (void)bottomRightCornerToCGPoint: (CGPoint)point
{
    b = point;
    [self needsRedraw];
}

- (void)topRightCornerToCGPoint: (CGPoint)point
{
    c = point;
    [self needsRedraw];
}

- (void)topLeftCornerToCGPoint: (CGPoint)point
{
    d = point;
    [self needsRedraw];
}

- (void)needsRedraw
{
    frameMoved = YES;
    [self setNeedsDisplay];
    [self setButtons];
//    [self drawRect:self.bounds];
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context)
    {
        
        // [UIColor colorWithRed:0.52f green:0.65f blue:0.80f alpha:1.00f];
        
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.7f);
        CGContextSetRGBStrokeColor(context, 1.00f, 0.43f, 0.08f, 1.0f);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 4.0f);
        
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextFillRect(context, boundingRect);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, a.x, a.y);
        CGPathAddLineToPoint(pathRef, NULL, b.x, b.y);
        CGPathAddLineToPoint(pathRef, NULL, c.x, c.y);
        CGPathAddLineToPoint(pathRef, NULL, d.x, d.y);
        CGPathCloseSubpath(pathRef);
        
        
        
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGPathRelease(pathRef);
    }
}

- (IBAction) pointMoveEnter:(id) sender withEvent:(UIEvent *) event
{
    UIControl *control = sender;
    CGPoint raw = [[[event allTouches] anyObject] locationInView:self];
    touchOffset = CGPointMake( raw.x - control.center.x, raw.y - control.center.y);
    
    if (self.magnifierView == nil) {
        self.magnifierView = [[MAMagnifierView alloc] init];
        self.magnifierView.viewToMagnify = self.superview;
    }
    self.magnifierView.pointToMagnify = [self GetPoint:control];
    [self showLoupe:nil];
    [self.magnifierView setNeedsDisplay];
}

-(CGPoint)GetPoint:(id)sender
{
    UIControl* control = (UIControl*)sender;
    CGPoint buttonPoint;
    switch (control.tag) {
        case 1:
            buttonPoint = a;
            break;
        case 2:
            buttonPoint = b;
            break;
        case 3:
            buttonPoint = c;
            break;
        case 4:
            buttonPoint = d;
            break;
    }
    
    CGPoint newP = CGPointMake(self.frame.origin.x+buttonPoint.y,
                               self.frame.origin.y+self.frame.size.height - buttonPoint.x - 20);
    return newP;
}

- (IBAction) pointMoved:(id) sender withEvent:(UIEvent *) event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    point = CGPointMake(point.x - touchOffset.x, point.y - touchOffset.y);
    
    self.magnifierView.pointToMagnify = [self GetPoint:sender];

    [self.magnifierView setNeedsDisplay];
    
    if (CGRectContainsPoint(self.bounds, point))
    {
        frameMoved = YES;
        UIControl *control = sender;
        

        switch (control.tag) {
            case 1:{
                point.x = fminf(point.x, fminf(c.x, b.x));
                point.y = fmaxf(point.y, fmaxf(d.y, c.y));
                a = point;
                break;
            }
            case 2:
                point.x = fmaxf(point.x, fmaxf(d.x, a.x));
                point.y = fmaxf(point.y, fmaxf(d.y, c.y));
                b = point;
                break;
            case 3:
                point.x = fmaxf(point.x, fmaxf(d.x, a.x));
                point.y = fminf(point.y, fminf(b.y, a.y));
                c = point;
                break;
            case 4:
                point.x = fminf(point.x, fminf(c.x, b.x));
                point.y = fminf(point.y, fminf(a.y, b.y));
                d = point;
                break;
        }
        control.center = point;
//        [self setNeedsDisplay];
//        [self drawRect:self.bounds];
    }
    else
    {
        float kLineOffsetWidth = 2.0f;
        
        if (point.x < kLineOffsetWidth || point.x > self.bounds.size.width - kLineOffsetWidth)
        {
            if (point.x < kLineOffsetWidth)
            {
                point.x = kLineOffsetWidth;
            }
            else if (point.x > self.bounds.size.width - kLineOffsetWidth)
            {
                point.x = self.bounds.size.width - kLineOffsetWidth;
            }
        }
        
        if (point.y < kLineOffsetWidth || point.y > self.bounds.size.height - kLineOffsetWidth)
        {
            if (point.y < kLineOffsetWidth)
            {
                point.y = kLineOffsetWidth;
            }
            else if (point.y > self.bounds.size.height)
            {
                point.y = self.bounds.size.height - kLineOffsetWidth;
            }
        }
        
        frameMoved = YES;
        UIControl *control = sender;
        
        
        
        switch (control.tag) {
            case 1:{
                point.x = fminf(point.x, fminf(c.x, b.x));
                point.y = fmaxf(point.y, fmaxf(d.y, c.y));
                a = point;
                break;
            }
            case 2:
                point.x = fmaxf(point.x, fmaxf(d.x, a.x));
                point.y = fmaxf(point.y, fmaxf(d.y, c.y));
                b = point;
                break;
            case 3:
                point.x = fmaxf(point.x, fmaxf(d.x, a.x));
                point.y = fminf(point.y, fminf(b.y, a.y));
                c = point;
                break;
            case 4:
                point.x = fminf(point.x, fminf(c.x, b.x));
                point.y = fminf(point.y, fminf(a.y, b.y));
                d = point;
                break;
        }
        control.center = point;
//        [self drawRect:self.bounds];
    }
    [self setNeedsDisplay];
}

- (void)showLoupe:(NSTimer *)timer
{
    [self.superview.superview addSubview:self.magnifierView];
}

- (IBAction) pointMoveExit:(id) sender withEvent:(UIEvent *) event
{
    NSLog(@"touch exit");
    touchOffset = CGPointZero;
    [self.magnifierView removeFromSuperview];
}

- (void) resetFrame
{
    [self setPoints];
    [self setNeedsDisplay];
//    [self drawRect:self.bounds];
    frameMoved = NO;
    [self setButtons];
}

- (BOOL) frameEdited
{
    return frameMoved;
}

- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor
{
    CGPoint tmp = CGPointMake(0, 0);
    
    switch (point) {
        case 1:
            tmp = CGPointMake(a.x / scaleFactor, a.y / scaleFactor);
            break;
        case 2:
            tmp = CGPointMake(b.x / scaleFactor, b.y / scaleFactor);
            break;
        case 3:
            tmp = CGPointMake(c.x / scaleFactor, c.y / scaleFactor);
            break;
        case 4:
            tmp =  CGPointMake(d.x / scaleFactor, d.y / scaleFactor);
            break;
    }
    
    //NSLog(@"%@", NSStringFromCGPoint(tmp));
    
    return tmp;
}

@end

