#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class UITableViewSwitchCell;

@protocol UITableViewSwitchCellDelegate<NSObject>
@required
- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell;
@end


@interface UITableViewSwitchCell : UITableViewCell 
{
    UISwitch *booleanSwitch;
	UILabel *otherTextLabel;
	NSObject<UITableViewSwitchCellDelegate> *_delegate;
	BOOL observeEditing;
}

@property (nonatomic, assign) NSObject<UITableViewSwitchCellDelegate> *delegate;
@property (nonatomic, assign) IBOutlet UISwitch *booleanSwitch;
@property (nonatomic, assign) IBOutlet UILabel *otherTextLabel;
@property (nonatomic, assign) BOOL observeEditing;

- (IBAction)switchChanged;

@end
