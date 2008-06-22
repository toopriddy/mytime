//
//  MainTransitionView.h
//  MyTime
//
//  Created by Brent Priddy on 3/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITransitionView.h>

@interface MainTransitionView : UITransitionView {
	NSString *_alertSheetText;
}

- (id) initWithFrame: (CGRect)rect;

- (void)transition:(int)transition fromView:(UIView*)fromView toView:(UIView *)toView withAlert:(NSString *)alert;

- (BOOL)respondsToSelector:(SEL)selector;
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
- (void)forwardInvocation:(NSInvocation*)invocation;
@end
