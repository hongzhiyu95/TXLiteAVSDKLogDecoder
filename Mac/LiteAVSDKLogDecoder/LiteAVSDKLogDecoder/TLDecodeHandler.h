//
//  TLDecodeHandler.h
//  LiteAVSDKLogDecoder
//
//  Created by einhorn on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TLDecodeHandler : NSObject

-(BOOL)isSurportToDecodeFile:(NSString *)filePath;
-(void)decodeWithFilePath:(NSString *)filePath;
@end

NS_ASSUME_NONNULL_END
