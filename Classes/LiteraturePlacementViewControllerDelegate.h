//
//  LiteraturePlacementViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class LiteraturePlacementViewController;

@protocol LiteraturePlacementViewControllerDelegate<NSObject>

@required

- (void)literaturePlacementViewControllerDone:(LiteraturePlacementViewController *)literaturePlacementViewController;

@end
