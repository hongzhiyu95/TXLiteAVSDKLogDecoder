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
@property (weak) IBOutlet NSButton *openWithConsoleCheck;

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

-(IBAction)openDocument:(NSButton* )sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
      openPanel.prompt = @"选择";
      openPanel.title = @"NSSplitView Demo";
      openPanel.message = @"";
      openPanel.canChooseFiles = YES;
      openPanel.canChooseDirectories = YES;
      [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
          if (result == NSModalResponseOK) {
              NSLog(@"%@", openPanel.URL.path);
              TLDecodeHandler *decodeHandler  = [TLDecodeHandler new];
              [decodeHandler decodeWithFilePath:openPanel.URL.path isOpenWithConsole:YES];
              
          }
          sender.state = NSControlStateValueOff;
      }];
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
        [decodeHandler decodeWithFilePath:filePath isOpenWithConsole:_openWithConsoleCheck.state];
        
       
    }
}

@end
 


