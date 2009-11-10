//
//  HelloTeapotAppDelegate.h
//  HelloTeapot
//
//  Created by turner on 11/10/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLViewController;
@interface HelloTeapotAppDelegate : NSObject <UIApplicationDelegate> {
	GLViewController	*_controller;
    UIWindow			*_window;
}

@property (nonatomic, retain) IBOutlet GLViewController	*controller;
@property (nonatomic, retain) IBOutlet UIWindow			*window;

@end

