/*
	UIOrientingApplication -- iPhone / iPod Touch UIKit Class
	©2008 James Yopp; LGPL License
	
	Application re-orients the display automatically to match the physical orientation of the hardware.
	Display can be locked / unlocked to prevent this behavior, and can be manually oriented with lockUIToOrientation.
*/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <GraphicsServices/GraphicsServices.h>

@interface UIOrientingApplication : UIApplication {
	CGRect FullKeyBounds;
	CGRect FullContentBounds;
	int orientations[7];
	int orientationDegrees;
	bool orientationLocked;
	float reorientationDuration;

	NSMutableArray *rotateThese;
}

- (id) init;

- (void) rotateObject: (UIView *)view;
- (void) dontRotateObject: (UIView *)view;
- (void) lockUIOrientation;
- (void) lockUIToOrientation: (unsigned int)o_code;
- (void) unlockUIOrientation;
- (void) setUIOrientation: (unsigned int)o_code;
- (void) setAngleForOrientation: (unsigned int)o_code toDegrees: (int)degrees;

- (void) deviceOrientationChanged: (GSEvent*)event;
- (CGRect) windowBounds;
- (CGRect) contentBounds;
- (bool) orientationLocked;

@end
