//
//  AppDelegate.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/13.
//

#import "AppDelegate.h"
#import "TLDecodeHandler.h"
@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
    for (NSURL *fileUrl in urls) {
        NSString *filePath = [fileUrl path];
        TLDecodeHandler *decodehandler = [TLDecodeHandler new];
        [decodehandler decodeWithFilePath:filePath];
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
