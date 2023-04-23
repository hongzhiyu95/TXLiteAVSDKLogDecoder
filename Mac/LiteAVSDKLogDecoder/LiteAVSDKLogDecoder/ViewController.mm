//
//  ViewController.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/13.
//

#import "ViewController.h"
#import "TLDragView.h"
#import "trtc_decode_log.h"
#import <string>
using namespace std;

@interface ViewController ()<TLDragDelegate>

@end
static NSString *_decodefileDir = @"";
@implementation ViewController{
    
    __weak IBOutlet TLDragView *_dragView;
    TRTCDecodeLog* _decoder;
    NSFileManager *_fileManager;
    //NSString *_decodefileDir;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dragView.dragDelegate = self;

    _fileManager = [NSFileManager defaultManager];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
-(void)dragEnteredFiles:(NSArray<NSString *> *)files{
    
}
-(void)dragEndedFiles:(NSArray<NSString *> *)files{
    for (NSString *filePath in files ) {
        _decoder = new TRTCDecodeLog();
        NSString *outDir = [filePath stringByAppendingString:@".log"];
        NSMutableString *mfileStr = [[NSMutableString alloc]initWithString:filePath];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        //用来解压的文件名
       NSString*fileName =  [[filePath componentsSeparatedByString:@"/"] lastObject];
        mfileStr = [mfileStr stringByDeletingLastPathComponent];
        _decodefileDir = mfileStr;
        NSString *outFile = [NSString stringWithFormat:@"%@/%@.log",docDir,fileName];
        const char *fileCstr = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
        const char * outfileCstr = [outFile cStringUsingEncoding:NSASCIIStringEncoding];
        string na(fileCstr,fileCstr+strlen(fileCstr));
        string outf(outfileCstr,outfileCstr+strlen(outfileCstr));
        _decoder->parseFile(na,outf);
        delete  _decoder;
    }
}

@end
 


