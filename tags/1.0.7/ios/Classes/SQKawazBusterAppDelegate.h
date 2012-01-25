//
//  SQKawazBusterAppDelegate.h
//  SQKawazBuster
//
//  Created by Kota Iguchi on 11/07/09.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmoViewController;

@interface SQKawazBusterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EmoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EmoViewController *viewController;

@end

