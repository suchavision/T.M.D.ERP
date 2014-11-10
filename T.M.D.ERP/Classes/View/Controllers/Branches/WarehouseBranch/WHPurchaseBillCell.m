//
//  WHPurchaseBillCell.m
//  T.M.D.ERP
//
//  Created by wudonghui on 10/20/14.
//  Copyright (c) 2014 Xinyuan4. All rights reserved.
//

#import "WHPurchaseBillCell.h"
#import "AppInterface.h"
@interface WHPurchaseBillCell()
@property(nonatomic, strong) JRTextField* paymentDateTxtField;
@property(nonatomic, strong) JRTextField* relatedDocumentTxtField;
@property(nonatomic, strong) JRTextField* payablesTxtField;
@property(nonatomic, strong) JRTextField* currentPaymentTxtField;
@property(nonatomic, strong) JRTextField* unPaidTxtField;
@end
@implementation WHPurchaseBillCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _paymentDateTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(0, 0, 175, 50)];
        
        _relatedDocumentTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(175, 0, 266, 50)];
        
        _payablesTxtField    = [[JRTextField alloc] initWithFrame:CanvasRect(440, 0, 180, 50)];
        
        _currentPaymentTxtField   = [[JRTextField alloc] initWithFrame:CanvasRect(620, 0, 190, 50)];
        
        _unPaidTxtField  = [[JRTextField alloc] initWithFrame:CanvasRect(810, 0, 195, 50)];
    
        _paymentDateTxtField.textAlignment = NSTextAlignmentCenter;
        _relatedDocumentTxtField.textAlignment = NSTextAlignmentCenter;
        _payablesTxtField.textAlignment = NSTextAlignmentCenter;
        _currentPaymentTxtField.textAlignment = NSTextAlignmentCenter;
        _unPaidTxtField.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:_paymentDateTxtField];
        [self.contentView addSubview:_relatedDocumentTxtField];
        [self.contentView addSubview:_payablesTxtField];
        [self.contentView addSubview:_currentPaymentTxtField];
        [self.contentView addSubview:_unPaidTxtField];
        
        self.backgroundColor = [UIColor clearColor];
        
        [ViewHelper iterateSubView: self.contentView class:[JRTextField class] handler:^BOOL(id subView) {
            JRTextField* tx = (JRTextField*) subView;
            tx.enabled = NO;
            return NO;
        }];

        
    }
    return self;
}


-(void)setDatas:(id)cotents
{
    [super setDatas:cotents];
    float finalValue = [_payablesTxtField.text floatValue] - [_currentPaymentTxtField.text floatValue];
    NSString *finalValueString = [[NSNumber numberWithFloat:finalValue] stringValue];
    _unPaidTxtField.text = finalValueString;
}


@end
