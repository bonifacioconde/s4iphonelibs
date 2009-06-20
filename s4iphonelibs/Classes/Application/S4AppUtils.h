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
 * Name:		S4AppUtils.h
 * Module:		S4 iPhone Libraries
 * Library:		
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



// ================================== Typedefs =========================================

typedef enum
{
	UIDeviceUnknown,
	UIDevice1GiPhone,
	UIDevice1GiPod,
	UIDevice3GiPhone,
	UIDevice2GiPod,
	UIDeviceUnknowniPhone,
	UIDeviceUnknowniPod
} UIDeviceType;


typedef enum
{
	UIDeviceNoCapabilities = 0,
	UIDeviceSupportsGPS	= 1 << 0,
	UIDeviceBuiltInSpeaker = 1 << 1,
	UIDeviceBuiltInCamera = 1 << 2,
	UIDeviceBuiltInMicrophone = 1 << 3,
	UIDeviceSupportsExternalMicrophone = 1 << 4,
	UIDeviceSupportsTelephony = 1 << 5,
	UIDeviceSupportsVibration = 1 << 6
} UIDeviceCapabilities;




// ================================== Globals =========================================



// ====================================================================================

@interface S4AppUtils : NSObject
{
@private
	NSString									*m_ProducteName;
	NSString									*m_RawDeviceName;
	UIDeviceType								m_DeviceType;
}

+ (S4AppUtils *)getInstance;

- (NSString *)productName;

- (void)openApplicationWithUrlStr: (NSString *)urlStr;

- (BOOL)canUseMailComposer;
- (void)sendCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr body: (NSString *)bodyStr;
- (void)sendHtmlCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr htmlBody: (NSString *)htmlBodyStr;
- (BOOL)sendComposerMailForController: (UIViewController *)viewController
						  toAddresses: (NSArray *)toRecipients
						  ccAddresses: (NSArray *)ccRecipients
						 bccAddresses: (NSArray *)bccRecipients
						  mailBodyStr: (NSString *)emailBody
							   isHTML: (BOOL)bIsHTML
					   attachmentData: (NSData *)attachData
				   attachmentMimeType: (NSString *)attachMimeType
				   attachmentFileName: (NSString *)attachFileName
						  mailSubject: (NSString *)subject;

- (void)openMapsWithAddressStr: (NSString *)addressStr city: (NSString *)cityStr state: (NSString *)stateStr zip: (NSString *)zipStr;
- (void)openMapsWithLatitude: (double)dLatitude longitude: (double)dLongitude;
- (void)openMapsAtStartingAddress: (NSString *)srcAddressStr
						  srcCity: (NSString *)srcCityStr
						 srcState: (NSString *)srcStateStr
						   srcZip: (NSString *)srcZipStr
					   dstAddress: (NSString *)dstAddressStr
						  dstCity: (NSString *)dstCityStr
						 dstState: (NSString *)dstStateStr
						   dstZip: (NSString *)dstZipStr;
- (void)placeCallWithPhoneNumStr: (NSString *)phoneNumberStr;
- (void)sendSmsTextMsgWithPhoneNumStr: (NSString *)phoneNumberStr;

- (BOOL)isLocaleMetric;
- (NSString *)isoCountry;
- (NSString *)isoLanguage;
- (NSString *)displayCountry;
- (NSString *)displayLanguage: (NSString *)isoLanguage;
- (NSString *)displayLanguage;

- (UIDeviceType)deviceType;
- (UIDeviceCapabilities)deviceCapabilities;
- (NSString *)deviceName;

@end
