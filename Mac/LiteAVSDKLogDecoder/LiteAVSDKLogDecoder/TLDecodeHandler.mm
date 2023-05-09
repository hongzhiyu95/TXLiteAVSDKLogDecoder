//
//  TLDecodeHandler.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/26.
//

#import "TLDecodeHandler.h"
#import "trtc_decode_log.h"
#import <AppKit/AppKit.h>
#import <string>
using namespace std;
class MyDecodeCallBack:public TRTCDecodeCallback{
    void decodeComplete(TRTCDecodeLog *decoder ,string filePath) override{
    }
};
@implementation TLDecodeHandler
-(BOOL)isSurportToDecodeFile:(NSString *)filePath{
    NSString *fileName = [[filePath componentsSeparatedByString:@"/"]lastObject];
    if([fileName hasSuffix:@".clog"]||[fileName hasSuffix:@".xlog"]){
        return YES;
    }else{
        return NO;
    }
}
-(void)openConsoleWithLogPath:(NSString *)filePath{
//     NSTask *task = [NSTask new];
//      [task setLaunchPath:@"/usr/bin/open"];
//      NSArray * args = [[NSArray alloc] initWithObjects:@"/System/Applications/Utilities/Console.app",filePath, nil];
//      [task setArguments:args];
//      [task launch];
//      [task waitUntilExit];
    [[NSWorkspace sharedWorkspace]openFile:filePath];
    
}
-(void)decodeWithFilePath:(NSString *)filePath isOpenWithConsole:(BOOL)enable{
    if([self isSurportToDecodeFile:filePath]){
     
        NSString *outDir = [filePath stringByAppendingString:@".log"];
        NSString*fileName =  [[filePath componentsSeparatedByString:@"/"] lastObject];
        if([fileName hasPrefix:@"LiteAV_R"]){
            [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:outDir error:nil];
            NSLog(@"不需要解压");
            return;
         
        }
        TRTCDecodeLog *decoder = new TRTCDecodeLog();
        MyDecodeCallBack *callbk = new MyDecodeCallBack();
        decoder->setDecodeCallBack(callbk);
        const char * fileCstr = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
      
       
        string filePathCppString(fileCstr,fileCstr+strlen(fileCstr));
        decoder->parseFile(filePathCppString);
        if(enable){
            [self openConsoleWithLogPath:outDir];
        }
        delete  decoder;
    }
}
@end
