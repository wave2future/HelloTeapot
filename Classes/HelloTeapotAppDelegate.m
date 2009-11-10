//
//  HelloTeapotAppDelegate.m
//  HelloTeapot
//
//  Created by turner on 11/10/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import "HelloTeapotAppDelegate.h"
#import "GLViewController.h"

@implementation HelloTeapotAppDelegate

@synthesize controller = _controller;
@synthesize window = _window;

- (void)dealloc {
	
	[_controller	release], _controller	= nil;
	[_window		release], _window		= nil;
	
    [super			dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    [self.window addSubview:self.controller.view];
    [self.window makeKeyAndVisible];
}

@end
