//
//  PSLocalizedCollationSortDescriptor.h
//  MyTime
//
//  Created by Brent Priddy on 8/25/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSLocalizedCollationSortDescriptor : NSSortDescriptor 
{
	id collation;
}

-(id)initWithSortDescriptor:(NSSortDescriptor *)sortDescriptor;
@end

