//
//  MyClass.m
//  RunTimeDemo
//
//  Created by uweiyuan on 2021/10/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "MyClass.h"

@implementation MyClass

- (void)myClassInstanceMethodWithOutParamater {
    NSLog(@"myClassInstanceMethodWithOutParamater");
}

- (void)myClassInstanceMethodWithParamater:(id)paramater {
    NSLog(@"myClassInstanceMethodWithParamater is %@", paramater);
}

- (void)myClassInstanceMethodWithParamater:(NSArray *)p1 p2:(int)p2 {
    
}

+ (void)myClassClassMethodWithOutParamater {
    NSLog(@"myClassClassMethodWithOutParamater");
}

- (void)canBeReplacedMethod {
    NSLog(@"canBeReplacedMethod");
}

- (NSInteger)myClassInstanceMethodWithParameterAndReturnValue:(NSInteger)paramater {
    return paramater + 100;
}

- (void)canBeReplacedByIMP {
    NSLog(@"%s", __FUNCTION__);
}

// c method
- (void)myClassReplacedMethod {
    NSLog(@"myClassReplacedMethod");
}

+ (void)myClassClassMethodWithParamater1:(NSString *)p1 paramater2:(NSArray<NSNumber *> *)p2 {
}

+ (int)getVersion {
    return 2;
}

- (NSString *)description {
    NSLog(@"this this my class");
    return @"this is my class";
}

@end
