//
//  MyClass.h
//  RunTimeDemo
//
//  Created by uweiyuan on 2021/10/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MyProtocol <NSObject>

@optional
- (void)myProctolMethod;

@end


@interface MyClass: NSObject<MyProtocol> {
    // 整形， 4
    // 8,长整形，浮点型，引用类型
    int instanceVar;
}

@property (assign, atomic)  CGFloat  age;
@property (nonatomic, copy) NSString *name;


- (void)myClassInstanceMethodWithOutParamater;
- (void)myClassInstanceMethodWithParamater:(id)paramater;
- (void)myClassInstanceMethodWithParamater:(NSArray *)p1 p2:(int)p2;
+ (void)myClassClassMethodWithOutParamater;
+ (void)myClassClassMethodWithParamater1:(NSString *)p1 paramater2:(NSArray <NSNumber *> *)p2;

- (void)canBeReplacedMethod;

- (NSInteger)myClassInstanceMethodWithParameterAndReturnValue:(NSInteger)paramater;
- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
