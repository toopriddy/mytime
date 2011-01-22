//
//  NSObject+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 1/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSObject+PriddySoftware.h"
#import <objc/runtime.h>

@interface PSObjectProxy : NSProxy 
{
@public
	NSObject *targetObject;
}
@end

@implementation PSObjectProxy
- (void)dealloc 
{
	[targetObject release];
	
	[super dealloc];
}
@end

@interface PSThreadProxy : PSObjectProxy 
{
@public
	NSThread *targetThread;
}
@end

@implementation PSThreadProxy

- (void)dealloc 
{
	[targetThread release];
	
	[super dealloc];
}

- (void)forwardInvocation:(NSInvocation *)invocation 
{
	[invocation performSelector:@selector(invokeWithTarget:) onThread:targetThread withObject:targetObject waitUntilDone:([targetThread isEqual:[NSThread mainThread]])];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector 
{
	return [targetObject methodSignatureForSelector:selector];
}
@end

@interface PSOptionalProxy : PSObjectProxy 
{
@public
	Protocol *_protocol;
}
@end

@implementation PSOptionalProxy

- (void)forwardInvocation:(NSInvocation *)invocation 
{
	if (![targetObject respondsToSelector:[invocation selector]]) return;
	[invocation invokeWithTarget:targetObject];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector 
{
	if ([targetObject respondsToSelector:selector]) 
	{
		return [targetObject methodSignatureForSelector:selector];
	}
	// Note: isRequiredMethod can be no, because if it's required and not implemented the compiler will issue a warning
	struct objc_method_description method = protocol_getMethodDescription(_protocol, selector, /* isRequiredMethod */ NO, /* isInstanceMethod */ YES);
	
	return [NSMethodSignature signatureWithObjCTypes:method.types];
}
@end

@implementation NSObject (PriddySoftware)
- (id)mainThreadProxy 
{
	return [self threadProxy:[NSThread mainThread]];
}

- (id)backgroundThreadProxy 
{
	return [self threadProxy:[[[NSThread alloc] init] autorelease]];
}

- (id)threadProxy:(NSThread *)thread 
{
	PSThreadProxy *proxy = [[PSThreadProxy alloc] autorelease];
	proxy->targetObject = [self retain];
	proxy->targetThread = [thread retain];
	return proxy;
}

- (id)protocolProxy:(Protocol *)protocol 
{
	PSOptionalProxy *proxy = [[PSOptionalProxy alloc] autorelease];
	proxy->targetObject = [self retain];
	proxy->_protocol = protocol;
	return proxy;
}
@end
