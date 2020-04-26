//
//  MethodForward.m
//  RunTimeDemo
//
//  Created by uweiyuan on 2020/4/26.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "MethodForward.h"

static void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

#define onExit \
__strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^

__attribute__((objc_runtime_name("fuckU")))
@interface Student:NSObject
@property int age;
@end
@implementation Student

+(void)load {
    NSLog(@"%s", __func__);
    onExit {
        NSLog(@"bye!");
    };
}

- (void)test:(NSString *)x {
    NSLog(@"student %@", x);
}

+ (void)userDefinedLoad {
    NSLog(@"load");
}


@end


@implementation MethodForward

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector(aSelector));
    exit(9);
}
# if 1
static int xxxxx = 0;
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    Student *s1 = [Student new];
    s1.age = 10;
    Student *s2 = [Student new];
    s2.age = 20;
    
    NSArray *stus = @[s1, s2];
    
    NSLog(@"average age = %@", [stus valueForKeyPath:@"@avg.age"]);
    NSLog(@"summery age = %@", [stus valueForKeyPath:@"@sum.age"]);
    NSLog(@"max age = %@", [stus valueForKeyPath:@"@max.age"]);
    NSLog(@"min age = %@", [stus valueForKeyPath:@"@min.age"]);
    NSLog(@"count age = %@", [stus valueForKeyPath:@"@count.age"]);
    
    
    NSLog(@"%@", [^{} class]);
    
    NSLog(@"%@", [^{
        NSLog(@"%ld", (long)xxxxx);
    } class]);
    
    NSInteger num = 10;
    NSLog(@"%@", [^{
        NSLog(@"%ld", (long)num);
    } class]);
    NSLog(@"%@", [[^{
        NSLog(@"%ld", (long)num);
    } copy] class]);
    
    NSLog(@"%@", [[^{
        NSLog(@"%@", self);
    } copy] class]);
    void (^mallocBlock)(void) = ^{
        NSLog(@"stackBlock:%zd",num);
    };
    
    NSLog(@"%@",[mallocBlock class]);
    NSLog(@"%@",[[mallocBlock copy] class]);
    
    void (^mallocBlockg)(void) = ^{};
    NSLog(@"%@",[mallocBlockg class]);
    
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector(sel));
    return sel == @selector(test);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector(aSelector));
    if (aSelector == @selector(test)) {
        return self;
    } else {
        return [Student new];
    }
}

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"%s", __FUNCTION__);
    SEL aSelector = [anInvocation selector];
    id friend = [Student new];
    if ([friend respondsToSelector:aSelector])
        [anInvocation invokeWithTarget:friend];
    else
        [super forwardInvocation:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector(aSelector));
    NSMethodSignature *ms = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    return ms;
}
#endif
- (void)test {
    
    NSLog(@"test Method Demo");
}

@end
