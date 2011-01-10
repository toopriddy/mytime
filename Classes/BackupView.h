//
//  BackupView.h
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

#import <UIKit/UIKit.h>
#import "TCPServer.h"
#import "EventAgent.h"

#define kRestoreBackup				0x0001
#define kRetrieveBackup				0x0002
#define kRetrieveBackupReply		0x8002
#define kPushTranslation			0x0003
#define kRestoreCoreDataBackup		0x0004

/*
 * format of the kRestoreBackup message
 * UINT32 length
 * data with the contents of the backup
 */
#define kRestoreBackupLength (4)

/*
 * format of the kRetrieveBackup message
 */
#define kRetrieveBackupLength (0)

/*
 * format of the kRestoreBackupReply message
 * UINT32 length
 * data with the contents of the backup
 */
#define kRestoreBackupReplyLength (4)

/*
 * format of the kPushTranslation message
 * UINT32 length
 * data with the contents of the backup
 */
#define kPushTranslationLength (4)








typedef enum {
	kConnecting,
	kConnected,
	kDisconnected
} BackupViewState;

@interface BackupView : UIAlertView <UIAlertViewDelegate, TCPServerDelegate, EventAgentDelegate, EventAgentMessageDelegate, NSStreamDelegate>
{
	BackupViewState     _state;
	TCPServer          *_server;
	NSInputStream      *_inStream;
	NSOutputStream     *_outStream;
	EventAgent         *_agent;
	BOOL				_inReady;
	BOOL				_outReady;
}

- (void)eventAgent:(EventAgent *)agent messageReceivedWithType:(uint16_t)type flags:(uint32_t)flags payload:(NSData *)payload;
- (void)stop;
@end
