#import "AppImagePickerController.h"
#import "AppInterface.h"


@interface AppImagePickerController() <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end


@implementation AppImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (self.supportedInterfaceOrientationsAction) {
        return self.supportedInterfaceOrientationsAction(self);
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.preferredInterfaceOrientationForPresentationAction) {
        return self.preferredInterfaceOrientationForPresentationAction(self);
    }
    return UIInterfaceOrientationPortrait;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.didRotateFromOrientation) {
        self.didRotateFromOrientation(self, fromInterfaceOrientation);
    }
}


-(BOOL)shouldAutorotate
{
    if (self.shouldAutorotateAction) {
        return self.shouldAutorotateAction(self);
    }
    return YES;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (self.didFinishPickingImage) {
        UIImage* pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.didFinishPickingImage(self, pickedImage);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.didCancelPickingImage) {
        self.didCancelPickingImage(self);
    }
}

#pragma UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.willShowViewController) {
        self.willShowViewController(self, animated);
    }
}



@end
