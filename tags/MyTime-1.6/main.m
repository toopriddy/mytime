//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyTimeAppDelegate.h"

#ifdef __DEBUGGING__
int debugging = 4;
#else
int debugging = 0;
#endif

int main(int argc, char **argv)
{
	int i;
	for(i = 0; i < argc; ++i)
	{
		if(argv[i])
		{
			if(0 == strcmp("-v", argv[i]))
			{
				debugging++;
			}
		}
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ret = UIApplicationMain(argc, argv, nil, @"MyTimeAppDelegate");
	[pool release];
	return ret;
}
