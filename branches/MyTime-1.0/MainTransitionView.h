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

}

- (id) initWithFrame: (CGRect)rect;
- (void)setBounds:(CGRect)rect;

- (BOOL)respondsToSelector:(SEL)selector;
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector;
- (void)forwardInvocation:(NSInvocation*)invocation;
@end
