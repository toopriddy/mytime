//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "MainView.h"

extern int debugging;

#define DEBUG(a) if(debugging) { a }
#define VERBOSE(a) if(debugging > 1) { a }
#define VERY_VERBOSE(a) if(debugging > 2) { a }


@interface App : UIApplication {
    UIWindow *_window;
    UITransitionView *_transitionView;

	CGRect _rect;
	
	MainView *_mainView;
}

- (CGRect)rect;
- (void)saveData;
- (UIWindow *)window;

- (NSMutableDictionary *)getSavedData;
- (void)setCalls:(NSMutableArray *)calls;
- (void)transition:(int)transition fromView:(UIView *)from toView:(UIView *)to;
+ (App *)getInstance;
- (void)dealloc;
@end
