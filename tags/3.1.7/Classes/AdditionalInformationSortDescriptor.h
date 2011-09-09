//
//  AdditionalInformationSortDescriptor.h
//  MyTime
//
//  Created by Brent Priddy on 3/16/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdditionalInformationSortDescriptor : NSSortDescriptor 
{

}
@property (nonatomic, copy) NSString *path;

-(id)initWithName:(NSString *)theName path:(NSString *)thePath ascending:(BOOL)ascending selector:(SEL)selector;
@end

