//
//  MyRootClass.h
//  RunTimeDemo
//
//  Created by uweiyuan on 2021/10/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// this is a method to custom a root class without inheried from superclass
OBJC_ROOT_CLASS @interface MyRootClass

+ (void)info;

@end

NS_ASSUME_NONNULL_END
