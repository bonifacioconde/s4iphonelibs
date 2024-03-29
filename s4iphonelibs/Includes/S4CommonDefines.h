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
 * Name:		S4CommonDefines.h
 * Module:		Common
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>



// =================================== Defines =========================================

/*	S4DebugLog is almost a drop-in replacement for NSLog.  For example:
		S4DebugLog();
		S4DebugLog(@"here");
		S4DebugLog(@"value: %d", x);

	Unfortunately this doesn't work:		S4DebugLog(aStringVariable); 
	you have to do this instead:			S4DebugLog(@"%@", aStringVariable);

	*** TO SET THE DEBUG FLAG IN BUILDS ***
	If you are using OTHER_CFLAGS then set the value to -DDEBUG=1, if you are instead
	using GCC_PREPROCESSOR_DEFINITIONS then the value needs to be just DEBUG=1
*/
#ifdef DEBUG

#define S4DebugLog(fmt, ...)							NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define S4DebugLog(...)

#endif

// S4Log always displays output regardless of the DEBUG setting
#define S4Log(fmt, ...)									NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


// macro for performing all NULL tests on objects
#define IS_NOT_NULL(x)									((nil != x) && (![x isEqual: [NSNull null]]))

// macro for testing NSString's for non-NULL and having content
#define STR_NOT_EMPTY(x)								((nil != x) && (![x isEqual: [NSNull null]]) && ([x length] > 0))



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================
