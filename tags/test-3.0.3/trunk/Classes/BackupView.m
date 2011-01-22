//
//  BackupView.m
//  MyTime
//
//  Created by Brent Priddy on 9/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "BackupView.h"
#import "Settings.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"
#import "UIAlertViewQuitter.h"

@implementation BackupView

- (void) setup 
{
	[self stop];
	
	_server = [TCPServer new];
	_server.delegate = self;
	
	NSError* error = nil;
	if(_server == nil || ![_server start:&error]) {
		NSLog(@"Failed creating server: %@", error);
			self.title = NSLocalizedString(@"Failed creating server", @"failure message for starting the backup service");
		return;
	}
	
	//Start advertising to clients, passing nil for the name to tell Bonjour to pick use default name
	if(![_server enableBonjourWithDomain:@"local" applicationProtocol:[TCPServer bonjourTypeFromIdentifier:@"mytime"] name:nil]) {
		self.title = NSLocalizedString(@"Failed advertising server", @"backup failed string");
		return;
	}
}


- (id)init
{
	if (self = [super init]) 
	{
		_state = kConnecting;
		_inStream = nil;
		_outStream = nil;
		_server = nil;
		
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		[self setup];
		[self autoresizesSubviews];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
		self.title = NSLocalizedString(@"Please wait for the Backup Service to initalize...\n\nGo to mytime.googlecode.com for more information about the Backup Application", @"initial setup message beore we have advertized the backup service (this message needs to be a bit long because the alertView can not resize when first shown)");
		self.delegate = self;
	}

	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// they pressed stop or ok
	switch(_state)
	{
		case kConnecting:
			[_server stop];
			[_server release];
			_server = nil;
			[self dismissWithClickedButtonIndex:buttonIndex animated:YES];
			break;
			
		case kConnected:
			[_server stop];
			[_server release];
			[self dismissWithClickedButtonIndex:buttonIndex animated:YES];
			break;
	}
}


- (void)dealloc 
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[self stop];
	[super dealloc];
}


- (void)stop
{
	self.delegate = nil;
	[_agent stop];
	[_agent release];
	_agent = nil;

	[_server stop];
	[_server release];
	_server = nil;
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;
	_inReady = NO;

	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;
	_outReady = NO;
}


- (void) openStreams
{
	_inStream.delegate = self;
	[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream open];
	_outStream.delegate = self;
	[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream open];
}


- (void) stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	switch(eventCode) {
		case NSStreamEventOpenCompleted:
		{
			if (stream == _inStream)
				_inReady = YES;
			else
				_outReady = YES;
			
			if (_inReady && _outReady) 
			{
				_state = kConnected;
				self.title = NSLocalizedString(@"Connected to the Backup Application.\n\nUse it to create a backup or to restore a backup", @"backup connected message");

				_agent = [[EventAgent alloc] initWithInputStream:_inStream outputStream:_outStream];
				_agent.delegate = self;
				[_agent setMessageDelegate:self forType:kRestoreBackup];
				[_agent setMessageDelegate:self forType:kRestoreCoreDataBackup];
				[_agent setMessageDelegate:self forType:kRetrieveBackup];
				[_agent setMessageDelegate:self forType:kPushTranslation];
			}
			break;
		}
		
		case NSStreamEventHasBytesAvailable:
		case NSStreamEventHasSpaceAvailable:
		case NSStreamEventEndEncountered:
		case NSStreamEventErrorOccurred:
		{
			if(_agent)
			{
				if([_agent stream:stream handleEvent:eventCode] == NO)
				{
					// need to close the event agent
					self.title = NSLocalizedString(@"Disconnected from the Backup Application", @"backup connected message");
					_state = kDisconnected;
					[self dismissWithClickedButtonIndex:0 animated:YES];
					[_agent stop];
					[_agent release];
					_agent = nil;
				}
			}
			else
			{
				// need to free up the streams
				self.title = NSLocalizedString(@"Connected to the Backup Application.\n\nUse it to create a backup or to restore a backup", @"backup connected message");
				_state = kDisconnected;
			}
			break;
		}
	}
}



- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)string
{
	self.title = NSLocalizedString(@"Waiting for the Backup Application to connect...\n\nGo to mytime.googlecode.com for more information about the Backup Application", @"initial message when trying to transfer backup files");
	[self layoutSubviews];
}

- (void)didAcceptConnectionForServer:(TCPServer*)server inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
	if (_inStream || _outStream || server != _server)
		return;
	
	[_server release];
	_server = nil;
	
	_inStream = istr;
	[_inStream retain];
	_outStream = ostr;
	[_outStream retain];
	
	[self openStreams];
}

- (void)eventAgentConnected:(EventAgent *)agent
{
}

- (void)eventAgentDisconnected:(EventAgent *)agent
{
}

- (void)eventAgent:(EventAgent *)agent messageReceivedWithType:(uint16_t)type flags:(uint32_t)flags payload:(NSData *)payload
{
	switch(type)
	{
		case kRestoreBackup:
		{
			NSMutableDictionary *dictionary = nil;
			@try
			{
				dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
			}
			@catch (NSException *e) 
			{
				dictionary = nil;
			}
			
			[dictionary writeToFile:[Settings filename] atomically: YES];
			NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
			BOOL exists = [fileManager fileExistsAtPath:[MyTimeAppDelegate storeFileAndPath]];
			if(exists && ![fileManager removeItemAtPath:[MyTimeAppDelegate storeFileAndPath] error:nil])
			{
				NSLog(@"deleted file");
			}
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			alertSheet.delegate = [[UIAlertViewQuitter alloc] init];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
			[alertSheet show];
			break;
		}
			
		case kRestoreCoreDataBackup:
		{
			NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
			BOOL exists = [fileManager fileExistsAtPath:[MyTimeAppDelegate storeFileAndPath]];
			if(exists && ![fileManager removeItemAtPath:[MyTimeAppDelegate storeFileAndPath] error:nil])
			{
				NSLog(@"deleted file");
			}
			[payload writeToFile:[MyTimeAppDelegate storeFileAndPath] atomically:YES];
			UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
			alertSheet.delegate = [[UIAlertViewQuitter alloc] init];
			[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
			alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
			[alertSheet show];
			break;
		}
			
		case kRetrieveBackup:
		{
			NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
			NSManagedObjectContext *moc = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
			NSError *error = nil;
			if(![moc save:&error])
			{
				[NSManagedObjectContext presentErrorDialog:error];
			}
			NSData *data = [fileManager contentsAtPath:[MyTimeAppDelegate storeFileAndPath]];
			self.title = NSLocalizedString(@"Sending Settings to the Backup Application", @"initial message when trying to transfer backup files");
			[agent sendMessageWithType:kRetrieveBackupReply flags:0 payload:[NSArray arrayWithObject:data]];
			self.title = NSLocalizedString(@"Connected to the Backup Application.\n\nUse it to create a backup or to restore a backup", @"backup connected message");
			break;
		}

		case kPushTranslation:
		{
			NSMutableDictionary *dictionary = nil;
			@try
			{
				dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:payload];
			}
			@catch (NSException *e) 
			{
				dictionary = nil;
			}
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);

			
			NSString *directory = [dictionary objectForKey:@"directory"];
			NSString *filename = [dictionary objectForKey:@"name"];
			NSData *contents = [dictionary objectForKey:@"file"];
			NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
			NSMutableString *bundlePath = [NSMutableString stringWithString:[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"translation.bundle/Contents/Resources/"] stringByAppendingPathComponent:directory]];
			
			if(![fileManager createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil])
			{
				NSLog(@"could not create directory at %@", bundlePath);
				self.title = [NSString stringWithFormat:NSLocalizedString(@"Could not create %@ directory", @"initial message when trying to transfer backup files"), directory];
			}
			else
			{
				[bundlePath appendFormat:@"/%@", filename];
				[contents writeToFile:bundlePath atomically:YES];
				self.title = [NSString stringWithFormat:NSLocalizedString(@"Pushed %@ translation file, restart MyTime to see the changes.", @"initial message when trying to transfer backup files"), directory];
			}
			break;
		}
	}
}

@end
