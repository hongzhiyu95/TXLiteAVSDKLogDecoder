//
//  ViewController.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/13.
//

#import "ViewController.h"
#import "TLDragView.h"

#import "TLDecodeHandler.h"


@interface ViewController ()<TLDragDelegate>

@end

@implementation ViewController{
    
    __weak IBOutlet TLDragView *_dragView;
   // TRTCDecodeLog* _decoder;

    //NSString *_decodefileDir;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    _dragView.dragDelegate = self;
    
   
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
        TLDecodeHandler *decodeHandler  = [TLDecodeHandler new];
        [decodeHandler decodeWithFilePath:filePath];
        
       
    }
}

@end
 


