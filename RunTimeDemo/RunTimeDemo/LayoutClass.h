//
//  LayoutClass.h
//  RunTimeDemo
//
//  Created by uweiyuan on 2021/10/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LayoutClass:NSObject{
}

@property (nonatomic, strong)  id  prop1_s;
// 内存中的layout 将会优先排列基本数据类型
@property (nonatomic, assign)  int  prop0_int;
@property (nonatomic, assign)  int  prop1_int;
@property (nonatomic, assign)  int  prop2_int;

@property (nonatomic, strong)  id  prop2_s;
@property (nonatomic, weak)  id  prop3_w;
@property (nonatomic, strong)  id  prop4_s;

@end

NS_ASSUME_NONNULL_END
