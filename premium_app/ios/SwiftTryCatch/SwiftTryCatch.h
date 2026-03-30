//
//  SwiftTryCatch.h
//
//  Created by William Falcon on 2/22/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwiftTryCatch : NSObject

+ (void)tryBlock:(void(^)(void))tryBlock catchBlock:(void(^)(NSException* exception))catchBlock finallyBlock:(void(^)(void))finallyBlock;

@end
