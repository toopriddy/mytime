//
//  NSData_PSCompress.m
//  MyTime
//
//  Created by Brent Priddy on 4/7/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSData+PSCompress.h"
#import "zlib.h"

@implementation NSData (PSCompress)

#define ZLIB_COMPRESS_DOMAIN @"zlib_compress_domain"

NSData* compressData(NSData *inData) 
{
	NSUInteger uncompressedLength = [inData length];
	if (uncompressedLength == 0) 
		return inData;
	const Bytef *inBytes = (const Bytef *)[inData bytes];
	uLongf outLength = (uncompressedLength * 1.1) + 12;
	Bytef *outBytes = (Bytef *)malloc(4 + outLength);
	*(uint32_t *)outBytes = htonl(uncompressedLength);
	Bytef *compressStart = outBytes + 4;
	int z_result = compress(compressStart, &outLength, inBytes, uncompressedLength); 
	NSData *ret;
	if (z_result == Z_OK) 
	{
		ret = [NSData dataWithBytesNoCopy:outBytes length:(outLength + 4) freeWhenDone:YES];
	} 
	else 
	{
		ret = [NSData data];
		switch (z_result) 
		{
			case Z_MEM_ERROR:
				printf("compressData got Z_MEM_ERROR out of memory. :(");
			case Z_BUF_ERROR:
				printf("compressData got Z_BUF_ERROR output buffer wasn't larege enough :(");
			default:
				break;
		}
	}
	return ret;
}

NSError* compressData2(NSData *inData, NSData **outData) 
{
	NSUInteger uncompressedLength = [inData length];
	if (uncompressedLength == 0) 
	{
		*outData = inData;
		return nil;
	}
	const Bytef *inBytes = (const Bytef *)[inData bytes];
	uLongf outLength = (uncompressedLength * 1.1) + 12;
	Bytef *outBytes = (Bytef *)malloc(4 + outLength);
	*(uint32_t *)outBytes = htonl(uncompressedLength);
	Bytef *compressStart = outBytes + 4;
	int z_result = compress(compressStart, &outLength, inBytes, uncompressedLength); 
	if (z_result == Z_OK) 
	{
		*outData = [NSData dataWithBytesNoCopy:outBytes length:(outLength + 4) freeWhenDone:YES];
		free(outBytes);
		return nil;
	}
	return [NSError errorWithDomain:ZLIB_COMPRESS_DOMAIN 
							   code:z_result userInfo:[NSDictionary dictionary]];
}

NSData* decompressData(NSData *inData) 
{
	NSUInteger compressedLength = [inData length];
	if (compressedLength == 0) 
		return inData;
	const Bytef *tempInBytes = (const Bytef *)[inData bytes];
	uLongf outLength = ntohl(*(uint32_t *)tempInBytes);
	const Bytef *inBytes = tempInBytes + 4;
	
	Bytef *outBytes = (Bytef *)malloc(outLength);
	int z_result = uncompress(outBytes, &outLength, inBytes, compressedLength);
	NSData *ret;
	if (z_result == Z_OK) 
	{
		ret = [NSData dataWithBytesNoCopy:outBytes length:outLength freeWhenDone:YES];
	} 
	else 
	{
		ret = [NSData data];
		switch (z_result) 
		{
			case Z_MEM_ERROR:
				printf("compressData got Z_MEM_ERROR out of memory. :(");
			case Z_BUF_ERROR:
				printf("compressData got Z_BUF_ERROR output buffer wasn't larege enough :(");
			default:
				break;
		}
	}
	return ret;
}

NSError* decompressData2(NSData *inData, NSData **outData) 
{
	NSUInteger compressedLength = [inData length];
	if (compressedLength == 0) 
	{
		*outData = inData;
		return nil;
	}
	const Bytef *tempInBytes = (const Bytef *)[inData bytes];
	uLongf outLength = ntohl(*(uint32_t *)tempInBytes);
	const Bytef *inBytes = tempInBytes + 4;
	
	Bytef *outBytes = (Bytef *)malloc(outLength);
	int z_result = uncompress(outBytes, &outLength, inBytes, compressedLength); 
	if (z_result == Z_OK) 
	{
		*outData = [NSData dataWithBytesNoCopy:outBytes length:outLength freeWhenDone:YES];
		free(outBytes);
		return nil;
	}
	return [NSError errorWithDomain:ZLIB_COMPRESS_DOMAIN 
							   code:z_result userInfo:[NSDictionary dictionary]];
}

- (NSData *)compress
{ 
	return compressData(self);
}

- (NSData *)compress:(NSError **)errorOut 
{
	NSData *ret;
	NSError *substitute;
	if(errorOut == nil)
		errorOut = &substitute;
	*errorOut = compressData2(self, &ret);
	return ret;
}

- (NSData *)decompress
{ 
	return decompressData(self);
}

- (NSData *)decompress:(NSError **)errorOut 
{
	NSData *ret;
	NSError *substitute;
	if(errorOut == nil)
		errorOut = &substitute;
	*errorOut = decompressData2(self, &ret);
	return ret;
}


@end
