#import "JsonControllerSeverHelper.h"

#import "AppInterface.h"


@implementation JsonControllerSeverHelper


+(void) startReturnOrderRequest: (NSString*)orderType department:(NSString*)department valueObjects:(NSDictionary*)valueObjects identities:(NSDictionary*)identities reason:(NSString*)reason
{
    NSMutableDictionary* objects = [NSMutableDictionary dictionary];
    NSString* currentApprovingLevel = [JsonControllerHelper getCurrentApprovingLevel: orderType valueObjects:valueObjects];
    NSString* currentHasApprovedLevel = [JsonControllerHelper getPreviousAppLevel: currentApprovingLevel];
    NSString* forwardUser = valueObjects[currentHasApprovedLevel];
    
    if ([valueObjects[PROPERTY_RETURNED] boolValue]) {
        
        if (! currentHasApprovedLevel || [currentHasApprovedLevel isEqualToString:PROPERTY_CREATEUSER]) {
            DLog(@"The last one , can not return ~~~~~~");
            [VIEW.progress show];
            VIEW.progress.mode = MBProgressHUDModeText;
            VIEW.progress.detailsLabelText =  APPLOCALIZE_KEYS(@"cannot", @"RETURN");
            [VIEW.progress hide: YES afterDelay:2];
            return;
        }
        
        if (! OBJECT_EMPYT(valueObjects[currentHasApprovedLevel])) {
            if ([MODEL.signedUserName isEqualToString:valueObjects[currentHasApprovedLevel]]) {
                [objects setObject:@"" forKey:currentHasApprovedLevel];
            }
        }
        
    }
    
    [objects setObject: [NSNumber numberWithBool:true] forKey:PROPERTY_RETURNED];
    [objects setObject: forwardUser forKey:PROPERTY_FORWARDUSER];
    
    
    [VIEW.progress show];
    VIEW.progress.detailsLabelText = APPLOCALIZE_KEYS(@"In_Process", @"RETURN");
    
    
    // modify the return field
    [AppServerRequester modifyModel: orderType department:department objects:objects identities:identities completeHandler:^(ResponseJsonModel *response, NSError *error) {
        
        BOOL isSuccess = response.status;
        
        VIEW.progress.detailsLabelText = nil;
        VIEW.progress.labelText = [NSString stringWithFormat:@"%@%@", LOCALIZE_KEY(@"RETURN"), isSuccess ? LOCALIZE_KEY(@"success") : LOCALIZE_KEY(@"failed")];
        
        if (response.status) {
            
            
            // save the reason
            
            RequestJsonModel* jsonModel = [RequestJsonModel getJsonModel];
            jsonModel.path = PATH_LOGIC_CREATE(@"Approval");
            [jsonModel addModel:@"ApprovalsReturnedRecord"];
            [jsonModel addObject:@{@"orderType": orderType, @"orderNO": valueObjects[@"orderNO"], @"reason": reason}];
            [MODEL.requester startPostRequest: jsonModel completeHandler:^(HTTPRequester *requester, ResponseJsonModel *response, NSHTTPURLResponse *httpURLReqponse, NSError *error) {
                
                NSString* applevel = currentHasApprovedLevel;
                NSString* actionKey = @"RETURN";
                if ([applevel isEqualToString: PROPERTY_CREATEUSER]) {
                    applevel = @"create";
                }
                NSString* apnsMessage = LOCALIZE_MESSAGE_FORMAT(@"YourOrderHaveBeenReturned", forwardUser, LOCALIZE_KEY(applevel), LOCALIZE_KEY(orderType), LOCALIZE_KEY(actionKey));
                [self startInformRequest:actionKey orderType:orderType department:department identities:identities forwardUser:forwardUser apnsMessage:apnsMessage];
                
            }];
            

            
            
        } else {
            [VIEW.progress hideAfterDelay: 2];
        }
        
    }];
}



+(void) startInformRequest: (NSString*)actionKey orderType:(NSString*)orderType department:(NSString*)department identities:(NSDictionary*)identities forwardUser:(NSString*)forwardUser apnsMessage:(NSString*)apnsMessage
{
    // when the Action successfully , then will do the following
    VIEW.progress.labelText = [NSString stringWithFormat:@"%@%@", LOCALIZE_KEY(actionKey), LOCALIZE_KEY(@"success")];
    __block NSString* detailsLabelText = nil;
    
    if (forwardUser) {
        NSString* forwardUserRealName = [ViewControllerHelper getUserName: forwardUser];
        if (! VIEW.isProgressShowing) [VIEW.progress show];
        VIEW.progress.detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"SendingNotification", forwardUserRealName, forwardUser);
        
        NSDictionary* contents = [AppDataHelper getApnsContents: department order:orderType identities:identities forwardUser:forwardUser alert:apnsMessage];
        
        [AppServerRequester sendInform: forwardUser contents:contents completeHandler:^(ResponseJsonModel *response, NSError *error) {
            BOOL isSuccessfully = response.status;
            detailsLabelText = LOCALIZE_MESSAGE_FORMAT(@"SendNotificationStatus", forwardUser, isSuccessfully ? LOCALIZE_KEY(@"success") : LOCALIZE_KEY(@"failed"));
            
            if (isSuccessfully) {
                [self popViewControllerToListController:detailsLabelText];
            } else {
                [VIEW.progress hide];
                NSString* askReInformMessage = [detailsLabelText stringByAppendingFormat:@",%@", LOCALIZE_MESSAGE_FORMAT(@"REDO_YESORNO", LOCALIZE_KEY(@"SEND"), LOCALIZE_KEY(@"inform"))];
                [PopupViewHelper popAlert:LOCALIZE_KEY(@"FAILED") message:askReInformMessage style:0 actionBlock:^(UIView *popView, NSInteger index) {
                    NSString* buttonTitle = [(UIAlertView*)popView buttonTitleAtIndex: index];
                    if ([buttonTitle isEqualToString: LOCALIZE_KEY(@"YES")]) {
                        [self startInformRequest: actionKey orderType:orderType department:department identities:identities forwardUser:forwardUser apnsMessage:apnsMessage];
                    } else {
                        [self popViewControllerToListController:detailsLabelText];
                    }
                } dismissBlock:nil buttons:LOCALIZE_KEY(@"NO"), LOCALIZE_KEY(@"YES"), nil];
            }
        }];
    } else {
        [self popViewControllerToListController:detailsLabelText];
    }
}
+(void) popViewControllerToListController:(NSString*)detailsLabelText
{
    VIEW.progress.detailsLabelText = detailsLabelText;
    [VIEW.progress setupCompletedView: YES];
    [VIEW.progress hideAfterDelay: 2];
    [VIEW.navigator popViewControllerAnimated: YES];
}


@end
