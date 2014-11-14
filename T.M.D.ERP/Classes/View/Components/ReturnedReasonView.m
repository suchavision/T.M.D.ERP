#import "ReturnedReasonView.h"
#import "AppInterface.h"


@implementation ReturnedReasonView



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView* bgImageView = [PopupTableHelper getCommonPopupBackgroundImageView];
        self.bounds = (CGRect){frame.origin, bgImageView.size};
        [self addSubview: bgImageView];
        
        // sure button
        JRButton* sureButton = [[JRButton alloc] initWithFrame:CanvasRect(330, 5, 84, 46)];
        [sureButton setBackgroundImage:[UIImage imageNamed:@"Pushbutton_08.png"] forState:UIControlStateNormal];
        [sureButton setTitle:LOCALIZE_KEY(@"OK") forState:UIControlStateNormal];
        [bgImageView addSubview: sureButton];
        
        // sure button
        JRButton* cancelButton = [[JRButton alloc] initWithFrame:CanvasRect(20, 5, 84, 46)];
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"Pushbutton_08.png"] forState:UIControlStateNormal];
        [cancelButton setTitle:LOCALIZE_KEY(@"CANCEL") forState:UIControlStateNormal];
        [bgImageView addSubview: cancelButton];
        
        // title label
        JRLabel* titleLabel = [[JRLabel alloc] initWithFrame:CanvasRect(0, 10, 200, 46)];
        [titleLabel setCenterX: [bgImageView sizeWidth] / 2 + CanvasW(50)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = APPLOCALIZE_KEYS(@"RETURN", @"reason");
        [bgImageView addSubview: titleLabel];
        
        // textfield
        JRTextView* textView = [[JRTextView alloc] initWithFrame:CanvasRect(20, 65, 0, 0)];
        [textView setSize:(CGSize){bgImageView.size.width - CanvasW(40), bgImageView.size.height - CanvasH(100)}];
        [bgImageView addSubview: textView];
//        [ColorHelper setBorder: textView color:[UIColor grayColor]];
        
        
        self.rightButton = sureButton;
        self.leftButton = cancelButton;
        self.reasonTextView = textView;
        
    }
    return self;
}


@end
