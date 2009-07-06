//
//  EventAgent.m
//  BonjourTest
//
//  Created by Brent Priddy on 9/14/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "EventAgent.h"

//#define DEBUG_ONLY(a) a
#define DEBUG_ONLY(a)

NSMutableSet *_agents = nil;

/*****************************************************************************************/
@implementation EventAgentWriteBuffer
@synthesize data = _data;
@synthesize offset = _offset;

- (id)initWithBuffer:(uint8_t *)buffer length:(uint32_t)length
{
	return([self initWithData:[NSData dataWithBytes:buffer length:length]]);
}

- (id)initWithData:(NSData *)data
{
	return([self initWithData:data offset:0]);
}

- (id)initWithData:(NSData *)data offset:(uint32_t)offset
{
	[super init];
	_data = [data retain];
	_offset = offset;
	
	return(self);
}

- (void)dealloc
{
	[_data release];
	
	[super dealloc];
}
@end


void PrintPacket(char *banner, uint16_t type, uint32_t flags, NSArray *payload)
{
	int i = 0;
	uint32_t offset = 0;
	NSEnumerator *enumerator = [payload objectEnumerator];
	NSData *data;
	while( (data = [enumerator nextObject]) && 
		   data != nil)
	{
		offset += data.length;
	}


	NSLog(@"%s: ##########################", banner);
	NSLog(@"%s: type  = 0x%04X (%d)", banner, type, type);
	NSLog(@"%s: flags = 0x%04X (%d)", banner, flags, flags);
	NSLog(@"%s: len   = 0x%04X (%d)", banner, offset + kMessageHeaderLength, offset + kMessageHeaderLength);
	NSLog(@"%s: plen  = 0x%04X (%d)", banner, offset, offset);
	NSLog(@"%s: PAYLOAD HEX:", banner);
	NSLog(@"%s:   ", banner);
	NSString *output = [NSString string];

	offset = 0;
	enumerator = [payload objectEnumerator];
	while( (data = [enumerator nextObject]) && 
		   data != nil && 
		   data.length == 0)
	{
	}

	while(data)
	{
		uint8_t b = *((uint8_t *)data.bytes + offset);
		
		output = [output stringByAppendingFormat:@"%02X ", b];
		offset++;
		i++;
		if(i % 8 == 0)
			output = [output stringByAppendingFormat:@"\n%s:   ", banner];

		if(offset > data.length)
		{
			offset = 0;
			while( (data = [enumerator nextObject]) && 
			       data != nil && 
				   data.length == 0)
			{
			}
		}
	}


	output = [output stringByAppendingFormat:@"\n%s: PAYLOAD ASCII:\n", banner];
	output = [output stringByAppendingFormat:@"%s:   ", banner];
	offset = 0;
	enumerator = [payload objectEnumerator];
	while( (data = [enumerator nextObject]) && 
		   data != nil && 
		   data.length == 0)
	{
	}
	while(data)
	{
		uint8_t b = *((uint8_t *)data.bytes + offset);
		
		output = [output stringByAppendingFormat:@ "%c", isprint(b) ? b : '.'];
		i++;
		offset++;
		if(i % 8 == 0)
			output = [output stringByAppendingFormat:@"\n%s:   ", banner];
			
		if(offset > data.length)
		{
			offset = 0;
			while( (data = [enumerator nextObject]) && 
			       data != nil && 
				   data.length == 0)
			{
			}
		}
	}
	NSLog(@"%@", output);
}



/*****************************************************************************************/
@implementation EventAgent

@synthesize flags = _myFlags;
@synthesize userData = _userData;
@synthesize delegate = _delegate;

- (void)stop
{
	[_handlers release];
	_handlers = nil;
	[_inStream release];
	_inStream = nil;
	[_outStream release];
	_outStream = nil;
	[_writeList release];
	_writeList = nil;
	
	[_agents removeObject:self];
}

- (void)dealloc
{
	id temp = _delegate;
	NSLog(@"%d", [temp retainCount]);
	[self stop];
	NSLog(@"%d", [temp retainCount]);
	self.delegate = nil;
	NSLog(@"%d", [temp retainCount]);
	self.userData = nil;
	
	[super dealloc];
}

- (id)initWithInputStream:(NSInputStream *)inStream outputStream:(NSOutputStream *)outStream
{
	[super init];
	
	if(_agents == nil)
	{
		_agents = [[NSMutableSet alloc] init];
	}
	_inStream = [inStream retain];
	_outStream = [outStream retain];
	_write = _buffer;
	_expectedLength = -1;
	_myFlags = 0;
	_len = 0;
	_type = 0;
	_flags = 0;
	_writeList = [[NSMutableArray array] retain];
	_userData = nil;
	_delegate = nil;
	_handlers = [[NSMutableDictionary dictionary] retain];
	
	[_agents addObject:self];
	
	return(self);
}

/**
 * this function validates a pointer to an agent
 * @param agent   the agent to check
 * @return        YES if the agent is valid
 */
+ (BOOL)isValid:(EventAgent *)agent
{
	return [_agents containsObject:agent];
}
	
/**
 * get the next agent (if the previous one is NULL, then get the 
 * first agent)
 * @param previousAgent the previous agent or null if you want the first
 * @return non null agent if there is a next, and NULL if the previousAgent is the
 *         last agent
 */
+ (EventAgent *)getNextAgent:(EventAgent *)previousAgent
{
	NSEnumerator *enumerator = [_agents objectEnumerator];
	EventAgent *agent;
	while( (agent = [enumerator nextObject]) )
	{
		if(agent == previousAgent)
		{
			return( [enumerator nextObject] );
		}
	}
	return(nil);
}

/**
 * Send an event to the EventAgent We are connected to
 * @param message    the event message to send to the peer
 * @param payload    a payload to send along with the message
 * @param payloadLen the length of the payload
 * @return YES if the message was sent, NO if error
 */
- (BOOL)sendMessageWithType:(uint16_t)type flags:(uint32_t)flags payload:(NSArray *)payload
{
	uint8_t headerBuffer[kMessageHeaderLength];
	uint8_t *buffer = headerBuffer;

	if([_outStream streamStatus] == NSStreamStatusNotOpen)
	{
		return(NO);
	}
		
	DEBUG_ONLY(
		PrintPacket("EventAgent sendMessageWithType", type, flags, payload);
	);

	uint32_t payloadLength = 0;
	NSEnumerator *enumerator = [payload objectEnumerator];
	NSData *data;
	while( (data = [enumerator nextObject]) && 
		   data != nil)
	{
		payloadLength += data.length;
	}


		
	BUFFER_WRITE_UINT32(buffer, kMessageHeaderLength + payloadLength);
	BUFFER_WRITE_UINT16(buffer, type);
	BUFFER_WRITE_UINT32(buffer, flags);

    bool store = NO;
    uint32_t offset = 0;
    
    if([_writeList count] == 0)
    {
		while(offset != kMessageHeaderLength && 
		      [_outStream hasSpaceAvailable])
		{
			offset += [_outStream write:(headerBuffer + offset) maxLength:(kMessageHeaderLength - offset)];
		}
		if(offset != kMessageHeaderLength)
		{
			store = YES;
		}
    }
    else
    {
        // if we have buffered up data, then just go ahead and store this too
        store = YES;
    }

    if(store)
    {
		// store the payload and the header
		[_writeList addObject:[[[EventAgentWriteBuffer alloc] initWithBuffer:(headerBuffer + offset) length:(kMessageHeaderLength - offset)] autorelease]];

		// store all of the payload pieces
		NSEnumerator *enumerator = [payload objectEnumerator];
		NSData *data;
		while( (data = [enumerator nextObject]) )
		{
			[_writeList addObject:[[[EventAgentWriteBuffer alloc] initWithData:data] autorelease]];
		}
    }
	else
	{
		NSEnumerator *enumerator = [payload objectEnumerator];
		NSData *data;
		while( (data = [enumerator nextObject]) )
		{
			offset = 0;

			// ok we sent the header now send the payload
			if([_writeList count] == 0)
			{
				while(offset != data.length && 
					  [_outStream hasSpaceAvailable])
				{
					offset += [_outStream write:(data.bytes + offset) maxLength:(data.length - offset)];
				}
				if(offset != data.length)
				{
					store = YES;
				}
			}
			else
			{
				// if we have buffered up data, then just go ahead and store this too
				store = YES;
			}

			if(store)
			{
				[_writeList addObject:[[[EventAgentWriteBuffer alloc] initWithData:data offset:offset] autorelease]];
			}
		}
	}
    
	return(YES);
}


/**
 * see whether the Agent is connected or not
 * @return YES if connected
 */
//- (BOOL)isConnected;

/**
 * handle a socket event
 * @return NO when you should delete the EventAgent
 */
- (BOOL)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventCode
{
	int32_t res;
	bool ret = YES;

	switch(eventCode)
	{
		case NSStreamEventErrorOccurred:
			NSLog(@"EventAgent::handleMessage(): NSStreamEventErrorOccurred/\n");
			if(_inStream == stream || _outStream == stream)
			{
				ret = NO;
			}
			break;

		case NSStreamEventEndEncountered:
			if(_inStream == stream || _outStream == stream)
			{
				NSLog(@"EventAgent::handleMessage(): NSStreamEventEndEncountered/\n");
				ret = NO;
			}
			break;
			
		case NSStreamEventHasSpaceAvailable:
			NSLog(@"EventAgent::handleMessage(): NSStreamEventHasSpaceAvailable\n");
			if(_outStream == stream && [_writeList count] != 0)
			{
                EventAgentWriteBuffer *writeBuffer;
				
                while([_writeList count] && (writeBuffer = [_writeList objectAtIndex:0]) )
                {
					while(writeBuffer.offset != writeBuffer.data.length && 
						  [_outStream hasSpaceAvailable])
					{
						writeBuffer.offset += [_outStream write:(writeBuffer.data.bytes + writeBuffer.offset) maxLength:(writeBuffer.data.length - writeBuffer.offset)];
					}
					if(writeBuffer.offset != writeBuffer.data.length)
					{
						break;
					}
					[_writeList removeObjectAtIndex:0];
                }
			}
			break;
			
		case NSStreamEventHasBytesAvailable:
			DEBUG_ONLY(NSLog(@"EventAgent::handleMessage(): NSStreamEventHasBytesAvailable\n"));
			if(_inStream != stream && _outStream != stream)
				break;
				
			res = sizeof(_buffer) - (_write - _buffer);

			if(res == 0)
			{
				printf("EventAgent::handleMessage(): the buffer is overflowing expectedLength = %d\n", _expectedLength);
				exit(1);
			}

			// -1 == new message comming in
			// 0  == new message in progress, but dont have length yet
			// #  == this is the length of the message that we are to recieve
			if(_expectedLength == -1)
			{
				res = [_inStream read:_write maxLength:sizeof(_buffer)];
				

#if 0
				if(res == 0)
				{
					DEBUG_ONLY(NSLog(@"EventAgent::handleEvent(): Closing connection on NULL read (socket closed)\n"));
					event_destroy_agent(a);
					return(NO);
				}
#endif

				if(res < (int)sizeof(_len)) // we need the first 4 byted for the total length
				{
					_expectedLength = 0;
				}
				else
				{
					uint8_t *temp = _buffer;
					BUFFER_READ_UINT32(temp, _len);

					if(_len > sizeof(_buffer)) 
					{
						fprintf(stderr,
						     "event too large: %d bytes (max = %d)\n", 
						     _len, 
						     sizeof(_buffer));
						return(NO);
					}
					_expectedLength = _len;
				}
				_write += res;
			}
			else
			{
				res = [_inStream read:_write maxLength:res];

#if 0
				if(res < 0)
				{
					DEBUG_ONLY(NSLog(@"Closing connection on read error\n"));
					event_destroy_agent(a);
					return 0;
				}

				if(res == 0)
				{
					DEBUG_ONLY(NSLog(@"Closing connection on NULL read (socket closed)\n"));
					event_destroy_agent(a);
					return 0;
				}
#endif

again:
				if(res < ((int)sizeof(_len) - (_write - _buffer)))
				{
					_expectedLength = 0;
				}
				else
				{
					uint8_t *temp = _buffer;
					BUFFER_READ_UINT32(temp, _len);
					if(_len > sizeof(_buffer)) 
					{
						NSLog(@"event too large: %d bytes (max = %d)\n", _len, sizeof(_buffer));
						return(NO);
					}
					_expectedLength = _len;
				}

				_write += res;
			}

			if( (_write - _buffer) >= _expectedLength &&
			    _expectedLength > 0)
			{
				uint8_t *temp = _buffer + 4;
				BUFFER_READ_UINT16(temp, _type);
				BUFFER_READ_UINT32(temp, _flags);
				NSData *data = [NSData dataWithBytesNoCopy:(_buffer + kMessageHeaderLength) length:(_len - kMessageHeaderLength)];
				
				DEBUG_ONLY(
					PrintPacket("EventAgent::handleEvent()", _type, _flags, [NSArray arrayWithObject:data]);
					
					// we have a message sitting in our buffer, now do it
					NSLog(@"Event received of type %d\n", _type);
				);
				NSObject<EventAgentMessageDelegate> *handler;
				if( (handler = [_handlers objectForKey:[NSNumber numberWithInt:_type]]))
				{
					[handler eventAgent:self messageReceivedWithType:_type flags:_flags payload:data];
				}
				else
				{
					NSLog(@"No handler for event type %d\n", _type);
				}

				// move the message over to the head of the
				res = _write - &_buffer[_expectedLength];

				memcpy(_buffer,
				       &_buffer[_expectedLength],
				       res);

				_write = _buffer; // i am going to move _write by res this in "again:"
				if(res)
					_expectedLength = 0;
				else
					_expectedLength = -1;

				goto again;
			}
			break;
		
		default:
			NSLog(@"EventAgent::handleMessage(): unknown event %d\n", eventCode);
			break;
	}
	return(ret);
}

/**
 * Add event handlers to the EventAgent
 * @param type  this is the event type
 * @param cb    the function to call when we recieve a message of type "type"
 * @param replace YES if you want this callback to replace an existing entry
 * @return YES if successfull (if replace == NO, and you are adding a 
 *              duplicate entry, then it will return NO)
 */
- (void)setMessageDelegate:(id<EventAgentMessageDelegate>)delegate forType:(uint16_t)type
{
	[_handlers setObject:delegate forKey:[NSNumber numberWithInt:type]];
}

/**
 * remove a EventAgent event handler
 * @param type the event handler type that will be deleted
 * @return YES if anything was deleted
 */
- (void)removeMessageDelegateForType:(uint16_t)type
{
	[_handlers removeObjectForKey:[NSNumber numberWithInt:type]];
}

/**
 * Default event handlers to the global EventAgent event handlers
 */
-  (void)defaultMessageDelegates
{
	[_handlers release];
	_handlers = [[NSMutableDictionary dictionary] retain];
}


@end
