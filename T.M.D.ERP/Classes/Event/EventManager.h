#import <Foundation/Foundation.h>

#define EVENT [EventManager getInstance]

@class AdministratorAction;

@interface EventManager : NSObject

@property (strong) AdministratorAction* adminAction;

+(EventManager*) getInstance ;

-(void) initialiazeAdministerProcedure ;
-(void) destroyReleaseableProcedure ;


@end
