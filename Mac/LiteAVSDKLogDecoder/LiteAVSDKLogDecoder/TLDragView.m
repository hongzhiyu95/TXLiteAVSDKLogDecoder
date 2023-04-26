//
//  TLDragView.m
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/13.
//

#import "TLDragView.h"

@implementation TLDragView


-(BOOL)isSurportToDecodeFile:(NSString *)filePath{
    NSString *fileName = [[filePath componentsSeparatedByString:@"/"]lastObject];
    if([fileName hasSuffix:@".clog"]||[fileName hasSuffix:@".xlog"]){
        return YES;
    }else{
        return NO;
    }
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.canDrawConcurrently = YES;
    [self registerForDraggedTypes:[NSArray arrayWithObjects:
                NSColorPboardType, NSFilenamesPboardType, nil]];
    // Drawing code here.
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    
    return YES;
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
 
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
 
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        if ([self.dragDelegate respondsToSelector:@selector(dragEnteredFiles:)]){
            for (NSString *filePath in files) {
                if([self isSurportToDecodeFile:filePath]){
                    return NSDragOperationCopy;
                }else{
                    return NSDragOperationNone;
                }
            }
          //  [self.dragDelegate dragEnteredFiles:files];
        }
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        if (sourceDragMask & NSDragOperationLink) {
          //  [self addLinkToFiles:files];
        } else {
          //  [self addDataFromFiles:files];
        }
    }
    
    return NSDragOperationNone;
}
-(void)draggingEnded:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
 
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        if ([self.dragDelegate respondsToSelector:@selector(dragEndedFiles:)]){
            [self.dragDelegate dragEndedFiles:files];
        }
        
    }
    NSLog(@"拖完了");
    
}
@end
