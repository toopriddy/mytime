#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UITableViewSwitchCell : UITableViewCell {
    UISwitch *booleanSwitch;
	UILabel *otherTextLabel;
}
@property (nonatomic, assign) IBOutlet UISwitch *booleanSwitch;
@property (nonatomic, assign) IBOutlet UILabel *otherTextLabel;

@end
