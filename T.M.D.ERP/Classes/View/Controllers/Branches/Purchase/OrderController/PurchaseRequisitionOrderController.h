//
//  PurchaseRequisitionOrderController.h
//  T.M.D.ERP
//
//  Created by wudonghui on 11/5/14.
//  Copyright (c) 2014 Xinyuan4. All rights reserved.
//

#import "JsonController.h"

@interface PurchaseRequisitionOrderController : JsonController
@property (strong, readonly) NSMutableArray* requisitionTableViewDataSource;
@end
