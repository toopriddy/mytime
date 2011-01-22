//
//  EmptyListView.h
//  MyTime
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmptyListViewController : UIViewController 
{
	UILabel *mainLabel;
	UILabel *subLabel;
	UIImageView *imageView;
}
@property (nonatomic, retain) IBOutlet UILabel *mainLabel;
@property (nonatomic, retain) IBOutlet UILabel *subLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
