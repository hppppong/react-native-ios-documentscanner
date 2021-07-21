//
//  DocumentScanner.m
//  AppTest
//
//  Created by User on 14/5/2021.
//
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RNDocumentScanner, NSObject)

RCT_EXTERN_METHOD(startScan: (NSDictionary *)savePath success:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(detectRectangle: (NSString *)path success:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(dismiss)
@end


