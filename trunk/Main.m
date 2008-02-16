//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "App.h"

int debugging = 0;

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
    [[NSAutoreleasePool alloc] init];
    return UIApplicationMain(argc, argv, [App class]);
}
