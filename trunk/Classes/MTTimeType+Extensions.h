//
//  MTTimeType+Extensions.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "MTTimeType.h"

@interface MTTimeType(Extensions)
+ (MTTimeType *)hoursType;
+ (MTTimeType *)rbcType;
+ (MTTimeType *)timeTypeWithName:(NSString *)name;
@end
