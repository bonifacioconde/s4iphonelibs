/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the S4 iPhone Libraries.
 *
 * The Initial Developer of the Original Code is
 * Michael Papp dba SeaStones Software Company.
 * All software created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4HttpConnection.m
 * Module:		Network
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreFoundation/CoreFoundation.h>
#import "S4HttpConnection.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4HttpConnection (PrivateImpl) =====================

@interface S4HttpConnection (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end




@implementation S4HttpConnection (PrivateImpl)

//============================================================================
//	S4HttpConnection (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	S4HttpConnection (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end




// ====================== Begin Class S4HttpConnection =======================

@implementation S4HttpConnection

//============================================================================
//	S4HttpConnection :: init
//============================================================================
- (id)init
{
	id					idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_receivedData = [[NSMutableData data] retain];
		if (nil != m_receivedData)
		{
			m_nsURLConnection = nil;
			m_delegate = nil;
			m_bIsOpen = NO;

			idResult = self;
		}
	}
	return (idResult);
}


//============================================================================
//	S4HttpConnection :: dealloc
//============================================================================
- (void)dealloc
{
	m_bIsOpen = NO;

	if (nil != m_nsURLConnection)
	{
		[m_nsURLConnection release];
		m_nsURLConnection = nil;
	}

	if (nil != m_receivedData)
	{
		[m_receivedData release];
		m_receivedData = nil;
	}

	m_delegate = nil;	

	[super dealloc];
}


//============================================================================
//	S4HttpConnection :: openConnectionForPathStr
//============================================================================
- (BOOL)openConnectionForRequest: (NSURLRequest *)request delegate: (id)connectionDelegate
{
	BOOL							bResult = NO;

	if ((nil == m_nsURLConnection) && (nil != request) && (nil != connectionDelegate))
	{
		m_delegate = connectionDelegate;

		// create the connection with the request and start loading the data
		m_nsURLConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
		if (nil != m_nsURLConnection)
		{
			m_bIsOpen = YES;
			bResult = YES;
		}
	}
	return (bResult);
}


//============================================================================
//	S4HttpConnection :: cancelConnection
//============================================================================
- (void)cancelConnection
{
	if ((nil != m_nsURLConnection) && (YES == m_bIsOpen))
	{
		m_bIsOpen = NO;
		[m_nsURLConnection cancel];
	}
}


// ================================== NSURLConnection delegate methods ==========================================

//============================================================================
//	S4HttpConnection :: didReceiveResponse
//
// this method is called when the server has determined that it
// has enough information to create the NSURLResponse
// it can be called multiple times, for example in the case of a
// redirect, so each time we reset the data.
// m_receivedData is declared as a method instance elsewhere
//============================================================================
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
	long long		length;

	length = [response expectedContentLength];
    [m_receivedData setLength: 0];
}


//============================================================================
//	S4HttpConnection :: didReceiveData
//
// append the new data to the receivedData
// receivedData is declared as a method instance elsewhere
//============================================================================
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// append the data received
    [m_receivedData appendData: data];

	// notify the delegate
	if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:receivedData:)]))
	{
		if (NO == [m_delegate httpConnection: self receivedData: data])
		{
			[self cancelConnection];
		}
	}
}


//============================================================================
//	S4HttpConnection :: didFailWithError
//============================================================================
- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
{
	NSString			*errorStr;

	m_bIsOpen = NO;

	// generate a string with error details
	errorStr = [NSString stringWithFormat: @"Connection failed! Error - %@ %@",
				[error localizedDescription],
				[[error userInfo] objectForKey: NSErrorFailingURLStringKey]];

    // inform the delegate
	if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:failedWithErrorStr:)]))
	{
		[m_delegate httpConnection: self failedWithErrorStr: errorStr];
	}
    [errorStr release];
}


//============================================================================
//	S4HttpConnection :: connectionDidFinishLoading
//============================================================================
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	m_bIsOpen = NO;

	// inform the delegate
	if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:completedWithData:)]))
	{
		[m_delegate httpConnection: self completedWithData: m_receivedData];
	}

    NSLog(@"Succeeded! Received %d bytes of data", [m_receivedData length]);
}


//============================================================================
//	S4HttpConnection :: willSendRequest
//	Handles redirect requests
//============================================================================
- (NSURLRequest *)connection: (NSURLConnection *)connection willSendRequest: (NSURLRequest *)request redirectResponse: (NSURLResponse *)redirectResponse
{
	NSURLRequest			*newRequest;

	newRequest = request;
	if (nil != redirectResponse)
	{
		// inform the delegate of a redirect
		if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:receivedRedirectdirectRequest:forResponse:)]))
		{
			newRequest = [m_delegate httpConnection: self receivedRedirectdirectRequest: request forResponse: redirectResponse];
		}
	}
	return (newRequest);
	
}


//============================================================================
//	S4HttpConnection :: didReceiveAuthenticationChallenge
//	Handles HTTPS authentication challenges
//============================================================================
- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
/*
	NSURLCredential				*newCredential;

	if ([challenge previousFailureCount] == 0)
	{
		newCredential=[NSURLCredential credentialWithUser: [self preferencesName]
												 password: [self preferencesPassword]
											  persistence: NSURLCredentialPersistenceNone];

		[[challenge sender] useCredential: newCredential forAuthenticationChallenge: challenge];
	}
	else
	{
		[[challenge sender] cancelAuthenticationChallenge: challenge];

		// inform the user that the user name and password
		// in the preferences are incorrect
		[self showPreferencesCredentialsAreIncorrectPanel: self];
	}
*/
}


//============================================================================
//	S4HttpConnection :: willCacheResponse
//	Handles caching notification if user wants custom approach
//============================================================================
- (NSCachedURLResponse *)connection: (NSURLConnection *)connection willCacheResponse: (NSCachedURLResponse *)cachedResponse
{
	NSCachedURLResponse				*newCachedResponse;

	newCachedResponse = cachedResponse;
/*
	if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"])
	{
		newCachedResponse = nil;
	}
	else
	{		
		NSDictionary *newUserInfo;

		newUserInfo = [NSDictionary dictionaryWithObject: [NSCalendarDate date] forKey: @"Cached Date"];

		newCachedResponse = [[[NSCachedURLResponse alloc] initWithResponse: [cachedResponse response]
																	  data:[cachedResponse data]
																  userInfo:newUserInfo
															 storagePolicy:[cachedResponse storagePolicy]] autorelease];
	}
*/
	return (newCachedResponse);
}


@end
