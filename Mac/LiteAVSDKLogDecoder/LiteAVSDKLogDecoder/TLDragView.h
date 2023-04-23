//
//  TLDragView.h
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/13.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TLDragDelegate <NSObject>

-(void)dragEnteredFiles:(NSArray<NSString *>*)files;
-(void)dragEndedFiles:(NSArray<NSString *>*)files;

@end

@interface TLDragView : NSView
@property (weak ,nonatomic)id<TLDragDelegate>dragDelegate;
@end

NS_ASSUME_NONNULL_END
