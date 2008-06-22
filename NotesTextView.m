//
//  NotesTextView.m
//  MyTime
//
//  Created by Brent Priddy on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NotesTextView.h"
#import "App.h"

#undef VERY_VERBOSE
#define VERY_VERBOSE(a) a

@implementation NotesTextView


- (NotesTextView *)initWithString:(NSString *)string editing:(BOOL)editing
{
	if((self = [super initWithFrame:CGRectZero]) != nil)
	{
		notes = [[UITextView alloc] initWithFrame:CGRectMake(50.0, 10.0, 240.0, 30.0)];
		
		[notes setEditable:editing];
		[notes setScrollingEnabled:editing];
		[notes setTextSize:16];
		[notes setDelegate:self];
		[[notes textTraits] setEditingDelegate:self];
		
		[notes setText:string];
		[self sizeToFit];
		[self addSubview:notes];
		[self setShowSelection:NO];

		[notes layoutSubviews];
		[notes setText:string];
		[notes layoutSubviews];
		CGSize textSize = [notes contentSize];
		int height = textSize.height;
		NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!Height = %u", height);
	}
	return(self);	
}

- (NSString *)text
{
	return([notes text]);
}

- (float) height
{
	CGSize textSize = [notes contentSize];
	float height = 52;
	if(textSize.height > height)
		height = textSize.height;
	NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!Height = %f", height);
	return(height);
}

- (UITextView *)textView
{
	return(notes);
}

-(BOOL)keyboardInput:(id)k shouldInsertText:(id)i isMarkedText:(int)b
{
//	NSLog(@"text changed");
	return(YES);
}

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"NotesTextView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"NotesTextView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"NotesTextView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}

@end
