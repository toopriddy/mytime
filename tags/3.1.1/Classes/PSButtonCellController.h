//
//  PSButtonCellController.h
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseCellController.h"

@interface PSButtonCellController : PSBaseCellController
{
	id buttonTarget_;
	SEL buttonAction_;
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *imagePressed;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imagePressedName;
@property (nonatomic, assign) BOOL darkTextColor;

- (void)setButtonTarget:(id)target action:(SEL)action;
@end
