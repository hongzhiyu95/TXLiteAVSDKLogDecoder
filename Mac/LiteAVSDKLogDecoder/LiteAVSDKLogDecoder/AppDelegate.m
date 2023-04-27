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
        [decodehandler decodeWithFilePath:filePath isOpenWithConsole:YES];
    }
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

//-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
//    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//    openPanel.prompt = @"选择";
//    openPanel.title = @"NSSplitView Demo";
//    openPanel.message = @"你是谁的谁";
//    openPanel.canChooseFiles = YES;
//    openPanel.canChooseDirectories = YES;
//    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
//        if (result == NSModalResponseOK) {
//            NSLog(@"%@", openPanel.URL.path);
//        }
////        sender.state = NSControlStateValueOff;
//    }];
//
//    return YES;
//}

@end
