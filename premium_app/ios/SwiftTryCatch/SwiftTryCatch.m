//
//  SwiftTryCatch.m
//
//  Created by William Falcon on 2/22/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException* exception))catchBlock finallyBlock:(void(^)(void))finallyBlock {
    @try {
        if (tryBlock) {
            tryBlock();
        }
    }
    @catch (NSException *exception) {
        if (catchBlock) {
            catchBlock(exception);
        }
    }
    @finally {
        if (finallyBlock) {
            finallyBlock();
        }
    }
}

@end
