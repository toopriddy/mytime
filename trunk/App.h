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
// 0 nothing
// 1 slide left with the to view to the right
// 2 slide right with the to view to the left
// 3 from bottom up with the to view right below the from view
// 4 from bottom up, but background seems to be invisible
// 5 from top down, but background seems to be invisible
// 6 fade away to the to view
// 7 down with the to view above the from view
// 8 from bottom up sliding ontop of
// 9 from top down sliding ontop of
- (void)transition:(int)transition fromView:(UIView *)from toView:(UIView *)to;
+ (App *)getInstance;
- (void)dealloc;
@end
