#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class SecurityViewController;

@protocol SecurityViewControllerDelegate
- (void)securityViewControllerDone:(SecurityViewController *)viewController authenticated:(BOOL)authenticated;
@end

@interface SecurityInputView : UIView
{
@private
    UILabel *label;
    UILabel *secondaryLabel;
    UITextField *text1;
    UITextField *text2;
    UITextField *text3;
    UITextField *text4;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *secondaryLabel;
@property (nonatomic, retain) IBOutlet UITextField *text1;
@property (nonatomic, retain) IBOutlet UITextField *text2;
@property (nonatomic, retain) IBOutlet UITextField *text3;
@property (nonatomic, retain) IBOutlet UITextField *text4;
@end


@interface SecurityViewController : UIViewController <UITextFieldDelegate>
{
@private
	SecurityInputView *currentView;
	SecurityInputView *mainView;
	SecurityInputView *confirmView;
    UITextField *input;
	BOOL shouldConfirm;
	NSString *promptText;
	NSString *secondaryPromptText;
	NSString *confirmText;
	NSString *passcode;
	NSString *confirmPasscode;
	id delegate;
}
@property (nonatomic, retain) IBOutlet UITextField *input;
@property (nonatomic, retain) IBOutlet SecurityInputView *mainView;
@property (nonatomic, retain) IBOutlet SecurityInputView *confirmView;
@property (nonatomic, assign) BOOL shouldConfirm;
@property (nonatomic, assign) NSString *promptText;
@property (nonatomic, assign) NSString *secondaryPromptText;
@property (nonatomic, retain) NSString *confirmText;
@property (nonatomic, retain) NSString *passcode;
@property (nonatomic, retain) NSString *confirmPasscode;
@property (nonatomic, assign) id<SecurityViewControllerDelegate> delegate;



@end
