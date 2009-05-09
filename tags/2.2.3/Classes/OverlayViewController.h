#import <UIKit/UIKit.h>

@class OverlayViewController;

@protocol OverlayViewControllerDelegate<NSObject>
@required
- (void)overlayViewControllerDone:(OverlayViewController *)overlayViewController;
@end


@interface OverlayViewController : UIViewController 
{
	id<OverlayViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<OverlayViewControllerDelegate> delegate;

@end
