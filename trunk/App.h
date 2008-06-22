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
#import "UIOrientingApplication.h"
#import "MainView.h"
#import "MainTransitionView.h"

extern int debugging;

#define DEBUG(a) if(debugging) { a }
#define VERBOSE(a) if(debugging > 1) { a }
#define VERY_VERBOSE(a) if(debugging > 2) { a }


#define resize_SpringLeft 0x01
#define resize_SpringWidth 0x02
#define resize_SpringRight 0x04
#define resize_SpringTop 0x08
#define resize_SpringHeight 0x10
#define resize_SpringBottom 0x20
#define kMainAreaResizeMask (resize_SpringWidth | resize_SpringHeight)
#define kPickerResizeMask resize_SpringWidth
#define kTopBarResizeMask resize_SpringWidth
#define kBottomBarResizeMask (resize_SpringWidth | resize_SpringTop)
#define kButtonBarResizeMask (resize_SpringWidth | resize_SpringLeft | resize_SpringRight | resize_SpringTop)
#define kKeyboardResizeMask resize_SpringWidth

enum kSwipeDirection {
	kSwipeDirectionUp=1, 
	kSwipeDirectionDown=2, 
	kSwipeDirectionRight=4, 
	kSwipeDirectionLeft=8
};


@interface App : UIOrientingApplication {
    UIWindow *_window;
    MainTransitionView *_transitionView;

	CGRect _rect;
	
	MainView *_mainView;
}

- (id)init;
- (CGRect)rect;
- (void)saveData;
- (UIWindow *)window;
- (MainView *)mainView;
- (void)applicationSuspend:(GSEvent*)event;

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
