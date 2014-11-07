#import <UIKit/UIKit.h>

@class PDFCollectionCell;

@interface PDFCollectionCell : UICollectionViewCell

@property(nonatomic, assign) BOOL isDirectory;

@property(nonatomic, strong) NSString* fileName;

@property(nonatomic, copy) void (^cellTapAction)(PDFCollectionCell* cell) ;


-(void) showDeleteIcon;
-(void) showSaveIcon;

-(void) showIcon;

-(void) hideIcon;


@end
