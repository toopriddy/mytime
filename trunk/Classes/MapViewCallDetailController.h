#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MapViewCallDetailController;

@protocol MapViewCallDetailControllerDelegate
@required
- (void) mapViewCallDetailControllerSelected:(MapViewCallDetailController *)mapViewCallDetailController;
- (void) mapViewCallDetailControllerCanceled:(MapViewCallDetailController *)mapViewCallDetailController;
@end

@interface MapViewCallDetailController : UIViewController 
{
@private
    IBOutlet UILabel *address;
    IBOutlet UILabel *info;
    IBOutlet UILabel *name;

	NSMutableDictionary *call;
	NSObject<MapViewCallDetailControllerDelegate> *delegate;
}
@property (nonatomic, assign, setter=setCall:, getter=call) NSMutableDictionary *call;
@property (nonatomic, assign) NSObject<MapViewCallDetailControllerDelegate> *delegate;

- (IBAction)callDetailSelected;
- (IBAction)cancelSelected;

- (void)setCall:(NSMutableDictionary *)theCall;
- (NSMutableDictionary *)call;

@end
