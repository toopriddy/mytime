//
//  CallTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>

@interface CallTableCell : UITableCell {
	NSMutableDictionary *_call;
}

- (CallTableCell *)initWithCall:(NSMutableDictionary *)call;

@end
