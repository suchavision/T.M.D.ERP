#import "BaseJRTableViewCell.h"
#import "AppInterface.h"

@implementation BaseJRTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Render
-(NSDictionary*)assembleCellSpecifications:(NSString*)order
{
    NSString* controllerSuffix = json_FILE_CONTROLLER_SUFIX;
    NSString* controllerFileName = [order stringByAppendingString:controllerSuffix];
    NSMutableDictionary* cellSpecifications = [DictionaryHelper deepCopy: [JsonFileManager getJsonFromFile: controllerFileName]];
    NSDictionary* specConfig = cellSpecifications[@"Specifications"];
    return specConfig;
}

-(void)renderCellSubView:(NSString*)order
{
    NSDictionary* specConfig = [self assembleCellSpecifications:order];
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        NSArray* frame = [specConfig[@"TableCellElementsFrames"] safeObjectAtIndex: i];
        JRTextField* jrTxtField = (JRTextField*)[self.contentView.subviews objectAtIndex: i];
        [FrameHelper setComponentFrame: frame component:jrTxtField];
        // subRender
        if ([jrTxtField conformsToProtocol:@protocol(JRComponentProtocal)]) {
            [((id<JRComponentProtocal>)jrTxtField) subRender: [specConfig[@"TableCellElementsSubRenders"] safeObjectAtIndex: i]];
        }
        // attribute
        [jrTxtField setAttribute:[specConfig[@"TableCellElementsAttribute"] safeObjectAtIndex: i]];
    }
}
-(void)renderFooterCellSubView:(NSString*)order
{
    NSDictionary* specConfig = [self assembleCellSpecifications:order];
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        NSArray* frame = [specConfig[@"FooterTableCellElementsFrames"] safeObjectAtIndex: i];
        JRTextField* jrTxtField = (JRTextField*)[self.contentView.subviews objectAtIndex: i];
        [FrameHelper setComponentFrame: frame component:jrTxtField];
        // subRender
        if ([jrTxtField conformsToProtocol:@protocol(JRComponentProtocal)]) {
            [((id<JRComponentProtocal>)jrTxtField) subRender: [specConfig[@"FooterTableCellElementsSubRenders"] safeObjectAtIndex: i]];
        }
        // attribute
        [jrTxtField setAttribute:[specConfig[@"FooterTableCellElementsAttribute"] safeObjectAtIndex: i]];
    }
}


#pragma mark -
#pragma mark - Handle

-(void)setDatas:(id)cotents
{
    if ([cotents isKindOfClass: [NSDictionary class]]) {
        [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
            JRTextField* tx = (JRTextField*)subView;
            id value = [cotents objectForKey: tx.attribute];
            [tx setValue: value];
            return NO;
        }];
        
    } else if ([cotents isKindOfClass: [NSArray class]]) {
        for (int i = 0; i < [cotents count]; i++) {
            id value = cotents[i];
            JRTextField* tx = self.contentView.subviews[i];
            [tx setValue: value];
            
        }
    }
}
-(id)getDatas
{
    NSMutableDictionary* values = [NSMutableDictionary dictionary];
    NSMutableArray* results = [NSMutableArray array];
    
    [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
        JRTextField* tx = (JRTextField*)subView;
        id value = [tx getValue];
        NSString* key = tx.attribute;
        if (value && key) {
            [values setObject: value forKey:key];
        } else {
            if (!value) value = @"";
            [results addObject: value];
        }
        return NO;
    }];
    
    return values.count ? values : results;
    
}


@end
