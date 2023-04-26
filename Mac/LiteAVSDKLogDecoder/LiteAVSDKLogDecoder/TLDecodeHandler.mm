//
//  TLDecodeHandler.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/26.
//

#import "TLDecodeHandler.h"
#import "trtc_decode_log.h"
#import <string>
using namespace std;
class MyDecodeCallBack:public TRTCDecodeCallback{
    void decodeComplete(TRTCDecodeLog *decoder) override{
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
-(void)decodeWithFilePath:(NSString *)filePath{
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
        const char *fileCstr = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        const char * outfileCstr = [outDir cStringUsingEncoding:NSASCIIStringEncoding];
        string filePathCppString(fileCstr,fileCstr+strlen(fileCstr));
        decoder->parseFile(filePathCppString);
        delete  decoder;
    }
}
@end
