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
 * Name:		S4CoreLocationManager.m
 * Module:		
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreFoundation/CoreFoundation.h>
#import "S4CoreLocationManager.h"


// ================================== Defines ==========================================

//#define DEFAULT_TIMEOUT_INTERVAL		(NSTimeInterval)60.0


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================

// holds the singleton
static S4CoreLocationManager				*g_clsInstance = nil;



// ================= Begin Class S4CoreLocationManager (PrivateImpl) ===================

@interface S4CoreLocationManager (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end



@implementation S4CoreLocationManager (PrivateImpl)

//============================================================================
//	S4CoreLocationManager (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	S4CoreLocationManager (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end



// ==================== Begin Class S4CoreLocationManager ====================

@implementation S4CoreLocationManager

@synthesize m_CLLocationManager;
@synthesize m_delegate;


//============================================================================
//	S4CoreLocationManager :: getInstance
//============================================================================
+ (S4CoreLocationManager *)getInstance
{
	@synchronized(self)
	{
		if (nil == g_clsInstance)
		{
			[[self alloc] init];			// assignment not done here
		}
	}
	return (g_clsInstance);
}


//============================================================================
//	S4CoreLocationManager :: init
//============================================================================
- (id)init
{
	if (nil == g_clsInstance)
	{
		self = [super init];
		if (nil != self)
		{
			// set up the CoreLocationManager member var and set self as delegate
			self.m_CLLocationManager = [[[CLLocationManager alloc] init] autorelease];
			if (nil != self.m_CLLocationManager)
			{
				self.m_CLLocationManager.delegate = self;

				m_delegate = nil;
				m_bIsRunning = NO;
				m_distanceTraveled = 0;
				m_updateIntervalTime = 0;
				m_curLocation = nil;
				m_lastLocation = self.m_CLLocationManager.location;

				// finally, set the global var for the singleton object
				g_clsInstance = self;
			}
		}
	}
	return (g_clsInstance);
}


//============================================================================
//	S4CoreLocationManager :: copyWithZone
//============================================================================
- (id)copyWithZone: (NSZone *)zone
{
	return (self);
}


//============================================================================
//	S4CoreLocationManager :: retain
//============================================================================
- (id)retain
{
	return (self);
}


//============================================================================
//	S4CoreLocationManager :: retainCount
//============================================================================
- (unsigned)retainCount
{
	return (UINT_MAX);		// denotes an object that cannot be released
}


//============================================================================
//	S4CoreLocationManager :: release
//============================================================================
- (void)release
{
	// do nothing
}


//============================================================================
//	S4CoreLocationManager :: autorelease
//============================================================================
- (id)autorelease
{
	return (self);
}



/**************************************************  Location Methods ****************************************************/

//============================================================================
//	S4CoreLocationManager :: startUpdatesWithAccuracy
//============================================================================
- (void)startUpdatesWithAccuracy: (LocationAccuracy)newAccuracy
{
	[self setAccuracy: newAccuracy];

	// start up the CLLocationManager
	[self.m_CLLocationManager startUpdatingLocation];
	m_bIsRunning = YES;
}


//============================================================================
//	S4CoreLocationManager :: startUpdatesWithAccuracy
//============================================================================
- (void)stopUpdates
{
	[self.m_CLLocationManager stopUpdatingLocation];
	m_bIsRunning = NO;
}


//============================================================================
//	S4CoreLocationManager :: setAccuracy
//============================================================================
- (void)setAccuracy: (LocationAccuracy)newAccuracy
{
	if (kHighestAccuracy == newAccuracy)
	{
		self.m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.m_CLLocationManager.distanceFilter = kCLDistanceFilterNone;
	}
	else if (kHighAccuracy == newAccuracy)
	{
		self.m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		self.m_CLLocationManager.distanceFilter = 10;
	}
	else if (kMediumAccuracy == newAccuracy)
	{
		self.m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		self.m_CLLocationManager.distanceFilter = 100;
	}
	else if (kLowAccuracy == newAccuracy)
	{
		self.m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		self.m_CLLocationManager.distanceFilter = 1000;
	}
	else if (kLowestAccuracy == newAccuracy)
	{
		self.m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
		self.m_CLLocationManager.distanceFilter = 3000;
	}
	else if (kDefaultAccuracy == newAccuracy)
	{
		// leave current settings
	}
}


//============================================================================
//	S4CoreLocationManager :: locationServicesAvailable
//============================================================================
- (BOOL)locationServicesAvailable
{
	return (self.m_CLLocationManager.locationServicesEnabled);
}


//============================================================================
//	S4CoreLocationManager :: lastLocation
//============================================================================
- (CLLocation *)lastLocation
{
	if (nil != m_lastLocation)
	{
		return (m_lastLocation);
	}
	return (self.m_CLLocationManager.location);
}



/********************************************* Methods performed on the Main Thread  *********************************************/

//============================================================================
//	S4CoreLocationManager :: receivedUpdate
//============================================================================
- (void)receivedUpdate: (CLLocation *)newLocation
{
	// Send the update to our delegate
	if ((self.m_delegate != nil) && ([self.m_delegate respondsToSelector: @selector(coreLocManager:newLocationUpdate:)]))
	{
		[self.m_delegate coreLocManager: self newLocationUpdate: newLocation];
	}
}


//============================================================================
//	S4CoreLocationManager :: receivedError
//============================================================================
- (void)receivedError: (NSString *)errorString
{
	// Send the update to our delegate
	if ((self.m_delegate != nil) && ([self.m_delegate respondsToSelector: @selector(coreLocManager:newError:)]))
	{
		[self.m_delegate coreLocManager: self newError: errorString];
	}
}



/******************************************  CLLocationManager Delegate Methods ******************************************/

//============================================================================
//	S4CoreLocationManager :: didUpdateToLocation
//============================================================================
- (void)locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *)newLocation fromLocation: (CLLocation *)oldLocation
{
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy))
	{
		// Negative accuracy means an invalid or unavailable measurement
	}
	else
	{
		m_curLocation = newLocation;
	}

	if (oldLocation != nil)
	{
		m_distanceTraveled = [newLocation getDistanceFrom: oldLocation];
		m_updateIntervalTime = [newLocation.timestamp timeIntervalSinceDate: oldLocation.timestamp];
	}

	// Send the update to our delegate on the main thread
	[self performSelectorOnMainThread: @selector(receivedUpdate:) withObject: newLocation waitUntilDone: NO];
}


//============================================================================
//	S4CoreLocationManager :: didFailWithError
//============================================================================
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
	NSMutableString						*errorString;

	errorString = [[[NSMutableString alloc] init] autorelease];
	if ([error domain] == kCLErrorDomain)
	{
		switch ([error code])
		{
			case kCLErrorDenied:
				[errorString appendFormat: @"%@\n", @"LocationDenied"];
				m_bIsRunning = NO;
				break;
			case kCLErrorLocationUnknown:
				[errorString appendFormat: @"%@\n", @"LocationUnknown"];
				break;
			default:
				[errorString appendFormat: @"%@ %d\n", @"GenericLocationError", [error code]];
				break;
		}
	}
	else
	{
		[errorString appendFormat: @"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat: @"Description: \"%@\"\n", [error localizedDescription]];
	}

	// Send the update to our delegate on the main thread
	[self performSelectorOnMainThread: @selector(receivedError:) withObject: errorString waitUntilDone: NO];
}

@end
