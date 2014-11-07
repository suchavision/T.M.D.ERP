#import "EventManager.h"
#import "AppInterface.h"

@implementation EventManager

static EventManager* sharedInstance;

@synthesize adminAction;


+(void)initialize {
    if (self == [EventManager class]) {
        sharedInstance = [[EventManager alloc] init];
    }
}

+(EventManager*) getInstance {
    return sharedInstance;
}



-(void) initialiazeAdministerProcedure {
    self.adminAction = [[AdministratorAction alloc] init];
}

-(void) destroyReleaseableProcedure {
    self.adminAction = nil;
}







@end
