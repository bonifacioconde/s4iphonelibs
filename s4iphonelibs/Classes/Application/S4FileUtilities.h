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
 * Name:		S4FileUtilities.h
 * Module:		Application
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4FileUtilities ==================================

@interface S4FileUtilities : NSObject
{

}


// commonly used directories
+ (NSString *)tempDirectory;
+ (NSString *)documentsDirectory;
+ (NSString *)cachesDirectory;
+ (NSString *)applSupportDirectory;

// persistant store for NSCoding objects
+ (BOOL)writePersistentKeyedArchiverObject: (id <NSCoding>)object atPath: (NSString *)path;
+ (id <NSCoding>)readPersistentKeyedArchiverObjectAtPath: (NSString *)path;
+ (BOOL)persistentFileExistsAtPath: (NSString *)path;
+ (BOOL)removePersistentFileAtPath: (NSString *)path;

// directory operations
+ (NSString *)uniqueDirectory: (NSString *)parentDirectory create: (BOOL)create;
+ (NSString *)uniqueTemporaryDirectory;
+ (void)createDirectory: (NSString *)path;
+ (NSArray *)directoryContentsNames: (NSString *)directory;
+ (NSArray *)directoryContentsPaths: (NSString *)directory;
+ (BOOL)isDirectoryAtPath: (NSString *)path;

// file or directory attributes
+ (NSDate *)modificationDate: (NSString *)file;
+ (unsigned long long)size: (NSString *)file;
+ (NSDictionary *)attributesOfItemAtPath: (NSString *)path;

// common file operations
+ (BOOL)fileExists: (NSString *)path;
+ (BOOL)moveDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath;
+ (NSString *)cleanupFileName: (NSString *)name;
+ (void)deleteDiskItemAtPath: (NSString *)itemPath;
+ (void)writeData: (NSData *)data toFileAtPath: (NSString *)file;
+ (NSData *)readDataFromFileAtPath: (NSString *)file;

// PList file operations
+ (void)writeObject: (id)object toPropListFile: (NSString *)file;
+ (id)readObjectFromPropListFile: (NSString *)file;
+ (NSDictionary *)readPlistFromBundleFile: (NSString *)fileName;
+ (CFPropertyListRef)readPlistFromCFURL: (CFURLRef)fileURL;
+ (BOOL)writePlist: (CFPropertyListRef)propertyList toCFURL: (CFURLRef)fileURL;

@end
