#import "UITableViewSwitchCell.h"

@implementation UITableViewSwitchCell
@synthesize booleanSwitch;
@synthesize otherTextLabel;
@synthesize delegate = _delegate;
@synthesize observeEditing;

- (void)dealloc
{
	self.booleanSwitch = nil;
	self.otherTextLabel = nil;
	
	[super dealloc];
}

- (IBAction)switchChanged
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(uiTableViewSwitchCellChanged:)])
	{
		[self.delegate uiTableViewSwitchCellChanged:self];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self bringSubviewToFront:self.booleanSwitch];
	
	if(self.observeEditing)
		self.booleanSwitch.enabled = self.editing;
}

@end
