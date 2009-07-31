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
 * Name:		S4AppUtils.m
 * Module:		Application
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

//#import "UIDevice-hardware.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "S4AppUtils.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"
#include <sys/types.h>
#include <sys/sysctl.h>


// =================================== Defines =========================================

#define MIN_PHONE_NUM_LEN				8		// "555-5555"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

// holds the singleton
static S4AppUtils						*g_clsInstance = nil;

// Lock for sensitive operations
static NSLock							*g_nsLock = nil;

// defined locales
//static NSString							*kAustraliaLocale		= @"AU";		// Australia
//static NSString							*kAustriaLocale			= @"AT";		// Austria
//static NSString							*kBelguimLocale			= @"BE";		// Belgium
//static NSString							*kBrazilLocale			= @"BR";		// Brazil
//static NSString							*kCanadaaLocale			= @"CA";		// Canada
//static NSString							*kSwitzerlandLocale		= @"CH";		// Switzerland
//static NSString							*kCzechLocale			= @"CZ";		// Czech Republic
//static NSString							*kDeutchlandLocale		= @"DE";		// Germany
//static NSString							*kDenmarkLocale			= @"DK";		// Denmark
//static NSString							*kSpainLocale			= @"ES";		// Spain
//static NSString							*kHungaryLocale			= @"HU";		// Hungary
//static NSString							*kJapanLocale			= @"JP";		// Japan
static NSString							*kGreatBritainLocale	= @"GB";		// Great Britain
//static NSString							*kItalyLocale			= @"IT";		// Italy
//static NSString							*kMalaysiaLocale		= @"MY";		// Malaysia
//static NSString							*kNetherlandsLocale		= @"NL";		// The Netherlands
//static NSString							*kPolandLocale			= @"PL";		// Poland
//static NSString							*UnitedStatesLocale		= @"US";		// United States
//static NSString							*kSingaporeLocale		= @"SG";		// Singapore
//static NSString							*kTurkeyLocale			= @"TR";		// Turkey


/////////////////////////////////////// mailTo URL scheme
static NSString							*kMailToFormatStr			= @"mailto:%@?subject=%@&body=%@";
static NSString							*kCCMailToFormatStr			= @"mailto:%@?cc=%@&subject=%@&body=%@";


////////////////////////////////////////////////////////////  Google Maps Query Format  ////////////////////////////////////////////////
//	 Parameter		Notes
//
//		q=			The query parameter. This parameter is treated as if it had been typed into the query box by the user on the 
//						maps.google.com page. q=* is not supported
//		near=		The location part of the query.
//		ll=			The latitude and longitude points (in decimal format, comma separated, and in that order) for the map center point.
//		sll=		The latitude and longitude points from which a business search should be performed.
//		spn=		The approximate latitude and longitude span.
//		sspn=		A custom latitude and longitude span format used by Google.
//		t=			The type of map to display.
//		z=			The zoom level.
//		saddr=		The source address, which is used when generating driving directions
//		daddr=		The destination address, which is used when generating driving directions.
//		latlng=		A custom ID format that Google uses for identifying businesses.
//		cid=		A custom ID format that Google uses for identifying businesses. 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// maps URL scheme
static NSString							*kiPhoneMapsFormatStr		= @"http://maps.google.com/maps?q=%@";
static NSString							*kMapsBaseFormatStr			= @"%@+%@,+%@";
static NSString							*kMapsGenericFormatStr		= @"%@+%@";
static NSString							*kMapsLatLonFormatStr		= @"http://maps.google.com/maps?ll=%f,%f";
static NSString							*kMapsDirectionFormatStr	= @"http://maps.google.com/maps?daddr=%@&saddr=%@";


/////////////////////////////////////// telephone URL scheme  -  must be of the format: 1-408-555-5555
static NSString							*kTelphoneFormatStr			= @"tel:%@";


////////////////////////////////////////////////////////////////  Apple SMS Format  /////////////////////////////////////////////////////
// The sms scheme is used to launch the Text application. The format for URLs of this type is “sms:<phone>”, where <phone> 
//  is an optional parameter that specifies the target phone number of the SMS message. This parameter can contain the
//  digits 0 through 9 and the plus (+), hyphen (-), and period (.) characters. The URL string must not include any message
//  text or other information.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// sms URL scheme  -  must be of the format: 1-408-555-1212
static NSString							*kSMSFormatStr				= @"sms:%@";


// Device Name Constants
static NSString							*kIPHONE_1G_NAME			= @"iPhone 1G";
static NSString							*kIPHONE_3G_NAME			= @"iPhone 3G";
static NSString							*kIPHONE_UNKNOWN_NAME		= @"Unknown iPhone";
static NSString							*kIPOD_1G_NAME				= @"iPod touch 1G";
static NSString							*kIPOD_2G_NAME				= @"iPod touch 2G";
static NSString							*kIPOD_UNKNOWN_NAME			= @"Unknown iPod";



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4AppUtils (PrivateImpl) ==========================

@interface S4AppUtils (PrivateImpl)

- (NSString *)cleanUpUSPhoneNumberStr: (NSString *)phoneNumberStr;
- (NSString *)buildMapUrlStr: (NSString *)addressStr city: (NSString *)cityStr state: (NSString *)stateStr zip: (NSString *)zipStr;
- (NSString *)rawDeviceName;

@end




@implementation S4AppUtils (PrivateImpl)

//============================================================================
//	S4AppUtils (PrivateImpl) :: cleanUpUSPhoneNumber
//============================================================================
- (NSString *)cleanUpUSPhoneNumberStr: (NSString *)phoneNumberStr
{
	NSString					*noPoundSignStr;
	NSString					*noAsteriskStr;
	NSString					*trimmedStr;
	NSRange						extensionRange;
	NSString					*noExtStr;
	NSString					*resultStr = nil;

	if ((nil != phoneNumberStr) && ([phoneNumberStr length] >= MIN_PHONE_NUM_LEN))
	{
		noPoundSignStr = [phoneNumberStr stringByReplacingOccurrencesOfString: @"#" withString : @""];
		noAsteriskStr = [noPoundSignStr stringByReplacingOccurrencesOfString: @"*" withString : @""];

		// first trim the string
		trimmedStr = [noAsteriskStr stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

		// first remove "xNNN" extensions from number
		extensionRange = [trimmedStr rangeOfString: @"x"];
		if ((extensionRange.length > 0) && (extensionRange.location >= 12))
		{
			noExtStr = [trimmedStr substringToIndex: extensionRange.location];
		}
		else
		{
			noExtStr = trimmedStr;
		}
		resultStr = noExtStr;
	}
	return (resultStr);
}


//============================================================================
//	S4AppUtils (PrivateImpl) :: buildMapUrlStr
//============================================================================
- (NSString *)buildMapUrlStr: (NSString *)addressStr city: (NSString *)cityStr state: (NSString *)stateStr zip: (NSString *)zipStr
{
	NSString				*tmpMapStr = nil;
	NSString				*cleanMapStr = nil;
	NSString				*resultMapStr = nil;
	
	if ((nil != addressStr) && (nil != cityStr) && (nil != stateStr))
	{
		// tmpMapStr looks like this: "1240 Clement St.+San Francisco,+CA"
		tmpMapStr = [NSString stringWithFormat: kMapsBaseFormatStr, addressStr, cityStr, stateStr];
		
		// cleanMapStr looks like this: "1240+Clement+St.+San+Francisco,+CA"
		cleanMapStr = [tmpMapStr stringByReplacingOccurrencesOfString: @" " withString: @"+"];
		
		if (nil != zipStr)
		{
			resultMapStr = [NSString stringWithFormat: kMapsGenericFormatStr, cleanMapStr, zipStr];
		}
		else
		{
			resultMapStr = cleanMapStr;
		}
	}
	return (resultMapStr);
}


//============================================================================
//	S4AppUtils (PrivateImpl) :: rawDeviceName
//============================================================================
- (NSString *)rawDeviceName
{
	size_t				sizeOfNameStr;
	char				*pNameStr;
	
	if (nil == m_RawDeviceName)
	{
		sysctlbyname("hw.machine", NULL, &sizeOfNameStr, NULL, 0);
		if (sizeOfNameStr > 0)
		{
			pNameStr = malloc(sizeOfNameStr);
			if (nil != pNameStr)
			{
				sysctlbyname("hw.machine", pNameStr, &sizeOfNameStr, NULL, 0);
				m_RawDeviceName = [NSString stringWithCString: pNameStr encoding: NSUTF8StringEncoding];
				free(pNameStr);
			}
		}
	}
	return (m_RawDeviceName);
}

@end




// ============================== Begin Class S4AppUtils =============================

@implementation S4AppUtils


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: getInstance
//============================================================================
+ (S4AppUtils *)getInstance
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
//	S4AppUtils :: init
//============================================================================
- (id)init
{
	if (nil == g_clsInstance)
	{
		self = [super init];
		if (nil != self)
		{
			m_ProducteName = nil;
			m_RawDeviceName = nil;
			m_DeviceType = UIDeviceUnknown;
			g_clsInstance = self;
			g_nsLock = [[NSRecursiveLock alloc] init];
		}
	}
	return (g_clsInstance);
}


//============================================================================
//	S4AppUtils :: copyWithZone
//============================================================================
- (id)copyWithZone: (NSZone *)zone
{
	return (self);
}


//============================================================================
//	S4AppUtils :: retain
//============================================================================
- (id)retain
{
	return (self);
}


//============================================================================
//	S4AppUtils :: retainCount
//============================================================================
- (unsigned)retainCount
{
	return (UINT_MAX);		// denotes an object that cannot be released
}


//============================================================================
//	S4AppUtils :: release
//============================================================================
- (void)release
{
	// do nothing
}


//============================================================================
//	S4AppUtils :: autorelease
//============================================================================
- (id)autorelease
{
	return (self);
}


///////////////////////////////////// INSTANCE METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: productName
//============================================================================
- (NSString *)productName
{
	if (nil == m_ProducteName)
	{
		m_ProducteName = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleDisplayName"];
	}
	return (m_ProducteName);
}



//============================================================================
//	S4AppUtils :: openApplicationWithUrlStr:
//============================================================================
- (void)openApplicationWithUrlStr: (NSString *)urlStr
{
	NSURL						*url;

	if (STR_NOT_EMPTY(urlStr))
	{
		// create a properly escaped NSURL from the string params
		url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
		if (nil != url)
		{
			[[UIApplication sharedApplication] openURL: url];
		}
	}
}


///////////////////////////////////// MAIL METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: canUseMailComposer
//============================================================================
- (BOOL)canUseMailComposer
{
	Class			mailComposerClass;
	BOOL			bResult = NO;

	mailComposerClass = NSClassFromString(@"MFMailComposeViewController");
	if (nil != mailComposerClass)
	{
		// We must always check whether the current device is configured for sending emails
		bResult = [MFMailComposeViewController canSendMail];
	}
	return (bResult);
}


//============================================================================
//	S4AppUtils :: sendCCMailWithAddressStr
//============================================================================
- (void)sendCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr body: (NSString *)bodyStr
{
	NSString				*tmpBodyStr = nil;
	NSString				*cleanBodyStr = nil;
	NSString				*urlStr = nil;
	
	if ((nil != addressStr) && (nil != subjectStr) && (nil != bodyStr))
	{
		tmpBodyStr = [bodyStr stringByReplacingOccurrencesOfString: @"\n" withString: @"\r\n"];
		cleanBodyStr = [tmpBodyStr stringByReplacingOccurrencesOfString: @"\r\r\n" withString: @"\r\n"];

//		cleanBodyStr = [tmpBodyStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		
		if (nil != ccStr)
		{
			urlStr = [NSString stringWithFormat: kCCMailToFormatStr, addressStr, ccStr, subjectStr, cleanBodyStr];
		}
		else
		{
			urlStr = [NSString stringWithFormat: kMailToFormatStr, addressStr, subjectStr, cleanBodyStr];
		}
		[self openApplicationWithUrlStr: urlStr];
	}
}


//============================================================================
//	S4AppUtils :: sendHtmlCCMailWithAddressStr
//============================================================================
- (void)sendHtmlCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr htmlBody: (NSString *)htmlBodyStr
{
	CFStringRef					rawHtmlRef;
	NSString					*escapedBody;
	NSString					*escapedSubject;
	NSString					*tmpBodyStr = nil;
	NSString					*cleanBodyStr = nil;
	NSString					*urlStr = nil;
	NSURL						*url;

	if ((nil != addressStr) && (nil != subjectStr) && (nil != htmlBodyStr))
	{
		// encode the HTML body
		rawHtmlRef= (CFStringRef)htmlBodyStr;
		escapedBody = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  rawHtmlRef, NULL,  CFSTR("?=&+"), kCFStringEncodingUTF8) autorelease];
		tmpBodyStr = [escapedBody stringByReplacingOccurrencesOfString: @"\n" withString: @"\r\n"];
		cleanBodyStr = [tmpBodyStr stringByReplacingOccurrencesOfString: @"\r\r\n" withString: @"\r\n"];

		// now encode the subject line
		escapedSubject = [subjectStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

		// finally compose the URL string
		if (nil != ccStr)
		{
			urlStr = [NSString stringWithFormat: kCCMailToFormatStr, addressStr, ccStr, escapedSubject, cleanBodyStr];
		}
		else
		{
			urlStr = [NSString stringWithFormat: kMailToFormatStr, addressStr, escapedSubject, cleanBodyStr];
		}

		// then create the NSURL
		url = [NSURL URLWithString: urlStr];
		if (nil != url)
		{
			[[UIApplication sharedApplication] openURL: url];
		}		
	}
}


//============================================================================
//	S4AppUtils :: sendComposerMailForController
//	Displays an email composition interface inside the application. Populates all the Mail fields
//============================================================================
- (BOOL)sendComposerMailForController: (UIViewController *)viewController
						  toAddresses: (NSArray *)toRecipients
						  ccAddresses: (NSArray *)ccRecipients
						 bccAddresses: (NSArray *)bccRecipients
						  mailBodyStr: (NSString *)emailBody
							   isHTML: (BOOL)bIsHTML
					   attachmentData: (NSData *)attachData
				   attachmentMimeType: (NSString *)attachMimeType
				   attachmentFileName: (NSString *)attachFileName
						  mailSubject: (NSString *)subject
{
	BOOL								bResult = NO;

	// validate that we are OS 3+ && MailComposer can send mail && the UIViewController is not nil && it is a MFMailComposeViewControllerDelegate
	if (([self canUseMailComposer]) &&
		(nil != viewController) && 
		([viewController respondsToSelector: @selector(mailComposeController:didFinishWithResult:error:)]))
	{
		// we are on the 3.0 OS and MailComposer is able to send mail
		MFMailComposeViewController			*mailComposer;

		mailComposer = [[MFMailComposeViewController alloc] init];
		if (nil != mailComposer)
		{
			mailComposer.mailComposeDelegate = (<MFMailComposeViewControllerDelegate>)viewController;

			// set the attachment
			if ((nil != attachData) && (nil != attachMimeType) && (nil != attachFileName))
			{
				[mailComposer addAttachmentData: attachData mimeType: attachMimeType fileName: attachFileName];
			}

			// set recipients
			[mailComposer setToRecipients: toRecipients];
			[mailComposer setCcRecipients: ccRecipients];	
			[mailComposer setBccRecipients: bccRecipients];

			// set the email body text
			[mailComposer setMessageBody: emailBody isHTML: bIsHTML];

			// set subject
			[mailComposer setSubject: subject];

			// present the modal mail composer sheet
			[viewController presentModalViewController: mailComposer animated: YES];
			[mailComposer release];
			bResult = YES;
		}
	}
	return (bResult);
}


///////////////////////////////////// MAPS METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: openMapsWithAddressStr
//============================================================================
- (void)openMapsWithAddressStr: (NSString *)addressStr city: (NSString *)cityStr state: (NSString *)stateStr zip: (NSString *)zipStr
{
	NSString				*encodedMapStr = nil;
	NSString				*urlStr = nil;

	encodedMapStr = [self buildMapUrlStr: addressStr city: cityStr state: stateStr zip: zipStr];
	if (nil != encodedMapStr)
	{
		urlStr = [NSString stringWithFormat: kiPhoneMapsFormatStr, encodedMapStr];
		[self openApplicationWithUrlStr: urlStr];
	}
}


//============================================================================
//	S4AppUtils :: openMapsWithLatitude
//============================================================================
- (void)openMapsWithLatitude: (double)dLatitude longitude: (double)dLongitude
{
	NSString				*urlStr = nil;

	urlStr = [NSString stringWithFormat: kMapsLatLonFormatStr, dLatitude, dLongitude];
	[self openApplicationWithUrlStr: urlStr];
}


//============================================================================
//	S4AppUtils :: openMapsAtStartingAddress
//============================================================================
- (void)openMapsAtStartingAddress: (NSString *)srcAddressStr
						  srcCity: (NSString *)srcCityStr
						 srcState: (NSString *)srcStateStr
						   srcZip: (NSString *)srcZipStr
					   dstAddress: (NSString *)dstAddressStr
						  dstCity: (NSString *)dstCityStr
						 dstState: (NSString *)dstStateStr
						   dstZip: (NSString *)dstZipStr
{
	NSString				*srcMapStr = nil;
	NSString				*dstMapStr = nil;
	NSString				*urlStr = nil;

	srcMapStr = [self buildMapUrlStr: srcAddressStr city: srcCityStr state: srcStateStr zip: srcZipStr];
	if (nil != srcMapStr)
	{
		dstMapStr = [self buildMapUrlStr: dstAddressStr city: dstCityStr state: dstStateStr zip: dstZipStr];
		if (nil != dstMapStr)
		{
			urlStr = [NSString stringWithFormat: kMapsDirectionFormatStr, dstMapStr, srcMapStr];
			[self openApplicationWithUrlStr: urlStr];
		}
	}
}


///////////////////////////////////// PHONE METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: placeCallWithPhoneNumStr
//============================================================================
- (void)placeCallWithPhoneNumStr: (NSString *)phoneNumberStr
{
	NSString				*cleanPhoneNumStr;
	NSString				*urlStr;

	if ([[[UIDevice currentDevice] model] isEqual: @"iPhone"])
	{
		cleanPhoneNumStr = [self cleanUpUSPhoneNumberStr: phoneNumberStr];
		if ((nil != cleanPhoneNumStr) && ([cleanPhoneNumStr length] >= MIN_PHONE_NUM_LEN))
		{
			urlStr = [NSString stringWithFormat: kTelphoneFormatStr, cleanPhoneNumStr];

			[self openApplicationWithUrlStr: urlStr];
		}
	}
}


///////////////////////////////////// TEXT METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: sendSmsTextMsgWithPhoneNumStr
//============================================================================
- (void)sendSmsTextMsgWithPhoneNumStr: (NSString *)phoneNumberStr
{
	NSString				*cleanPhoneNumStr;
	NSString				*urlStr;
	
	if ([[[UIDevice currentDevice] model] isEqual: @"iPhone"])
	{
		cleanPhoneNumStr = [self cleanUpUSPhoneNumberStr: phoneNumberStr];
		if ((nil != cleanPhoneNumStr) && ([cleanPhoneNumStr length] >= MIN_PHONE_NUM_LEN))
		{
			urlStr = [NSString stringWithFormat: kSMSFormatStr, cleanPhoneNumStr];

			[self openApplicationWithUrlStr: urlStr];
		}
	}	
}


///////////////////////////////////// LOCALE METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: isLocaleMetric
//============================================================================
- (BOOL)isLocaleMetric
{
	BOOL					isMetric;
	BOOL					isUK;

	isMetric = [[[NSLocale currentLocale] objectForKey: NSLocaleUsesMetricSystem] boolValue];
	isUK = [kGreatBritainLocale isEqual: [self isoCountry]];
	return isMetric && !isUK;
}


//============================================================================
//	S4AppUtils :: isoCountry
//============================================================================
- (NSString *)isoCountry
{
	return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}


//============================================================================
//	S4AppUtils :: isoLanguage
//============================================================================
- (NSString *)isoLanguage
{
	return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}


//============================================================================
//	S4AppUtils :: displayCountry
//============================================================================
- (NSString *)displayCountry
{
	NSString			*isoCountry = [self isoCountry];
	return [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:isoCountry];
}


//============================================================================
//	S4AppUtils :: displayLanguage
//============================================================================
- (NSString *)displayLanguage: (NSString *)isoLanguage
{
	return [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:isoLanguage];
}


//============================================================================
//	S4AppUtils :: displayLanguage
//============================================================================
- (NSString *)displayLanguage
{
	NSString			*isoLanguage = [self isoLanguage];
	return [self displayLanguage:isoLanguage];
}


//============================================================================
//	S4AppUtils :: englishLocale
//============================================================================
- (NSLocale *)englishLocale
{
	return [[[NSLocale alloc] initWithLocaleIdentifier: @"en"] autorelease];
}


//============================================================================
//	S4AppUtils :: englishCountry
//============================================================================
- (NSString *)englishCountry
{
	NSString			*isoCountry = [self isoCountry];
	return [[self englishLocale] displayNameForKey:NSLocaleCountryCode value:isoCountry];
}


//============================================================================
//	S4AppUtils :: englishLanguage
//============================================================================
- (NSString *)englishLanguage
{
	NSString			*isoLanguage = [self isoLanguage];
	return [[self englishLocale] displayNameForKey:NSLocaleLanguageCode value:isoLanguage];
}


///////////////////////////////////// DEVICE METHODS /////////////////////////////////////

//============================================================================
//	S4AppUtils :: deviceType
//============================================================================
- (UIDeviceType)deviceType
{
	NSString					*curRawName;

	if (UIDeviceUnknown == m_DeviceType)
	{
		curRawName = [self rawDeviceName];
		if (nil != curRawName)
		{
			if ([curRawName isEqualToString: @"iPhone1,1"])
			{
				m_DeviceType = UIDevice1GiPhone;
			}
			else if ([curRawName isEqualToString: @"iPhone1,2"])
			{
				m_DeviceType = UIDevice3GiPhone;
			}
			else if ([curRawName isEqualToString: @"iPod1,1"])
			{
				m_DeviceType = UIDevice1GiPod;
			}
			else if ([curRawName isEqualToString: @"iPod2,1"])
			{
				m_DeviceType = UIDevice2GiPod;
			}
			else if ([curRawName hasPrefix: @"iPhone"])
			{
				m_DeviceType = UIDeviceUnknowniPhone;
			}
			else if ([curRawName hasPrefix: @"iPod"])
			{
				m_DeviceType = UIDeviceUnknowniPod;
			}
		}
	}
	return (m_DeviceType);
}


//============================================================================
//	S4AppUtils :: deviceCapabilities
//============================================================================
- (UIDeviceCapabilities)deviceCapabilities
{
	UIDeviceType						curDeviceType;
	UIDeviceCapabilities				capResult = UIDeviceNoCapabilities;

	curDeviceType = [self deviceType];
	if (UIDevice1GiPhone == curDeviceType)
	{
		capResult = (UIDeviceBuiltInSpeaker |
					 UIDeviceBuiltInCamera |
					 UIDeviceBuiltInMicrophone |
					 UIDeviceSupportsExternalMicrophone |
					 UIDeviceSupportsTelephony |
					 UIDeviceSupportsVibration);
	}
	else if (UIDevice3GiPhone == curDeviceType)
	{
		capResult = (UIDeviceSupportsGPS |
					 UIDeviceBuiltInSpeaker |
					 UIDeviceBuiltInCamera |
					 UIDeviceBuiltInMicrophone |
					 UIDeviceSupportsExternalMicrophone |
					 UIDeviceSupportsTelephony |
					 UIDeviceSupportsVibration);
	}
	else if (UIDeviceUnknowniPhone == curDeviceType)
	{
		capResult = (UIDeviceBuiltInSpeaker |
					 UIDeviceBuiltInCamera |
					 UIDeviceBuiltInMicrophone |
					 UIDeviceSupportsExternalMicrophone |
					 UIDeviceSupportsTelephony |
					 UIDeviceSupportsVibration);
	}
	else if (UIDevice2GiPod == curDeviceType)
	{
		capResult = (UIDeviceBuiltInSpeaker |
					 UIDeviceBuiltInMicrophone |
					 UIDeviceSupportsExternalMicrophone);
	}
	return (capResult);
}


//============================================================================
//	S4AppUtils :: deviceName
//============================================================================
- (NSString *)deviceName
{
	UIDeviceType					curDeviceType;
	NSString						*nameResult = nil;

	curDeviceType = [self deviceType];
	if (UIDevice1GiPhone == curDeviceType)
	{
		nameResult = kIPHONE_1G_NAME;
	}
	else if (UIDevice3GiPhone == curDeviceType)
	{
		nameResult = kIPHONE_3G_NAME;
	}
	else if (UIDeviceUnknowniPhone == curDeviceType)
	{
		nameResult = kIPHONE_UNKNOWN_NAME;
	}
	else if (UIDevice1GiPod == curDeviceType)
	{
		nameResult = kIPOD_1G_NAME;
	}
	else if (UIDevice2GiPod == curDeviceType)
	{
		nameResult = kIPOD_2G_NAME;
	}
	else if (UIDeviceUnknowniPod == curDeviceType)
	{
		nameResult = kIPOD_UNKNOWN_NAME;
	}
	return (nameResult);
}

@end
