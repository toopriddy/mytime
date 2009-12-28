//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
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
