#import "AppWheelViewController.h"
#import "AppInterface.h"

@implementation AppWheelViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = LOCALIZE_KEY(@"wheel");
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.config) {
        self.config = MODEL.config[@"WHEELS"][@"Common"];
    }
    
    // swipe
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    [self.view  addGestureRecognizer:swipeGesture];
    
    // background
    UIView* backgroundView = [JsonViewRenderHelper render:nil specifications: self.config[@"WHEELS_BACKGROUNDVIEW"]];
    backgroundView.userInteractionEnabled = NO;
    [self.view addSubview: backgroundView];
    
    //configure carousel
    _carousel = [[Carousel alloc] initWithFrame: self.view.bounds];
    _carousel.backgroundColor = [UIColor clearColor];
    _carousel.dataSource = self;
    _carousel.delegate = self;
    _carousel.type = iCarouselTypeRotary;
    _carousel.vertical = YES;
    [self.view addSubview: _carousel];
}

-(void)didSwipeRight:(id)sender
{
    if (self.wheelDidSwipRightBlock) {
       self.wheelDidSwipRightBlock(self, sender);
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) didTapOrSwipeLeftCarouselItemAtIndex:(NSInteger)index {
    if (self.wheelDidTapSwipLeftBlock) self.wheelDidTapSwipLeftBlock(self, index);
}



#pragma mark iCarousel methods


- (NSUInteger)numberOfItemsInCarousel:(Carousel *)carousel
{
    return self.wheels.count;
}

- (UIView *)carousel:(Carousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSString* key = [self.wheels objectAtIndex: index];
    NSDictionary* componentsConfig = self.config[@"WHEELS_VIEWS"];
    NSDictionary* componemtConfig = [DictionaryHelper combines:componentsConfig[@"DEFAULT"] with:componentsConfig[key]];
    UIView* renderView = [JsonViewRenderHelper render:nil specifications:componemtConfig];
    
    // set the localize
    JRLocalizeLabel* label = (JRLocalizeLabel*)[JsonViewIterateHelper getViewWithKeyPath: @"LABEL" on:renderView];
    label.text = APPLOCALIZE(key);
    [label resizeWidth];
    [label setCenter:[label.superview middlePoint]];
    
    return renderView;
}

- (void)carousel:(Carousel *)carousel didTapItemAtIndex:(NSInteger)index {
    [self didTapOrSwipeLeftCarouselItemAtIndex: index];
}

- (void)carousel:(Carousel *)carousel didSwipeItemAtIndex:(NSInteger)index {
    [self didTapOrSwipeLeftCarouselItemAtIndex: index];
}



@end
