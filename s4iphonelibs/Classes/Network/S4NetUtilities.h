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
 * Name:		S4NetUtilities.h
 * Module:		Network
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================

/*
 An enumeration that defines the return values of the network state
 of the device.
 */
typedef enum
{
	NotReachable = 0,
	ReachableViaCarrierDataNetwork,
	ReachableViaWiFiNetwork
} NetworkStatus;



// ================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4NetUtilities ===================================

@interface S4NetUtilities : NSObject
{

}

+ (NSURL *)createNSUrlForPathStr: (NSString *)path baseStr: (NSString *)base;
+ (NSURLRequest *)createRequestForURL: (NSURL *)url useCache: (BOOL)bUseCache timeoutInterval: (NSTimeInterval)timeoutInSec bodyData: (NSData *)data handleCookies: (BOOL)bHandleCookies;
+ (BOOL)isReachableWithoutRequiringConnection: (SCNetworkReachabilityFlags)flags;
+ (BOOL)isNetworkAvailableFlags: (SCNetworkReachabilityFlags *)outFlags;
+ (NetworkStatus)internetConnectionStatus;
+ (BOOL)isHostReachable: (NSString *)host;
+ (BOOL)isAdHocWiFiNetworkAvailableFlags: (SCNetworkReachabilityFlags *)outFlags;
+ (NetworkStatus)localWiFiConnectionStatus;

@end
