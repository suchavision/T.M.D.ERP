//
//  MAImagePickerControllerAdjustViewController.m
//  instaoverlay
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAImagePickerControllerAdjustViewController.h"
#import "MAImagePickerFinalViewController.h"

#import "MAOpenCV.h"
#import "UIImageView+ContentFrame.h"
#import <QuartzCore/QuartzCore.h>
#import "TouchReader.h"
#import "UIImage+fixOrientation.h"

@interface MAImagePickerControllerAdjustViewController ()


@end

@implementation MAImagePickerControllerAdjustViewController

@synthesize sourceImageView = _sourceImageView;
@synthesize adjustToolBar = _adjustToolBar;
@synthesize sourceImage = _sourceImage;
@synthesize adjustedImage = _adjustedImage;
@synthesize adjustRect = _adjustRect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:backgroundView];
    
    _sourceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kCameraToolBarHeight)];
    [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];

    _adjustedImage = _sourceImage;
    
    /* hack here */
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, -M_PI_2);
    _sourceImageView.transform = rotationTransform;
    /* hack end*/
    
    [_sourceImageView setImage:_adjustedImage];

    [self.view addSubview:_sourceImageView];
    
    _adjustRect= [[MADrawRect alloc] initWithFrame:_sourceImageView.contentFrame];
//    [_adjustRect.bg setImage:_sourceImage];
    _adjustRect.transform = rotationTransform;
    [self.view addSubview:_adjustRect];
    
    _adjustToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kCameraToolBarHeight, self.view.bounds.size.width, kCameraToolBarHeight)];
    [_adjustToolBar setBackgroundImage:[UIImage imageNamed:@"camera-bottom-bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-button"] style:UIBarButtonItemStylePlain target:self action:@selector(popCurrentViewController)];
    cancelButton.accessibilityLabel = @"Return to Camera Viewer";
    
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-icon-crop"] style:UIBarButtonItemStylePlain target:self action:@selector(resetRectFrame)];
    undoButton.accessibilityLabel = @"Reset Frame";
    
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"confirm-button"] style:UIBarButtonItemStylePlain target:self action:@selector(confirmedImage)];
    confirmButton.accessibilityLabel = @"Confirm adjusted Image";
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:10.0f];
    
    [_adjustToolBar setItems:[NSArray arrayWithObjects:fixedSpace,cancelButton,flexibleSpace,undoButton,flexibleSpace,confirmButton,fixedSpace, nil]];
    
    [self.view addSubview:_adjustToolBar];
    
    //    TouchReader* touchMagnifier = [[TouchReader alloc] initWithFrame:self.view.bounds];
    //    touchMagnifier.userInteractionEnabled = YES;
    //    touchMagnifier.alpha = 0;
    //    [self.view addSubview:touchMagnifier];
    
    [self detectEdges];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_adjustRect frameEdited])
    {
        _adjustedImage = _sourceImage;
        [_sourceImageView setImage:_adjustedImage];
    }
}

- (void)popCurrentViewController
{    
    [self.navigationController popViewControllerAnimated:NO];

    _adjustRect = nil;
    _adjustToolBar = nil;
    _adjustedImage = nil;
    _sourceImage = nil;
}

- (void)resetRectFrame
{
    _adjustedImage = _sourceImage;
    [_sourceImageView setImage:_adjustedImage];
    [_adjustRect setHidden:NO];
    [_adjustRect resetFrame];
}

- (void)detectEdges
{

    cv::Mat original = [MAOpenCV cvMatFromUIImage:_adjustedImage];
    CGSize targetSize = _sourceImageView.contentSize;
    cv::resize(original, original, cvSize(targetSize.width, targetSize.height));
    cv::vector<cv::vector<cv::Point>>squares;
    cv::vector<cv::Point> largest_square;
    
    find_squares(original, squares);
    find_largest_square(squares, largest_square);
//    if (largest_square.size() < 4){
//        hough_search(original, largest_square);
//    }
    if (largest_square.size() == 4)
    {
        
        // Manually sorting points, needs major improvement. Sorry.
        
        NSMutableArray *points = [NSMutableArray array];
        NSMutableDictionary *sortedPoints = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < 4; i++)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:CGPointMake(largest_square[i].x, largest_square[i].y)], @"point" , [NSNumber numberWithInt:(largest_square[i].x + largest_square[i].y)], @"value", nil];
            [points addObject:dict];
        }
        
        int min = [[points valueForKeyPath:@"@min.value"] intValue];
        int max = [[points valueForKeyPath:@"@max.value"] intValue];
        
        int minIndex;
        int maxIndex;
        
        int missingIndexOne;
        int missingIndexTwo;
        
        for (int i = 0; i < 4; i++)
        {
            NSDictionary *dict = [points objectAtIndex:i];
            
            if ([[dict objectForKey:@"value"] intValue] == min)
            {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"0"];
                minIndex = i;
                continue;
            }
            
            if ([[dict objectForKey:@"value"] intValue] == max)
            {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"2"];
                maxIndex = i;
                continue;
            }
            
            NSLog(@"MSSSING %i", i);
            
            missingIndexOne = i;
        }
        
        for (int i = 0; i < 4; i++)
        {
            if (missingIndexOne != i && minIndex != i && maxIndex != i)
            {
                missingIndexTwo = i;
            }
        }
        
        
        if (largest_square[missingIndexOne].x < largest_square[missingIndexTwo].x)
        {
            //2nd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"3"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"1"];
        }
        else
        {
            //4rd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"1"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"3"];
        }
        
        
        [_adjustRect topLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"0"] CGPointValue]];
        [_adjustRect topRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"1"] CGPointValue]];
        [_adjustRect bottomRightCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"2"] CGPointValue]];
        [_adjustRect bottomLeftCornerToCGPoint:[(NSValue *)[sortedPoints objectForKey:@"3"] CGPointValue]];
    }

    original.release();

    /*
    [_sourceImageView setNeedsDisplay];
    [_sourceImageView setImage:[MAOpenCV UIImageFromCVMat:original]];
    [_sourceImageView setContentMode:UIViewContentModeScaleAspectFit];
     */
}

- (void)confirmedImage
{
    BOOL edited;
    if ([_adjustRect frameEdited])
    {
        //cv::GaussianBlur(original, original, cvSize(11,11), 0);
        //cv::adaptiveThreshold(original, original, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 5, 2);
        
        CGFloat scaleFactor =  [_sourceImageView contentScale];
        CGPoint ptBottomLeft = [_adjustRect coordinatesForPoint:1 withScaleFactor:scaleFactor];
        CGPoint ptBottomRight = [_adjustRect coordinatesForPoint:2 withScaleFactor:scaleFactor];
        CGPoint ptTopRight = [_adjustRect coordinatesForPoint:3 withScaleFactor:scaleFactor];
        CGPoint ptTopLeft = [_adjustRect coordinatesForPoint:4 withScaleFactor:scaleFactor];
        
        CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
        CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
        
        CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
        CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
        
        CGFloat maxWidth = (w1 < w2) ? w1 : w2;
        CGFloat maxHeight = (h1 < h2) ? h1 : h2;
        
        cv::Point2f src[4], dst[4];
        src[0].x = ptTopLeft.x;
        src[0].y = ptTopLeft.y;
        src[1].x = ptTopRight.x;
        src[1].y = ptTopRight.y;
        src[2].x = ptBottomRight.x;
        src[2].y = ptBottomRight.y;
        src[3].x = ptBottomLeft.x;
        src[3].y = ptBottomLeft.y;
        
//        src[0].x = ptBottomLeft.x;
//        src[0].y = ptBottomLeft.y;
//        src[1].x = ptBottomRight.x;
//        src[1].y = ptBottomRight.y;
//        src[2].x = ptTopRight.x;
//        src[2].x = ptTopRight.y;
//        src[3].x = ptTopLeft.x;
//        src[3].y = ptTopLeft.y;
        
        dst[0].x = 0;
        dst[0].y = 0;
        dst[1].x = maxWidth - 1;
        dst[1].y = 0;
        dst[2].x = maxWidth - 1;
        dst[2].y = maxHeight - 1;
        dst[3].x = 0;
        dst[3].y = maxHeight - 1;
        
        cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC1);
        cv::Mat original = [MAOpenCV cvMatFromUIImage:_adjustedImage];
        cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
        original.release();
        
        _adjustedImage = [MAOpenCV UIImageFromCVMat:undistorted];
        undistorted.release();
        edited = YES;
    }
    else
    {
        edited = NO;
    }
    
    MAImagePickerFinalViewController *finalView = [[MAImagePickerFinalViewController alloc] init];
    finalView.sourceImage = _adjustedImage;
    finalView.imageFrameEdited = edited;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:finalView animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

struct Line {
    cv::Point _p1;
    cv::Point _p2;
    cv::Point _center;
    
    Line(cv::Point p1, cv::Point p2) {
        _p1 = p1;
        _p2 = p2;
        _center = cv::Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
    }
};
bool cmp_y(const Line &p1, const Line &p2) {
    return p1._center.y < p2._center.y;
}

bool cmp_x(const Line &p1, const Line &p2) {
    return p1._center.x < p2._center.x;
}

void getCanny(cv::Mat gray, cv::Mat &canny) {
    cv::Mat thres;
    double high_thres = threshold(gray, thres, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU), low_thres = high_thres * 0.5;
    cv::Canny(gray, canny, low_thres, high_thres);
}

cv::Point2f computeIntersect(Line l1, Line l2) {
    int x1 = l1._p1.x, x2 = l1._p2.x, y1 = l1._p1.y, y2 = l1._p2.y;
    int x3 = l2._p1.x, x4 = l2._p2.x, y3 = l2._p1.y, y4 = l2._p2.y;
    if (float d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)) {
        cv::Point2f pt;
        pt.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
        pt.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
        return pt;
    }
    return cv::Point2f(-1, -1);
}

void hough_search(cv::Mat& image, cv::vector<cv::Point>& result){
    cv::Mat img_proc;
    int w = image.size().width, h = image.size().height, min_w = 200;
    double scale = fmin(10.0, w*1.0 / min_w);
    int w_proc = w*1.0 / scale, h_proc = h*1.0 / scale;
    resize(image, img_proc, cv::Size(w_proc, h_proc));
    //    cv::GaussianBlur(img_proc, img_proc, cv::Size(3, 3), 2.0, 2.0);
    cv::Mat img_dis = img_proc.clone();
    
    cv::Mat gray, canny;
    cvtColor(img_proc, gray, CV_BGR2GRAY);
    getCanny(gray, canny);
    
    cv::vector<cv::Vec4i> lines;
    cv::vector<Line> horizontals, verticals;
    cv::HoughLinesP(canny, lines, 1, CV_PI/180, w_proc / 6, w_proc / 4, 20);
    for (size_t i = 0; i < lines.size(); i++){
        cv::Vec4i v = lines[i];
        double delta_x = v[0] - v[2], delta_y= v[1] - v[3];
        Line l(cv::Point(v[0], v[1]), cv::Point(v[2], v[3]));
        
        if (fabs(delta_x) > fabs(delta_y)){
            horizontals.push_back(l);
        }else{
            verticals.push_back(l);
        }
        
        //        cv::line(img_proc, cv::Point(v[0],v[1]), cv::Point(v[2],v[3]), cv::Scalar(0,0,255));
    }
    
    if (horizontals.size() >= 2 && verticals.size() >= 2){
        std::sort(horizontals.begin(), horizontals.end(), cmp_x);
        std::sort(verticals.begin(), verticals.end(), cmp_y);
//        cv::Point2f a = computeIntersect(horizontals[0], verticals[0]);
//        cv::Point2f b = computeIntersect(horizontals[0], verticals[verticals.size() - 1]);
//        cv::Point2f c = computeIntersect(horizontals[horizontals.size()-1], verticals[0]);
//        cv::Point2f d = computeIntersect(horizontals[horizontals.size()-1], verticals[verticals.size()-1]);
        result.push_back(computeIntersect(horizontals[0], verticals[0]));
        result.push_back(computeIntersect(horizontals[0], verticals[verticals.size() - 1]));
        result.push_back(computeIntersect(horizontals[horizontals.size() - 1], verticals[0]));
        result.push_back(computeIntersect(horizontals[horizontals.size() - 1], verticals[verticals.size() - 1]));
        NSLog(@"hough!");
        for (size_t i=0; i < result.size(); i++){
            result[i].x *= scale;
            result[i].y *= scale;
        }
        cv::Rect r = cv::boundingRect(result);
        if (!(r.x > 0 && r.y > 0) || r.area() < 1000){
            result.clear();
        }
    }
}

// http://stackoverflow.com/questions/8667818/opencv-c-obj-c-detecting-a-sheet-of-paper-square-detection
void find_squares(cv::Mat& image, cv::vector<cv::vector<cv::Point>>&squares) {
    
    // blur will enhance edge detection
    cv::Mat blurred(image);
    medianBlur(image, blurred, 9);
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    cv::vector<cv::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
                Canny(gray0, gray, 10, 20, 3); //
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            cv::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

void find_largest_square(const cv::vector<cv::vector<cv::Point> >& squares, cv::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}


double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

cv::Mat debugSquares( std::vector<std::vector<cv::Point> > squares, cv::Mat image ){
    
    NSLog(@"DEBUG!/?!");
    for ( unsigned int i = 0; i< squares.size(); i++ ) {
        // draw contour
        
        NSLog(@"LOOP!");
        
        cv::drawContours(image, squares, i, cv::Scalar(255,0,0), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0,255,0), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points( rect_points );
        for ( int j = 0; j < 4; j++ ) {
            cv::line( image, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255), 1, 8 ); // blue
        }
    }
    
    return image;
}

@end
