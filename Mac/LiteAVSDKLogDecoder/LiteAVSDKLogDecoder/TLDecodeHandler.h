//
//  TLDecodeHandler.h
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TLDecodeHandler;
@protocol TLDecodeHandlerDelegate <NSObject>

-(void)decodeSuccessWithhandler:(TLDecodeHandler *)handler decodedFilePath:(NSString *)filePath;
-(void)decodeFailedWithhandler:(TLDecodeHandler *)handler failedFilePath:(NSString *)filePath reason:(NSString *)reason;


@end
@interface TLDecodeHandler : NSObject
@property (weak)id<TLDecodeHandlerDelegate> delegate;
-(BOOL)isSurportToDecodeFile:(NSString *)filePath;
-(void)decodeWithFilePath:(NSString *)filePath isOpenWithConsole:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
