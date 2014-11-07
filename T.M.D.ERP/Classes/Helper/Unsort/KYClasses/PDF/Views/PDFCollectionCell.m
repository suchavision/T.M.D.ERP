#import "PDFCollectionCell.h"
#import "AppInterface.h"


@implementation PDFCollectionCell
{
    UIImageView* _selectedIcon;
    UIImageView* _fileImageView;
    
    UILabel* _label;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        
        self.backgroundColor = [UIColor grayColor];
//        [ColorHelper setBorder: self];
//        [LayerHelper setBasicAttributes: self.layer config:@{@"borderWidth":@(1), @"borderColor":[UIColor greenColor], @"shadowRadius": @(10)}];
    }
    return self;
}



-(void)setIsDirectory:(BOOL)isDirectory
{
    _isDirectory = isDirectory;
    
    NSString* imageName = isDirectory ? @"directory_icon" : @"pdf_icon";
    UIImageView* imageView = [self getFileImageView];
    imageView.image = [UIImage imageNamed:imageName];
    
    [imageView setCenterX: self.frame.size.width / 2];
    [imageView setCenterY: (self.frame.size.height - [[self getLabel] sizeHeight]) / 2];
}


-(void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    
    UILabel* label = [self getLabel];
    label.text = fileName;
    
    [label adjustWidthToFontText];
    
    if ([label sizeWidth] > self.frame.size.width) {
        [label setSizeWidth: self.frame.size.width];
    }
    
    [label setCenterX: self.frame.size.width / 2];
    [label setOriginY: self.frame.size.height - [label sizeHeight]];
}


-(void)singleTap:(id)sender
{
    if (self.cellTapAction) {
        self.cellTapAction(self);
    }
}

-(void) showDeleteIcon
{
    UIImageView* imageView = [self getIconView];
    imageView.image = [UIImage imageNamed:@"selectionIconDelete.png"]; ;
    imageView.hidden = NO;
}

-(void) showSaveIcon
{
    UIImageView* imageView = [self getIconView];
    imageView.image = [UIImage imageNamed:@"selectionIconSave.png"]; ;
    imageView.hidden = NO;
}

-(void) showIcon
{
    [self getIconView].hidden = NO;
}

-(void) hideIcon
{
    [self getIconView].hidden = YES;
}


-(UIImageView*) getIconView
{
    if (!_selectedIcon) {
        _selectedIcon = [[UIImageView alloc] init];
        _selectedIcon.frame = CanvasRect(150, 85, 70, 70);
        [self addSubview:_selectedIcon];
        [_selectedIcon setHidden:YES];
    }
    _selectedIcon.image = [UIImage imageNamed:@"selectionIcon.png"];
    return _selectedIcon;
}


-(UILabel*) getLabel
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        [_label setFrame: CanvasRect(0, 0, 140, 100)];
        _label.font = [UIFont systemFontOfSize: CanvasFontSize(20)];
        _label.numberOfLines = 0;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return _label;
}

-(UIImageView*) getFileImageView
{
    if (! _fileImageView) {
        _fileImageView = [[UIImageView alloc] init];
        _fileImageView.frame = CanvasRect(0, 0, 220, 220);
        _fileImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_fileImageView];
    }
    return _fileImageView;
}

@end
