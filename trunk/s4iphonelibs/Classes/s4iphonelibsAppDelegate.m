//
//  s4iphonelibsAppDelegate.m
//  s4iphonelibs
//
//  Created by Michael Papp on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "s4iphonelibsAppDelegate.h"
#import "RootViewController.h"


@implementation s4iphonelibsAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
