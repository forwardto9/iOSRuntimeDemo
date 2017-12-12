//
//  main.m
//  RunTimeDemo
//
//  Created by uwei on 3/17/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

// OBJC_OLD_DISPATCH_PROTOTYPES


// this is a method to custom a root class without inheried from superclass
OBJC_ROOT_CLASS @interface MyRootClass
+ (void)info;
@end

@implementation MyRootClass
+ (void)info {
    NSLog(@"MY ROOT Class");
}
@end

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

@interface MySubClass:MyClass {
    
}

@end
@implementation MySubClass
@end

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
@implementation LayoutClass
@end

// c method
void myClassReplaceMethod(id self, SEL _cmd) {
    NSLog(@"myClassReplaceMethod");
}

void myMethodIMP(id self, SEL _cmd) {
    NSLog(@"myMethodIMP");
}

void myMethodBeSetIMP(id self, SEL _cmd) {
    NSLog(@"%s", __FUNCTION__);
}

void dynamicAddSEL(id self, SEL _cmd) {
    NSLog(@"this is a dynamic method");
}

void setName(id self, SEL _cmd, NSString *nameString) {
    Class cls = object_getClass(self);
    Ivar ivar = class_getInstanceVariable(cls, "_name");
    object_setIvar(self, ivar, nameString);
}

NSString *name(id self, SEL _cmd) {
    Class cls = object_getClass(self);
    Ivar ivar = class_getInstanceVariable(cls, "_name");
    id name = object_getIvar(self, ivar);
    return name;
}

void mutateFunction(id obj) {
    NSLog(@"%s", __func__);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        [MyRootClass info];
#pragma mark - Operation on an unexisted class
        // create a new class
        Class cls = objc_allocateClassPair([NSObject class], "NewDynamicClass", 0);
        
        // 资源清理
//        objc_disposeClassPair(cls);
        
        // 使用runtime给一个类注册方法的前提是：方法的SEL结构必须存在runtime系统
        // 1.其他地方定义过
        // 2.使用注册方法进行注册
       
        // 注册SEL方法 1
//        SEL aDynamicRegisterSEL = sel_registerName("aDynamicRegisterSEL");
        // 注册SEL方法 2
        SEL aDynamicRegisterSEL = sel_getUid("aDynamicRegisterSEL");
        if (class_respondsToSelector(cls, aDynamicRegisterSEL)) {
            NSLog(@"Class respond to Method");
        } else {
            NSLog(@"Class not respond to Method");
        }
        
#warning Instance methods and instance variables should be added to the class itself.
#warning Class methods should be added to the metaclass.
        
        // add instance method
        // 关于类型编码参照:https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
        BOOL addMethodResult = class_addMethod(cls, aDynamicRegisterSEL, (IMP)(dynamicAddSEL), "v@:");
        if (addMethodResult) {
            NSLog(@"Add a method to Class success!");
        } else {
            NSLog(@"Add a method to Class failed!");
        }
        
        if (class_respondsToSelector(cls, aDynamicRegisterSEL)) {
            NSLog(@"Class respond to Method");
            // 方法1，不推荐
            NSObject *obj = class_createInstance(cls, 0);
            [obj performSelector:aDynamicRegisterSEL];
            
            // 方法2，不推荐
            NSObject *instance = [[cls alloc] init];
            [instance performSelector:aDynamicRegisterSEL];
            
            // 方法3，推荐
            objc_msgSend(obj, aDynamicRegisterSEL);
            
            // 方法4，推荐
            Method m = class_getInstanceMethod(cls, aDynamicRegisterSEL);
            method_invoke(cls, m);
        } else {
            NSLog(@"Class not respond to Method");
        }
        
        // 定义属性
        objc_property_attribute_t type = {"T", "@\"NSString\""};
        objc_property_attribute_t automatic = {"N", ""};
        objc_property_attribute_t ownerShip = {"C", ""};
        objc_property_attribute_t variable  = {"V", "_name"};
        objc_property_attribute_t attributes[] = {type, automatic, ownerShip, variable};
        
        // add property or replace, 如果不存在则add，已经存在则替换
        int size = sizeof(attributes)/sizeof(objc_property_attribute_t);
        BOOL addPropertyResult = class_addProperty(cls, "name", attributes, size);
        if (addPropertyResult) {
            NSLog(@"Add a new property success!");
        } else {
            class_replaceProperty(cls, "name", attributes, sizeof(attributes)/sizeof(objc_property_attribute_t));
            NSLog(@"Add a new property failed!");
        }
        // step 1, 设置方法
        SEL setter = sel_registerName("setName:");
        class_addMethod(cls, setter, (IMP)(setName), "v@:@");
        SEL getter = sel_registerName("name");
        class_addMethod(cls, getter, (IMP)(name), "@@:");
        
        // step 2, 设置对应的成员变量
        class_addIvar(cls, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
        
        // step 3, 操作属性
        NSObject *obj = class_createInstance(cls, 0);
        
        // 操作方法 1
        Method setterName = class_getInstanceMethod(cls, setter);
        method_invoke(obj, setterName, @"uwei");
        Method getterName = class_getInstanceMethod(cls, getter);
        id name = method_invoke(obj, getterName);
        
        // 操作方法 2
        //            objc_msgSend(obj, setter, @"uwei");
        //            id name = objc_msgSend(obj, getter);
        NSLog(@"property name is %@", name);
        
        // add var
        // add int var， 必须after objc_allocateClassPair & before objc_registerClassPair
        // 不支持向一个已经存在的类中添加成员变量
        BOOL addIntVarResult = class_addIvar(cls, "_age", sizeof(int), sizeof(int), @encode(int));
        if (addIntVarResult) {
            NSLog(@"Add a new Int var success!");
            id obj = class_createInstance(cls, 0);
            Ivar age = class_getInstanceVariable(cls, "_age");
//            object_setInstanceVariable(obj, "_age", 29); 此方法不支持ARC
            object_setIvar(obj, age, @(29));
            id ageValue = object_getIvar(obj, age);
            NSLog(@"_age = %@", ageValue);
        } else {
            NSLog(@"Add a new Int var failed!");
        }
        
        // add object var
        BOOL addObjectResult = class_addIvar(cls, "_address", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
        if (addObjectResult) {
            NSLog(@"Add a new Object var success!");
            id obj = class_createInstance(cls, 0);
            Ivar address = class_getInstanceVariable(cls, "_address");
            object_setIvar(obj, address, @"SZ");
            id addressValue = object_getIvar(obj, address);
            NSLog(@"_address = %@", addressValue);
        } else {
            NSLog(@"Add a new Object var failed!");
        }
        
        unsigned int methodCount = 0;
        Method *listMethod = class_copyMethodList(cls, &methodCount);
        for (int i = 0; i < methodCount; ++i) {
            NSLog(@"method [%d] is %@", i, NSStringFromSelector(method_getName(listMethod[i])));
        }
        if (listMethod) {
            free(listMethod);
            listMethod = NULL;
        }
        
        unsigned int varCount = 0;
        Ivar *listVar = class_copyIvarList(cls, &varCount);
        for (int  i = 0; i < varCount; ++i) {
            NSLog(@"var[%d] is %s type is %s offset is [%td]", i, ivar_getName(listVar[i]), ivar_getTypeEncoding(listVar[i]), ivar_getOffset(listVar[i]));
        }
        if (listVar) {
            free(listVar);
            listVar = NULL;
        }
        
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for (int  i = 0 ; i <  propertyCount; ++i) {
            NSLog(@"property [%s]  attribute is %s, attribute value is %s", property_getName(properties[i]), property_getAttributes(properties[i]), property_copyAttributeValue(properties[i], "T"));
        }
        if (properties) {
            free(properties);
            properties = NULL;
        }
        // 关于属性的操作详细见https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101
        
        objc_registerClassPair(cls);
        
#pragma mark - Operation on an existed class
        
        Class myClass = [MyClass class];
        NSLog(@"My Class name is %s", class_getName(myClass));
        NSLog(@"My Class super class name is %s", class_getName(class_getSuperclass(myClass)));
        NSLog(@"%@", class_isMetaClass([MyClass class]) ? @"MyClass is a meta class":@"MyClass is not a meta class");
        // 对齐原则
        // 不同类型的成员变量占内存大小不同
        NSLog(@"the size of instances of a class is %zu",class_getInstanceSize(myClass));
        // TODO: what is layout? Layout是描述属性在对象内存中的布局
        // 查询strong，weak的属性描述，这个序列会将基本数据类型排在最前面
        const uint8_t *array_layout = class_getIvarLayout([LayoutClass class]);
        int layoutIndex = 0;
        int8_t layoutValue = array_layout[layoutIndex];
        while (layoutValue != 0x0) {
            // 内存中的layout 将会优先排列基本数据类型
            printf("\\x%02x\n", layoutValue);
            layoutValue = array_layout[++layoutIndex];
        }
        Method myClassClassMethod = class_getClassMethod(myClass, @selector(myClassClassMethodWithOutParamater));
        NSLog(@"myClass class Method is %s", sel_getName(method_getName(myClassClassMethod)));
        //通过使用sel_registerName可以绕过编译器检查
        Method myClassClassMethodFromRegister = class_getClassMethod(myClass, sel_registerName("myClassClassMethodNoExist"));
        NSLog(@"myClass class Method is %s not exist", sel_getName(method_getName(myClassClassMethodFromRegister)));
        
        Method myClassClassMethodWith2P = class_getClassMethod(myClass, @selector(myClassClassMethodWithParamater1:paramater2:));
        NSLog(@"myClass class Method1 is %s", sel_getName(method_getName(myClassClassMethodWith2P)));
        
        Method myClassInstanceMethod = class_getInstanceMethod(myClass, @selector(myClassInstanceMethodWithOutParamater));
        NSLog(@"My class instance method is %s", sel_getName(method_getName(myClassInstanceMethod)));

//        This macro indicates that the values stored in certain local variables should not be aggressively released by the compiler during optimization.
        // 在ARC的模式下，很多局部变量很快就会被编译器优化，释放掉，而这个宏正好可以解决这个问题，直到作用范围被执行完毕之后才让编译器释放这个局部变量
        NS_VALID_UNTIL_END_OF_SCOPE MyClass *myClassInstace = [MyClass new];
        [myClassInstace canBeReplacedMethod];
        
        // replace method or exchange method
        Method oringnalMethod = class_getInstanceMethod(myClass, @selector(canBeReplacedMethod));
        // 获取一个方法的IMP方法一
//        IMP originalIMP = method_getImplementation(oringnalMethod);
        
        // 获取一个方法的IMP方法二
        // class_getMethodImplementation may be faster than method_getImplementation(class_getInstanceMethod(cls, name)).
        IMP originalIMP = class_getMethodImplementation(myClass, @selector(canBeReplacedMethod));
        
        [myClassInstace canBeReplacedMethod];
        BOOL hadThisMehod = class_addMethod(myClass, @selector(canBeReplacedMethod), originalIMP, method_getTypeEncoding(oringnalMethod));
        if (hadThisMehod) {
            NSLog(@" class had this method now replace");
            // 使用C方式的替换
            class_replaceMethod(myClass, @selector(canBeReplacedMethod), (IMP)(myClassReplaceMethod), "@v:");
            
            // 也可以通过Category的方式扩展类的方法，然后将方法class_replaceMethod中使用的参数，通过runtime函数获取
        } else {
            method_exchangeImplementations(oringnalMethod, class_getInstanceMethod(myClass, @selector(myClassReplacedMethod)));
        }
        
        [myClassInstace canBeReplacedMethod];
        [myClassInstace performSelector:@selector(myClassReplacedMethod)];
        
        // 对于持久化(archive)很重要，可以知道类的Layout变化
        [MyClass setVersion:3];
        int myClassVersion = class_getVersion(myClass);
        NSLog(@"My class current version is %d", [MyClass getVersion]);
        
        /****************  working with instance start******************** */
        
        NSLog(@"myClassInstace's class name is %s", object_getClassName(myClassInstace));
        NSLog(@"myClassInstace's class name is %s", class_getName(object_getClass(myClassInstace)));
        
        // 修改实例对象所属的类
        object_setClass(myClassInstace, cls);
        NSLog(@"myClassInstace's class name is %s", object_getClassName(myClassInstace));
        object_setClass(myClassInstace, myClass);
        
        /****************  working with instance end******************** */
        
        
        /****************  get class defintion start******************** */
        Class myClassLookup = objc_lookUpClass("MyClass");
        id myClassSpecified = objc_getClass("MyClass");
        
        // crash(kills the process) if the class is not found, ZeroLink
        Class myRequrieClass = objc_getRequiredClass("NewDynamicClass");
        id myClassMetaClass = objc_getMetaClass("MyClass");
        
        NSLog(@"myClass Look Up Class name is %s", object_getClassName(myClassLookup));
        NSLog(@"myClass Specified name is %s", object_getClassName(myClassSpecified));
        NSLog(@"myClass Meta Class name is %s", object_getClassName(myClassMetaClass));
        
        //The Objective-C runtime library automatically registers all the classes defined in your source code. You can create class definitions at runtime and register them with the objc_addClass function.`
        int numClasses;
        Class * classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0 ) {
            //NSLog(@"numClasses = %d", numClasses);
            classes = (Class *)malloc(numClasses * sizeof(Class));
            numClasses = objc_getClassList(classes, numClasses);
            free(classes);
            classes = NULL;
        }
        
        unsigned int copyClassesNum = 0;
        classes = objc_copyClassList(&copyClassesNum);
        if (classes) {
            free(classes);
            classes = NULL;
        }
        
        /****************  get class defintion end******************** */
//        为现有的类添加私有变量以帮助实现细节；
//        为现有的类添加公有属性；
//        为 KVO 创建一个关联的观察者
        static char associatedKey;
        NSString * associatedObject = [[NSString alloc] initWithFormat:@"%@", @"First three numbers"];
        objc_setAssociatedObject(myClassInstace, &associatedKey, associatedObject, OBJC_ASSOCIATION_RETAIN);
        NSString *associatedObject1 = (NSString *)objc_getAssociatedObject(myClassInstace, &associatedKey);
        NSLog(@"associatedObject:%@", associatedObject1);
        objc_removeAssociatedObjects(myClassInstace);
        objc_setAssociatedObject(myClassInstace, &associatedKey, nil, OBJC_ASSOCIATION_RETAIN);
        //一个具体的实例：https://www.cnblogs.com/cqcnblogs/p/5796462.html
        
        /****************  Sending Message ******************** */
        // sending message
        struct objc_super objcSuper;
        id myClassObjcet = [MySubClass new];
        objcSuper.receiver = myClassObjcet;
        objcSuper.super_class = [MyClass class];
        NSString *des = objc_msgSendSuper(&objcSuper, @selector(description));
        NSLog(@"super return is %@", des);
        char r [256] = {0};
        // TODO: error
        //objc_msgSend_stret(myClassObjcet, @selector(description), r, r);
        /****************  Sending Message ******************** */
#pragma mark - Method
        
        unsigned int myClassMethodCount = 0;
        // instance method list
        Method *myClassInstanceMethodList = class_copyMethodList(myClass, &myClassMethodCount);
        for (int i = 0 ; i < myClassMethodCount; ++i) {
            // 获取返回值类型方法1
//            char *returnType = method_copyReturnType(myClassMethodList[i]);
//            NSLog(@"My class instance method return type is %s", returnType);
//            free(returnType);
            // 获取返回值类型方法 2
            char returnChars[32] = {0};
            method_getReturnType(myClassInstanceMethodList[i], returnChars, 32);
            NSLog(@"instance method name is %s, type encode is %s, return type is %s", sel_getName(method_getName(myClassInstanceMethodList[i])), method_getTypeEncoding(myClassInstanceMethodList[i]), returnChars);
            
            int parameterCount = 0;
            // include self,_cmd,and other custom argument
            parameterCount = method_getNumberOfArguments(myClassInstanceMethodList[i]);
            NSLog(@"instance method arguments' count = %d", parameterCount);
            for (int j = 0; j < parameterCount; j++) {
                // 获取参数类型方法1
//                char arguments[32] = {0};
//                method_getArgumentType(myClassMethodList[j], j, arguments, 32);
                // 获取参数类型方法2
                char *argumentType = method_copyArgumentType(myClassInstanceMethodList[j], j);
                NSLog(@"argument[%d] type is [%s]", j, argumentType);
                free(argumentType);
            }
            
            if (strcmp(sel_getName(method_getName(myClassInstanceMethodList[i])),"canBeReplacedByIMP") == 0) {
                method_invoke(myClassInstace, myClassInstanceMethodList[i]);
                IMP orignalIMP = method_setImplementation(myClassInstanceMethodList[i], (IMP)(myMethodBeSetIMP));
                method_invoke(myClassInstace, myClassInstanceMethodList[i]);
                method_setImplementation(myClassInstanceMethodList[i], orignalIMP);
                method_invoke(myClassInstace, myClassInstanceMethodList[i]);
            }
            
        }
        free(myClassInstanceMethodList);
        
        unsigned int myClassClassMethodCount = 0;
        
        // class method list
        Method *myClassClassMethodList = class_copyMethodList(object_getClass(myClass), &myClassClassMethodCount);
        for (int i = 0 ; i < myClassClassMethodCount; ++i) {
            // class method
            NSLog(@"class method is %s", sel_getName(method_getName(myClassClassMethodList[i])));
        }
        free(myClassClassMethodList);
        
        
        
        
#pragma mark - Library
        const char **libs = NULL;
        unsigned int librariesCount = 0;
        
        //the names of all the loaded Objective-C frameworks and dynamic libraries.
        libs = objc_copyImageNames(&librariesCount);
        if (librariesCount > 0) {
            for (int i = 0; i < librariesCount; ++i) {
                NSLog(@"This library's name is %s", *(libs + i));
                if (i == 0) {
                    unsigned int classesCount = 0;
                    const char **classes = objc_copyClassNamesForImage(*(libs + i), &classesCount);
                    for (int j = 0 ; j < classesCount; ++j) {
                        NSLog(@"class[%d] is %s in %@", j, *(classes + j), [[NSString stringWithUTF8String:*(libs + i)] lastPathComponent]);
                    }
                    if (classes) {
                        free(classes);
                        classes = NULL;
                    }
                }
            }
        }
        free(libs);
        libs = NULL;
        
        const char *dynamicLibraryName = NULL;
        dynamicLibraryName = class_getImageName(myClass);
        NSLog(@"MyClass image's name is %s", dynamicLibraryName);
        dynamicLibraryName = class_getImageName(cls);
        NSLog(@"cls dynamic class image's name is %s", dynamicLibraryName);
        
#pragma mark - Protocol
        
        unsigned int myClassAdoptProtocolCount = 0;
        __unsafe_unretained Protocol **myClassProtocols = class_copyProtocolList(myClass, &myClassAdoptProtocolCount);
        for (int i = 0; i < myClassAdoptProtocolCount; ++i) {
            Protocol *protocol = *(myClassProtocols + i);
            NSLog(@"My class adopts protocol name is %s", protocol_getName(protocol));
        }
        free(myClassProtocols);
        myClassProtocols = NULL;
        
        Protocol *myCustomProtocol = objc_allocateProtocol("MyCustomProtocol");
        SEL myCustomProtocolOptionalInstanceMethod = sel_registerName("MyCustomProtocolOptionalInstanceMethod");
        protocol_addMethodDescription(myCustomProtocol, myCustomProtocolOptionalInstanceMethod, "@", NO, YES);
        SEL myCustomProtocolRequiredClassMethod = sel_registerName("MyCustomProtocolRequiredClassMethod");
        protocol_addMethodDescription(myCustomProtocol, myCustomProtocolRequiredClassMethod, "i", YES, NO);

        struct objc_method_description * methodDescriptionForCustomProtocol = NULL;
        unsigned int  methodCountInDescriptionForCustomProtocol = 0;
        methodDescriptionForCustomProtocol = protocol_copyMethodDescriptionList(myCustomProtocol, NO, YES, &methodCountInDescriptionForCustomProtocol);
        for (int i = 0; i < methodCountInDescriptionForCustomProtocol; ++i) {
            NSLog(@"MyCustomProtocol optional method[%d]'s name is %s, argument is %s", i, sel_getName(((struct objc_method_description)methodDescriptionForCustomProtocol[i]).name), ((struct objc_method_description)methodDescriptionForCustomProtocol[i]).types);
        }
        
        protocol_addProtocol(myCustomProtocol, objc_getProtocol("NSObject"));
        if (protocol_conformsToProtocol(myCustomProtocol, objc_getProtocol("NSObject"))) {
            NSLog(@"My Custom Protocol conforms NSObjct");
        }
        protocol_addProperty(myCustomProtocol, "name", attributes, sizeof(attributes)/sizeof(objc_property_attribute_t), NO, YES);
        unsigned int propertyCountInMyCustomProtocol = 0;
        objc_property_t *protocolPropertyList = protocol_copyPropertyList(myCustomProtocol, &propertyCountInMyCustomProtocol);
        for (int i = 0; i < propertyCountInMyCustomProtocol; ++i) {
            NSLog(@"Custom Protocol property is %s", property_getName(protocolPropertyList[i]));
        }
        free(protocolPropertyList);
//        objc_property_t protocolProperty = protocol_getProperty(myCustomProtocol, "name", NO, YES);
//        NSLog(@"Custom Protocol property is %s", property_getName(protocolProperty));
        
        objc_registerProtocol(myCustomProtocol);
        
        // 当协议中的方法是必须时，此方法就可以绕过编译器的编译检查
        BOOL addCustomProtocolResult = class_addProtocol(myClass, myCustomProtocol);
        if (addCustomProtocolResult) {
            if (class_conformsToProtocol(myClass, myCustomProtocol)) {
                NSLog(@"My class be added to be adopted MyCustomProtocol");
            }
            
        } else {
            NSLog(@"My class can't be added to be adopted MyCustomProtocol");
        }
        myClassProtocols = class_copyProtocolList(myClass, &myClassAdoptProtocolCount);
        for (int i = 0; i < myClassAdoptProtocolCount; ++i) {
            Protocol *protocol = *(myClassProtocols + i);
            NSLog(@"My class adopts protocol [%d] is %s", i, protocol_getName(protocol));
        }
        
        free(myClassProtocols);
        myClassProtocols = NULL;
        
#pragma mark - OC Language Features
        objc_setEnumerationMutationHandler(&mutateFunction);
        objc_enumerationMutation([NSObject new]);
        NSString *weakStringTarget = @"uwei";
        
        // __weak
        id weakLoad = objc_loadWeak(&weakStringTarget);
        weakLoad = @"demo";
        id weakStore = nil;
        objc_storeWeak(&weakStore, weakStringTarget);
        NSLog(@"weak load string is %@ weak load string is %@", weakLoad, weakStore);
    }
    
    
    return 0;
}
