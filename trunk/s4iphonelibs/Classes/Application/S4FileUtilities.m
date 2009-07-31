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
 * Name:		S4FileUtilities.m
 * Module:		Application
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4FileUtilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

static NSString							*kTemporaryDirctory = nil;
static NSString							*kDocumentsDirectory = nil;
static NSString							*kCachesDirctory = nil;
static NSString							*kApplSupportDirectory = nil;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ===================== Begin Class S4FileUtilities (PrivateImpl) =====================

@interface S4FileUtilities (PrivateImpl)

+ (NSString *)randomString;
+ (void)placeHolder2;

@end




@implementation S4FileUtilities (PrivateImpl)

//============================================================================
//	S4FileUtilities (PrivateImpl) :: placeHolder1
//============================================================================
+ (NSString *)randomString
{
	NSMutableString* string = [NSMutableString string];
	for (int i = 0; i < 8; i++)
	{
		[string appendFormat:@"%c", ((rand() % 26) + 'a')];
	}
	return (string);
}


//============================================================================
//	S4FileUtilities (PrivateImpl) :: placeHolder2
//============================================================================
+ (void)placeHolder2
{
}

@end




// ======================= Begin Class S4FileUtilities =======================

@implementation S4FileUtilities

//============================================================================
//	S4FileUtilities : tempDirectory
//============================================================================
+ (NSString *)tempDirectory
{
	if (nil == kTemporaryDirctory)
	{
		kTemporaryDirctory = [NSTemporaryDirectory() retain];
	}
	return (kTemporaryDirctory);
}


//============================================================================
//	S4FileUtilities : documentsDirectory
//============================================================================
+ (NSString *)documentsDirectory
{
	NSArray							*pathsArray;

	if (nil == kDocumentsDirectory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kDocumentsDirectory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kDocumentsDirectory);
}


//============================================================================
//	S4FileUtilities : cachesDirectory
//============================================================================
+ (NSString *)cachesDirectory
{
	NSArray							*pathsArray;

	if (nil == kCachesDirctory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kCachesDirctory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kCachesDirctory);
}


//============================================================================
//	S4FileUtilities : applSupportDirectory
//============================================================================
+ (NSString *)applSupportDirectory
{
	NSArray							*pathsArray;

	if (nil == kApplSupportDirectory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kApplSupportDirectory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kApplSupportDirectory);
}


//============================================================================
//	S4FileUtilities : writePersistentKeyedArchiverObject
//============================================================================
+ (BOOL)writePersistentKeyedArchiverObject: (id <NSCoding>)object atPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if ((nil != object) && (nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [NSKeyedArchiver archiveRootObject: object toFile: archivePath];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : readPersistentKeyedArchiverObjectAtPath
//============================================================================
+ (id <NSCoding>)readPersistentKeyedArchiverObjectAtPath: (NSString *)path
{
	NSString					*archivePath;
	id <NSCoding>				idResult = nil;

	if ((nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		idResult = [NSKeyedUnarchiver unarchiveObjectWithFile: archivePath];
	}
	return (idResult);
}


//============================================================================
//	S4FileUtilities : persistentFileExistsAtPath
//============================================================================
+ (BOOL)persistentFileExistsAtPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if ((nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [[NSFileManager defaultManager] fileExistsAtPath: archivePath];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : removePersistentFileAtPath
//============================================================================
+ (BOOL)removePersistentFileAtPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if ((nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [[NSFileManager defaultManager] removeItemAtPath: archivePath error: NULL];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : uniqueDirectory:create:
//============================================================================
+ (NSString *)uniqueDirectory: (NSString *)parentDirectory create: (BOOL)create
{
	NSString* finalDir = nil;

	do
	{
		NSString* random = [self randomString];
		finalDir = [parentDirectory stringByAppendingPathComponent: random];
	}
	while ([[NSFileManager defaultManager] fileExistsAtPath: finalDir]);

	if (create)
	{
		[S4FileUtilities createDirectory: finalDir];
	}
	return (finalDir);
}


//============================================================================
//	S4FileUtilities : uniqueTemporaryDirectory
//============================================================================
+ (NSString *)uniqueTemporaryDirectory
{
	return [self uniqueDirectory: [self tempDirectory] create: YES];
}


//============================================================================
//	S4FileUtilities : createDirectory
//============================================================================
+ (void)createDirectory: (NSString *)directory
{
	if (![[NSFileManager defaultManager] fileExistsAtPath: directory])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath: directory withIntermediateDirectories: YES attributes: nil error: NULL];
	}
}


//============================================================================
//	S4FileUtilities : modificationDate
//============================================================================
+ (NSDate *)modificationDate: (NSString *)file
{
	NSDate				*result = nil;

	result = [[[NSFileManager defaultManager] attributesOfItemAtPath: file error: NULL] objectForKey: NSFileModificationDate];
	return (result);
}


//============================================================================
//	S4FileUtilities : size
//============================================================================
+ (unsigned long long)size: (NSString *)file
{
	NSNumber					*number;

	number = [[[NSFileManager defaultManager] attributesOfItemAtPath: file error: NULL] objectForKey: NSFileSize];
	return ([number unsignedLongLongValue]);
}


//============================================================================
//	S4FileUtilities : attributesOfItemAtPath
//============================================================================
+ (NSDictionary *)attributesOfItemAtPath: (NSString *)path
{
	return ([[NSFileManager defaultManager] attributesOfItemAtPath: path error: NULL]);
}


//============================================================================
//	S4FileUtilities : directoryContentsNames
//============================================================================
+ (NSArray *)directoryContentsNames: (NSString *)directory
{
	return ([[NSFileManager defaultManager] directoryContentsAtPath: directory]);
}


//============================================================================
//	S4FileUtilities : directoryContentsPaths
//============================================================================
+ (NSArray *)directoryContentsPaths: (NSString *)directory
{
	NSArray						*names;
	NSMutableArray				*result;

	result = [NSMutableArray array];
	names = [[NSFileManager defaultManager] directoryContentsAtPath: directory];
	for (NSString *name in names)
	{
		[result addObject: [directory stringByAppendingPathComponent: name]];
	}
	return (result);
}


//============================================================================
//	S4FileUtilities : fileExists
//============================================================================
+ (BOOL)fileExists: (NSString *)path
{
	return ([[NSFileManager defaultManager] fileExistsAtPath: path]);
}


//============================================================================
//	S4FileUtilities : moveDiskItemFromPath:toPath:
//============================================================================
+ (BOOL)moveDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath
{
	return ([[NSFileManager defaultManager] moveItemAtPath: srcPath toPath: dstPath error: NULL]);
}


//============================================================================
//	S4FileUtilities : cleanupFileName
//============================================================================
+ (NSString *)cleanupFileName: (NSString *)name
{
    return [[name stringByReplacingOccurrencesOfString: @"/" withString: @"_"] stringByReplacingOccurrencesOfString: @":" withString: @"_"];
}


//============================================================================
//	S4FileUtilities : deleteDiskItemAtPath
//============================================================================
+ (void)deleteDiskItemAtPath: (NSString *)itemPath
{
	[[NSFileManager defaultManager] removeItemAtPath: itemPath error: NULL];
}


//============================================================================
//	S4FileUtilities : writeData:toFileAtPath:
//============================================================================
+ (void)writeData: (NSData *)data toFileAtPath: (NSString *)file
{
	[data writeToFile: file atomically: YES];
}


//============================================================================
//	S4FileUtilities : readDataFromFileAtPath
//============================================================================
+ (NSData *)readDataFromFileAtPath: (NSString *)file
{
	NSData			*dataResult = nil;

    if (IS_NOT_NULL(file))
	{
        dataResult = [NSData dataWithContentsOfFile: file];
    }
    return (dataResult);
}


//============================================================================
//	S4FileUtilities : isDirectoryAtPath
//============================================================================
+ (BOOL)isDirectoryAtPath: (NSString *)path
{
	BOOL						result;

	[[NSFileManager defaultManager] fileExistsAtPath: path isDirectory: &result];
	return (result);
}



+ (void)writeObject: (id)object toPropListFile: (NSString *)file
{
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:object
																   format:NSPropertyListBinaryFormat_v1_0
														 errorDescription:NULL];
	
	if (plistData != nil) {
		[plistData writeToFile:file atomically:YES];
	} if (object == nil) {
		[[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
	}
}



+ (id)readObjectFromPropListFile: (NSString *)file
{
    if (file == nil) {
        return nil;
    }
	
    id result = nil;
    {
        NSData* data = [NSData dataWithContentsOfFile:file];
        if (data != nil) {
            result = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:NULL];
        }
    }
    return result;
}


//============================================================================
//	S4FileUtilities : readPlistFromBundleFile
//============================================================================
+ (NSDictionary *)readPlistFromBundleFile: (NSString *)fileName
{
	NSPropertyListFormat			format;
	NSString						*errorDesc = nil;
	NSString						*plistPath;
	NSData							*plistXML;
	NSDictionary					*dictResult = nil;

	if (IS_NOT_NULL(fileName))
	{
		plistPath = [[NSBundle mainBundle] pathForResource: fileName ofType: @"plist"];
		plistXML = [[NSFileManager defaultManager] contentsAtPath: plistPath];
		dictResult = (NSDictionary *)[NSPropertyListSerialization propertyListFromData: plistXML
																	  mutabilityOption: NSPropertyListMutableContainersAndLeaves
																				format: &format
																	  errorDescription: &errorDesc];

		if (nil != errorDesc)
		{
			NSLog(errorDesc);
			[errorDesc release];
		}
	}
	return (dictResult);
}	


//============================================================================
//	S4FileUtilities : readPlistFromCFURL
//============================================================================
+ (CFPropertyListRef)readPlistFromCFURL: (CFURLRef)fileURL
{
	CFStringRef						errorString;
	CFDataRef						resourceData;
	Boolean							status;
	SInt32							errorCode;
	CFPropertyListRef				propertyList = NULL;

	// Read the XML file.
	status = CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,
													  fileURL,
													  &resourceData,            // place to put file data
													  NULL,
													  NULL,
													  &errorCode);

	// Reconstitute the dictionary using the XML data.
	propertyList = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, resourceData, kCFPropertyListImmutable, &errorString);

	if (resourceData)
	{
		CFRelease(resourceData);
	}
	else
	{
		CFRelease(errorString);
	}
	return (propertyList);
}


//============================================================================
//	S4FileUtilities : writePlist:toCFURL: 
//============================================================================
+ (BOOL)writePlist: (CFPropertyListRef)propertyList toCFURL: (CFURLRef)fileURL
{
	CFDataRef					xmlData;
	Boolean						status;
	SInt32						errorCode;
	BOOL						bResult = NO;

	// Convert the property list into XML data.
	xmlData = CFPropertyListCreateXMLData(kCFAllocatorDefault, propertyList);

	// Write the XML data to the file.
	status = CFURLWriteDataAndPropertiesToResource(fileURL, xmlData, NULL, &errorCode);
	CFRelease(xmlData);
	return (bResult);
}

@end
