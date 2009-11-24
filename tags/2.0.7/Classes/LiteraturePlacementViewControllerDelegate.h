//
//  LiteraturePlacementViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

@class LiteraturePlacementViewController;

@protocol LiteraturePlacementViewControllerDelegate<NSObject>

@required

- (void)literaturePlacementViewControllerDone:(LiteraturePlacementViewController *)literaturePlacementViewController;

@end