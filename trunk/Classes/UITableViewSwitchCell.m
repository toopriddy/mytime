#import "UITableViewSwitchCell.h"

@implementation UITableViewSwitchCell
@synthesize booleanSwitch;
@synthesize otherTextLabel;
@synthesize delegate = _delegate;

- (IBAction)switchChanged
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(uiTableViewSwitchCellChanged:)])
	{
		[self.delegate uiTableViewSwitchCellChanged:self];
	}
}

@end
