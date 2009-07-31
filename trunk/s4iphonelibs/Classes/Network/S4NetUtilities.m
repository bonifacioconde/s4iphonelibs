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
 * Name:		S4NetUtilities.m
 * Module:		Network
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================

#define DEFAULT_TIMEOUT_INTERVAL		(NSTimeInterval)120.0


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4NetUtilities (PrivateImpl) ======================

@interface S4NetUtilities (PrivateImpl)

+ (void)placeHolder1;
+ (void)placeHolder2;

@end




@implementation S4NetUtilities (PrivateImpl)

//============================================================================
//	S4NetUtilities (PrivateImpl) :: placeHolder1
//============================================================================
+ (void)placeHolder1
{
}


//============================================================================
//	S4NetUtilities (PrivateImpl) :: placeHolder2
//============================================================================
+ (void)placeHolder2
{
}

@end




// ============================== Begin Class S4NetUtilities =========================

@implementation S4NetUtilities

//============================================================================
//	S4NetUtilities : createNSUrlForPathStr
//============================================================================
+ (NSURL *)createNSUrlForPathStr: (NSString *)path baseStr: (NSString *)base
{
	CFStringRef				rawPathStr;
	CFStringRef				rawBaseStr;
	CFStringRef				prePathStr;
	CFStringRef				preBaseStr;
	CFStringRef				pathUrlStr;
	CFStringRef				baseUrlStr;
	CFURLRef				baseURL = NULL;
	BOOL					bError = NO;
	NSURL					*nsUrlResult = nil;
	
	if ((nil != base) && ([base length] > 0))
	{
		rawBaseStr = (CFStringRef)base;
		preBaseStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, rawBaseStr, CFSTR(""), kCFStringEncodingUTF8);
		if (NULL != preBaseStr)
		{
			baseUrlStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preBaseStr, NULL, NULL, kCFStringEncodingUTF8);
			if (NULL != baseUrlStr)
			{
				baseURL = CFURLCreateWithString(kCFAllocatorDefault, baseUrlStr, NULL);
				CFRelease(baseUrlStr);
			}
			CFRelease(preBaseStr);
		}
		
		if (NULL == baseURL)
		{
			bError = YES;
		}
	}
	
	if ((nil != path) && ([path length] > 0) && (NO == bError))
	{
		rawPathStr = (CFStringRef)path;
		prePathStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, rawPathStr, CFSTR(""), kCFStringEncodingUTF8);
		if (NULL != prePathStr)
		{
			pathUrlStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, prePathStr, NULL, NULL, kCFStringEncodingUTF8);
			if (NULL != pathUrlStr)
			{
				nsUrlResult = (NSURL *)CFURLCreateWithString(kCFAllocatorDefault, pathUrlStr, baseURL);
				CFRelease(pathUrlStr);
			}
			CFRelease(prePathStr);
		}
	}
	return (nsUrlResult);
}


//============================================================================
//	S4NetUtilities :: createRequestForURL
//============================================================================
+ (NSURLRequest *)createRequestForURL: (NSURL *)url useCache: (BOOL)bUseCache timeoutInterval: (NSTimeInterval)timeoutInSec bodyData: (NSData *)data handleCookies: (BOOL)bHandleCookies
{
	NSMutableURLRequest				*requestResult = nil;

	if (nil != url)
	{
		requestResult = [[NSMutableURLRequest alloc] init];
		if (nil != requestResult)
		{
			[requestResult setURL: url];

			if (nil != data)
			{
				[requestResult setHTTPMethod:@"POST"];
				[requestResult setHTTPBody: data];
			}
			else
			{
				[requestResult setHTTPMethod:@"GET"];
			}

			if (YES == bUseCache)
			{
				[requestResult setCachePolicy: NSURLRequestUseProtocolCachePolicy];
			}
			else
			{
				[requestResult setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
			}

			if (0 < timeoutInSec)
			{
				[requestResult setTimeoutInterval: timeoutInSec];
			}
			else
			{
				[requestResult setTimeoutInterval: DEFAULT_TIMEOUT_INTERVAL];
			}

			[requestResult setHTTPShouldHandleCookies: bHandleCookies];
			[requestResult setValue: @"gzip" forHTTPHeaderField: @"Accept-Encoding"];
			[requestResult setValue: @"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField: @"User-Agent"];
		}
	}
	return (requestResult);
}


//============================================================================
//	S4NetUtilities :: isReachableWithoutRequiringConnection
//============================================================================
+ (BOOL)isReachableWithoutRequiringConnection: (SCNetworkReachabilityFlags)flags
{
	BOOL				bResult;

	bResult = ((flags & kSCNetworkReachabilityFlagsReachable) && ((!(flags & kSCNetworkReachabilityFlagsConnectionRequired)) || (flags & kSCNetworkReachabilityFlagsIsWWAN)));
	return (bResult);
}


//============================================================================
//	S4NetUtilities :: isNetworkAvailableFlags
//============================================================================
+ (BOOL)isNetworkAvailableFlags: (SCNetworkReachabilityFlags *)outFlags
{
	struct sockaddr_in				sockAddress;
	SCNetworkReachabilityRef		networkReachability;
	SCNetworkReachabilityFlags		flags;
	BOOL							bResult = NO;

	bzero(&sockAddress, sizeof(sockAddress));
	sockAddress.sin_len = sizeof(sockAddress);
	sockAddress.sin_family = AF_INET;

	networkReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&sockAddress);
	if (NULL != networkReachability)
	{
		if (YES == SCNetworkReachabilityGetFlags(networkReachability, &flags))
		{
			bResult = [S4NetUtilities isReachableWithoutRequiringConnection: flags];
			if (NULL != outFlags)
			{
				*outFlags = flags;
			}
		}
		CFRelease(networkReachability);
	}
	return (bResult);
}


//============================================================================
//	S4NetUtilities :: internetConnectionStatus
//============================================================================
+ (NetworkStatus)internetConnectionStatus
{
	SCNetworkReachabilityFlags				defaultRouteFlags;
	NetworkStatus							netStatusResult = NotReachable;

	if (YES == [S4NetUtilities isNetworkAvailableFlags: &defaultRouteFlags])
	{
		if (defaultRouteFlags & kSCNetworkReachabilityFlagsIsDirect)
		{
			// The connection is to an ad-hoc WiFi network, so Internet access is not available.
			netStatusResult = NotReachable;
		}
		else if (defaultRouteFlags & ReachableViaCarrierDataNetwork)
		{
			netStatusResult = ReachableViaCarrierDataNetwork;
		}
		else
		{
			netStatusResult = ReachableViaWiFiNetwork;
		}
	}
	return (netStatusResult);
}


//============================================================================
//	S4NetUtilities :: isHostReachable
//============================================================================
+ (BOOL)isHostReachable: (NSString *)host
{
	SCNetworkReachabilityRef			reachability;
	SCNetworkReachabilityFlags			flags;
	BOOL								bResult = NO;

	if ((nil != host) && ([host length] > 0))
	{
		reachability = SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
		if (NULL != reachability)
		{
			if (YES == SCNetworkReachabilityGetFlags(reachability, &flags))
			{
				bResult = [S4NetUtilities isReachableWithoutRequiringConnection: flags];
			}
			CFRelease(reachability);
		}
	}
	return (bResult);
}


//============================================================================
//	S4NetUtilities :: isAdHocWiFiNetworkAvailableFlags
//============================================================================
+ (BOOL)isAdHocWiFiNetworkAvailableFlags: (SCNetworkReachabilityFlags *)outFlags
{
	struct sockaddr_in					sockAddr;
	SCNetworkReachabilityRef			adHocWiFiNetworkReachability;
	SCNetworkReachabilityFlags			addressReachabilityFlags;
	BOOL								bResult = NO;

	bzero(&sockAddr, sizeof(sockAddr));
	sockAddr.sin_len = sizeof(sockAddr);
	sockAddr.sin_family = AF_INET;
	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	sockAddr.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	adHocWiFiNetworkReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&sockAddr);
	if (NULL != adHocWiFiNetworkReachability)
	{
		if (YES == SCNetworkReachabilityGetFlags(adHocWiFiNetworkReachability, &addressReachabilityFlags))
		{
			bResult = [S4NetUtilities isReachableWithoutRequiringConnection:addressReachabilityFlags];
			if (NULL != outFlags)
			{
				*outFlags = addressReachabilityFlags;
			}
		}
		CFRelease(adHocWiFiNetworkReachability);
	}
	return (bResult);
}


//============================================================================
//	S4NetUtilities :: localWiFiConnectionStatus
//============================================================================
+ (NetworkStatus)localWiFiConnectionStatus
{
	SCNetworkReachabilityFlags			selfAssignedAddressFlags;
	BOOL								hasLinkLocalNetworkAccess;
	NetworkStatus						netStatusResult = NotReachable;

	// This returns YES if the address 169.254.0.0 is reachable without requiring a connection.
	hasLinkLocalNetworkAccess = [S4NetUtilities isAdHocWiFiNetworkAvailableFlags: &selfAssignedAddressFlags];
	if (hasLinkLocalNetworkAccess && (selfAssignedAddressFlags & kSCNetworkReachabilityFlagsIsDirect))
	{
		netStatusResult = ReachableViaWiFiNetwork;
	}
	return (netStatusResult);
}

@end
