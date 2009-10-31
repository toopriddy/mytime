#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSString.h>

int main (int argc, const char * argv[]) 
{
	// LocalizableMerge baseLanguageFile destinationFile
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(argc < 3)
	{
		CFShow(@"usage:\nLocalizableMerge baseLanguageFile destinationFile");
		
		[pool release];
		return -1;
	}

	NSString *baseLanguageFile = [NSString stringWithContentsOfFile:[NSString stringWithCString:argv[1]]];
	
	if(baseLanguageFile == nil || baseLanguageFile.length == 0)
	{
		CFShow(@"usage:\nLocalizableMerge baseLanguageFile destinationFile");
		CFShow(@"bad baseLanguageFile");
		
		return -1;
	}
//	CFShow(baseLanguageFile);

	NSMutableArray *baseArray = [NSMutableArray array];
	NSMutableDictionary *entry = [NSMutableDictionary dictionary];
	
	NSArray *baseLanguageArray = [baseLanguageFile componentsSeparatedByString:@"\n"];
	for(NSString *line in baseLanguageArray)
	{
//		CFShow(line);
		
		// check for comment
		if([line hasPrefix:@"/*"])
		{
			[entry setObject:line forKey:@"comment"];
		}
		// check for a translation entry
		else if([line hasPrefix:@"\""])
		{
			NSArray *tempArray = [line componentsSeparatedByString:@" = "];
			if(tempArray.count != 2)
			{
				NSLog(@"ERROR: there is an equal sign in the text and this breaks this merge utility");
				return -1;
			}
			[entry setObject:[tempArray objectAtIndex:0] forKey:@"first"];
			[entry setObject:[tempArray objectAtIndex:1] forKey:@"second"];
			
			[baseArray addObject:entry];
			entry = [NSMutableDictionary dictionary];
		}
	}
	// we dont need entry anymore
	entry = nil;
	
	NSString *mergeToFilename = [NSString stringWithCString:argv[2]];
	if([mergeToFilename isEqualToString:@"-check"])
	{
		CFShow(@"The following have not been translated:\n\n");
		for(NSDictionary *entry in baseArray)
		{
//			CFShow([entry description]);
			if([[entry objectForKey:@"second"] hasPrefix:[entry objectForKey:@"first"]])
			{
				CFShow([entry objectForKey:@"first"]);
				CFShow(@"\n");
			}
		}
		
		return 0;
	}
	
	NSString *mergeToFile = [NSString stringWithContentsOfFile:mergeToFilename];
	if(mergeToFile == nil || mergeToFile.length == 0)
	{
		CFShow(@"usage:\nLocalizableMerge baseLanguageFile destinationFile");
		CFShow(@"bad destinationFile");
		
		return -1;
	}
	NSArray *mergeToArray = [mergeToFile componentsSeparatedByString:@"\n"];
	NSString *firstLine = [mergeToArray objectAtIndex:0];
	NSString *versionLine = nil;
	if([firstLine hasPrefix:@"/* VERSION:"])
	{
		versionLine = firstLine;
	}
	
	NSArray *names = [baseArray valueForKey:@"first"];
	for(NSString *line in mergeToArray)
	{
//		CFShow(line);
		
		// check for comment
		if([line hasPrefix:@"\""])
		{
			NSArray *tempArray = [line componentsSeparatedByString:@" = "];
			if(tempArray.count != 2)
			{
				NSLog(@"ERROR: there is an equal sign in the text and this breaks this merge utility");
				return -1;
			}
			int index = [names indexOfObject:[tempArray objectAtIndex:0]];
			if(index != NSNotFound)
			{
				NSString *value = [tempArray objectAtIndex:1];
//				NSLog(@"found it at %d as %@", index, value);
				entry = [baseArray objectAtIndex:index];
				[entry setObject:value forKey:@"second"];
				[entry setObject:@"" forKey:@"found"];
			}
			else
			{
				NSLog(@"%@ not found or removed", [tempArray objectAtIndex:0]);
			}
		}
	}
//	NSLog(@"%@", baseArray);
	NSString *printString = [NSString stringWithFormat:@"The following are new entries for %@:", mergeToFilename];
	CFShow(printString);

	NSMutableString *output = [NSMutableString string];
	NSMutableString *newEntry = [[NSMutableString alloc] init];
	if(versionLine)
	{
		[output appendFormat:@"%@\n\n", versionLine];
	}
	for(entry in baseArray)
	{
		NSString *comment = [entry objectForKey:@"comment"];
		[newEntry appendFormat:@"%@\n", (comment ? comment : @"/* */")];
		[newEntry appendFormat:@"%@ = %@\n\n", [entry objectForKey:@"first"], [entry objectForKey:@"second"]];
		[output appendString:newEntry];
		if([entry objectForKey:@"found"] == nil)
		{
			CFShow(newEntry);
		}
		[newEntry setString:@""];
	}
//	NSLog(@"this is the output %@", output);
	[output writeToFile:mergeToFilename atomically:YES encoding:NSUTF16StringEncoding error:(NSError **)nil];

	[pool release];
    return 0;
}
