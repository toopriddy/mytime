//
//  EventAgent.h
//  BonjourTest
//
//  Created by Brent Priddy on 9/14/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	MAX_PAYLOAD_LENGTH = (500000 - 10),
	DEFAULT_SERVICE_PORT = 3201,
	kMessageHeaderLength = 10
};

#define BUFFER_WRITE_UINT32(buffer, value)   \
{                                            \
    *((unsigned char *)buffer++) = ((unsigned int)(value) >> 24) & 0x000000FF;  \
    *((unsigned char *)buffer++) = ((unsigned int)(value) >> 16) & 0x000000FF;  \
    *((unsigned char *)buffer++) = ((unsigned int)(value) >>  8) & 0x000000FF;  \
    *((unsigned char *)buffer++) = (unsigned int)(value) & 0x000000FF;          \
}

#define BUFFER_WRITE_UINT16(buffer, value)   \
{                                            \
    *((unsigned char *)buffer++) = ((unsigned int)(value) >>  8) & 0x000000FF;  \
    *((unsigned char *)buffer++) = (unsigned int)(value) & 0x000000FF;          \
}

#define BUFFER_WRITE_UINT8(buffer, value)   \
{                                           \
    *((unsigned char *)buffer++) = (unsigned int)(value) & 0x000000FF;         \
}

#define BUFFER_READ_UINT32(buffer, value) \
{                                         \
    (value) = 0;                            \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
}

#define BUFFER_READ_UINT16(buffer, value) \
{                                         \
    (value) = 0;                            \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);     \
}

#define BUFFER_READ_UINT8(buffer, value) \
{                                        \
    (value) = 0;                            \
    (value) = ((unsigned int)(value) << 8) | *((unsigned char *)buffer++);    \
}

@class EventAgent;
@class EventAgentMessage;

@protocol EventAgentDelegate
- (void)eventAgentConnected:(EventAgent *)agent;
- (void)eventAgentDisconnected:(EventAgent *)agent;
@end

@protocol EventAgentMessageDelegate
- (void)eventAgent:(EventAgent *)agent messageReceivedWithType:(uint16_t)type flags:(uint32_t)flags payload:(NSData *)payload;
@end

@interface EventAgentWriteBuffer : NSObject {
	NSData *_data;
	uint32_t _offset;
}
@property (nonatomic, retain) NSData *data;
@property (nonatomic) uint32_t offset;

- (id)initWithBuffer:(uint8_t *)buffer length:(uint32_t)length;
- (id)initWithData:(NSData *)data;
- (id)initWithData:(NSData *)data offset:(uint32_t)offset;
@end

@interface EventAgent : NSObject {

	uint8_t    _buffer[MAX_PAYLOAD_LENGTH + 10];
	uint8_t   *_write;
	uint8_t   *_read;
	uint32_t   _expectedLength;
	uint32_t  _myFlags;
	NSMutableArray *_writeList;
	
	uint32_t  _len;
	uint32_t  _type;
	uint32_t  _flags;
	id _userData;
	uint32_t  _eventId;

	NSInputStream*		_inStream;
	NSOutputStream*		_outStream;

	id<EventAgentDelegate> _delegate;
	NSMutableDictionary *_handlers;
}

@property (nonatomic) uint32_t flags;
@property (nonatomic, assign) id<EventAgentDelegate> delegate;
@property (nonatomic, retain) id userData;

- (id)initWithInputStream:(NSInputStream *)inStream outputStream:(NSOutputStream *)outStream;

/**
 * this function validates a pointer to an agent
 * @param agent   the agent to check
 * @return        true if the agent is valid
 */
+ (BOOL)isValid:(EventAgent *)agent;
	
/**
 * get the next agent (if the previous one is NULL, then get the 
 * first agent)
 * @param previousAgent the previous agent or null if you want the first
 * @return non null agent if there is a next, and NULL if the previousAgent is the
 *         last agent
 */
+ (EventAgent *)getNextAgent:(EventAgent *)previousAgent;

/**
 * Send an event to the EventAgent We are connected to
 * @param message    the event message to send to the peer
 * @param payload    a payload to send along with the message
 * @return true if the message was sent, false if error
 */
- (BOOL)sendMessageWithType:(uint16_t)type flags:(uint32_t)flags payload:(NSArray *)payload;

/**
 * see whether the Agent is connected or not
 * @return true if connected
 */
//- (BOOL)isConnected;

/**
 * handle a socket event
 * @return false when you should delete the EventAgent
 */
- (BOOL)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode;

/**
 * Add event handlers to the EventAgent
 * @param type  this is the event type
 * @param cb    the function to call when we recieve a message of type "type"
 * @param replace true if you want this callback to replace an existing entry
 * @return true if successfull (if replace == false, and you are adding a 
 *              duplicate entry, then it will return false)
 */
- (void)setMessageDelegate:(id<EventAgentMessageDelegate>)delegate forType:(uint16_t)type;

/**
 * remove a EventAgent event handler
 * @param type the event handler type that will be deleted
 * @return true if anything was deleted
 */
- (void)removeMessageDelegateForType:(uint16_t)type;

/**
 * Default event handlers to the global EventAgent event handlers
 */
-  (void)defaultMessageDelegates;

- (void)stop;
@end



