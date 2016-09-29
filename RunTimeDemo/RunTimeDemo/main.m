//
//  main.m
//  RunTimeDemo
//
//  Created by uwei on 3/17/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <objc/runtime.h>
#import <objc/message.h>

#define OBJC_OLD_DISPATCH_PROTOTYPES 0


// this is a method to custom a root class without inheried from superclass
OBJC_ROOT_CLASS @interface MyRootClass

@end

@implementation MyRootClass


@end





@protocol MyProtocol <NSObject>

@optional
- (void)myProctolMethod;

@end


@interface MyClass: NSObject<MyProtocol>{
    int instanceVar;
}


@property (copy, nonatomic) NSString *name;
@property (assign, atomic)  CGFloat  age;

- (void)myClassInstanceMethodWithOutParamater;
- (void)myClassInstanceMethodWithParamater:(id)paramater;
+ (void)myClassClassMethodWithOutParamater;

- (void)canBeReplacedMethod;

- (NSInteger)myClassInstanceMethodWithParameterAndReturnValue:(NSInteger)paramater;


@end


@implementation MyClass

- (void)myClassInstanceMethodWithOutParamater {
    NSLog(@"myClassInstanceMethodWithOutParamater");
}

- (void)myClassInstanceMethodWithParamater:(id)paramater {
    NSLog(@"myClassInstanceMethodWithParamater is %@", paramater);
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

@end



// c method
void myClassReplaceMethod(self, _cmd) {
    NSLog(@"myClassReplaceMethod");
}



void myMethodIMP(self, _cmd) {
    NSLog(@"myMethodIMP");
}

void myMethodBeSetIMP(self, _cmd) {
    NSLog(@"%s", __FUNCTION__);
}




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        
        // create a new class
        Class cls = objc_allocateClassPair([NSObject class], "A", 0);
        
        // You must register a method name with the Objective-C runtime system to obtain the method’s selector before you can add the method to a class definition. If the method name has already been registered, this function simply returns the selector.
        SEL aDynanicMethodSelector = sel_registerName("aDynanicMethod");
//        if (class_respondsToSelector(cls, @selector(aDynanicMethod))) {
        if (class_respondsToSelector(cls, aDynanicMethodSelector)) {
            NSLog(@"Class respond to Method");
        } else {
            NSLog(@"Class not respond to Method");
        }
        
        // add method
        
        
        BOOL addMethodResult = class_addMethod(cls, aDynanicMethodSelector, (IMP)(myMethodIMP), "v@:");
        if (addMethodResult) {
            NSLog(@"Add a method to Class Success!");
        } else {
            NSLog(@"Add a method to Class Failed!");
        }
        
        if (class_respondsToSelector(cls, aDynanicMethodSelector)) {
            NSLog(@"Class respond to Method");
        } else {
            NSLog(@"Class not respond to Method");
        }
        
        objc_property_attribute_t type = {"T", "@\"NSString\""};
        objc_property_attribute_t automatic = {"N", ""};
        objc_property_attribute_t ownerShip = {"C", ""};
        objc_property_attribute_t variable  = {"V", "_name"};
        
        objc_property_attribute_t attributes[] = {type, automatic, ownerShip, variable};
        
        
        // add property
        BOOL addPropertyResult = class_addProperty(cls, "name", attributes, 4);
        if (addPropertyResult) {
            NSLog(@"Add New property Success!");
        } else {
            NSLog(@"Add New property Failed!");
        }
        
        // add var
        
        // add int var
        BOOL addIntVarResult = class_addIvar(cls, "_age", sizeof(int), sizeof(int), @encode(int));
        if (addIntVarResult) {
            NSLog(@"Add New Int Var Success!");
        } else {
            NSLog(@"Add New Int Var Failed!");
        }
        
        
        // add object var
        BOOL addObjectResult = class_addIvar(cls, "_address", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
        if (addObjectResult) {
            NSLog(@"Add New Object Var Success!");
        } else {
            NSLog(@"Add new Object Var Failed!");
        }
        
        objc_registerClassPair(cls);
        id instance = [[cls alloc] init];
        
        // not allowed in arc enviroment
//        id instance = class_createInstance(cls, 0);
        
        // call method of class
        [instance performSelector:@selector(aDynanicMethod)];
        
        // access property of an instance
        unsigned int propertyCount = 0;
        objc_property_t *propertys = class_copyPropertyList(cls, &propertyCount);
        for (int  i = 0 ; i <  propertyCount; ++i) {
            NSLog(@"Property name is %s", property_getName(propertys[i]));
            NSLog(@"Property attribute is %s", property_getAttributes(propertys[i]));
        }
        
        
        // access var of an instance
        unsigned int varCount = 0;
        Ivar *varList = class_copyIvarList(cls, &varCount);
        for (int i = 0; i < varCount; ++i) {
            NSLog(@"Var name is %s", ivar_getName(varList[i]));
        }
        
        
        // Var setter & getter
        Ivar ageIvar = class_getInstanceVariable(cls, "_age");
        Ivar addressIvar = class_getInstanceVariable(cls, "_address");
        object_setIvar(instance, ageIvar, @28);
        object_setIvar(instance, addressIvar, @"shenzhen");
        NSLog(@"age = %@", object_getIvar(instance, ageIvar));
        NSLog(@"address = %@", object_getIvar(instance, addressIvar));
        
        // property getter
        objc_property_t property = class_getProperty(cls, "name");
        
        
        
        Class myClass = [MyClass class];
        NSLog(@"My Class name is %s", class_getName(myClass));
        NSLog(@"My Class super class name is %s", class_getName(class_getSuperclass(myClass)));
        
        if (class_isMetaClass([MyClass class])) {
            NSLog(@"MyClass is a meta class");
        } else {
            NSLog(@"MyClass is not a meta class");
        }
        
        NSLog(@"the size of instances of a class is %zu",class_getInstanceSize(myClass));
        
        // TODO: what is layout?
        NSLog(@"Var Layout is %s", class_getIvarLayout(myClass));
        
        
        
        
        Method myClassClassMethod = class_getClassMethod(myClass, @selector(myClassClassMethodWithOutParamater));
        NSLog(@"myClass class Method is %s", sel_getName(method_getName(myClassClassMethod)));
        
        Method myClassClassMethod1 = class_getClassMethod(myClass, @selector(myClassInstanceMethodWithOutParamater));
        // print null
        NSLog(@"myClass class Method1 is %s", sel_getName(method_getName(myClassClassMethod1)));
        
        
        Method myClassInstanceMethod = class_getInstanceMethod(myClass, @selector(myClassInstanceMethodWithOutParamater));
        NSLog(@"My class instance method is %s", sel_getName(method_getName(myClassInstanceMethod)));
        
        Method myClassInstanceMethod1 = class_getInstanceMethod(myClass, @selector(myClassClassMethodWithOutParamater));
        // print null
        NSLog(@"My class instance method1 is %s", sel_getName(method_getName(myClassInstanceMethod1)));
        
        
        
        
        
//        This macro indicates that the values stored in certain local variables should not be aggressively released by the compiler during optimization.
        // 在ARC的模式下，很多局部变量很快就会被编译器优化，释放掉，而这个宏正好可以解决这个问题，知道作用范围被执行完毕之后才让编译器释放这个局部变量
        NS_VALID_UNTIL_END_OF_SCOPE MyClass *myClassInstace = [MyClass new];
        [myClassInstace canBeReplacedMethod];
        // replace method
        class_replaceMethod(myClass, @selector(canBeReplacedMethod), (IMP)(myClassReplaceMethod), "@v:");
        
        [myClassInstace canBeReplacedMethod];
        
        
        
        /****************  working with instance variables start******************** */
        
        // not allowed in arc
//        MyClass *copyMyClassInstance = object_copy(myClassInstace, sizeof(MyClass));
//        Ivar *myClassInstanceVar = object_setInstanceVariable(myClassInstace, "instanceVar", 8);
//        object_getInstanceVariable(myClassInstace, "instanceVar", nil);
        Ivar myClassInstanceVar = class_getInstanceVariable(myClass, "instanceVar");
        object_setIvar(myClassInstace, myClassInstanceVar, [NSNumber numberWithInt:1000008]);
        NSNumber *myClassInstanceVarValue = object_getIvar(myClassInstace, myClassInstanceVar);
        NSLog(@"myClassInstanceVarValue %@", myClassInstanceVarValue);
        NSLog(@"myClassInstace's class name is %s", object_getClassName(myClassInstace));
        
        
        
        //The Objective-C runtime library automatically registers all the classes defined in your source code. You can create class definitions at runtime and register them with the objc_addClass function.`
        int numClasses;
        Class * classes = NULL;
        classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0 ) {
            NSLog(@"numClasses = %d", numClasses);
        }
        
        /****************  working with instance variables end******************** */
        
        
        /****************  get class defintion start******************** */
        id myClassLookup = objc_lookUpClass("MyClass");
        id myClassSpecified = objc_getClass("MyClass");
        id myClassMetaClass = objc_getMetaClass("MyClass");
        
        NSLog(@"LookUpClass name is %s", object_getClassName(myClassLookup));
        NSLog(@"myClassSpecified name is %s", object_getClassName(myClassSpecified));
        NSLog(@"myClassMetaClass name is %s", object_getClassName(myClassMetaClass));
        
        /****************  get class defintion end******************** */
        
        
        
        
        
        
        unsigned int myClassProperyCount = 0;
        objc_property_t *myClassProperties = class_copyPropertyList(myClass, &myClassProperyCount);
        for (int i = 0; i < myClassProperyCount; ++i) {
            NSLog(@"My Class property name is %s", property_getName(myClassProperties[i]));
            NSLog(@"My Class property's attribute is %s", property_getAttributes(myClassProperties[i]));
        }
        
        unsigned int myClassVarCount = 0;
        Ivar *myClassVarList = class_copyIvarList(myClass, &myClassVarCount);
        for (int i = 0; i < myClassVarCount; ++i) {
            
            // Working with Instance Variables start
            NSLog(@"MyClass Var is %s", ivar_getName(myClassVarList[i]));
            NSLog(@"MyClass Var type is %s", ivar_getTypeEncoding(myClassVarList[i]));
            //Working with Instance Variables end
        }
        
        
        //关联是指把两个对象相互关联起来，使得其中的一个对象作为另外一个对象的一部分
//        objc_setAssociatedObject(myClassInstace, "instanceVar", [NSNumber numberWithInt:1000009], OBJC_ASSOCIATION_ASSIGN);
//        void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy)
//        id objc_getAssociatedObject(id object, void *key)
//        void objc_removeAssociatedObjects(id object)
        static char overviewKey;
        NSArray *array = @[@"One", @"Two", @"Three"];
        //为了演示的目的，这里使用initWithFormat:来确保字符串可以被销毁
        NSString * overview = [[NSString alloc] initWithFormat:@"%@", @"First three numbers"];
        objc_setAssociatedObject(array, &overviewKey, overview, OBJC_ASSOCIATION_RETAIN);
        
        NSString *associatedObject = (NSString *)objc_getAssociatedObject(array, &overviewKey);
        NSLog(@"associatedObject:%@", associatedObject);
        
        
        
        
        
        // sending message
        
        
//        When it encounters a method invocation, the compiler might generate a call to any of several functions to perform the actual message dispatch, depending on the receiver, the return value, and the arguments. You can use these functions to dynamically invoke methods from your own plain C code, or to use argument forms not permitted by NSObject’s perform... methods. These functions are declared in /usr/include/objc/objc-runtime.h.
//        objc_msgSend sends a message with a simple return value to an instance of a class.
//        objc_msgSend_stret sends a message with a data-structure return value to an instance of a class.
//        objc_msgSendSuper sends a message with a simple return value to the superclass of an instance of a class.
//        objc_msgSendSuper_stret sends a message with a data-structure return value to the superclass of an instance of a class.
        objc_msgSend(myClassInstace, @selector(myClassInstanceMethodWithOutParamater));
        objc_msgSend(myClassInstace, @selector(myClassInstanceMethodWithParamater:), @"******HAHAHA*****");
        
        // objc_msgSend's return value type is selector return type
        NSInteger returnResult = objc_msgSend(myClassInstace, @selector(myClassInstanceMethodWithParameterAndReturnValue:), 123);
        NSLog(@"objc_msgSend's result = %ld", (long)returnResult);
        
        
        
        
#pragma mark - Method
        Method aMethod = class_getInstanceMethod(cls, @selector(aDynanicMethod));
        
        // exc_bad_access
//        method_invoke(instance, aMethod);
//        IMP method_getImplementation( Method method)
        
        
        
        
        unsigned int myClassMethodCount = 0;
        // class_copyMethodList() parameters diff, instance
        Method *myClassMethodList = class_copyMethodList(myClass, &myClassMethodCount);
        for (int i = 0 ; i < myClassMethodCount; ++i) {
            // instance method
            NSLog(@"My Class instance method is %s", sel_getName(method_getName(myClassMethodList[i])));
            NSLog(@"My Class instance method type is %s", method_getTypeEncoding(myClassMethodList[i]));
            char *returnType = method_copyReturnType(myClassMethodList[i]);
            NSLog(@"My class instance method return type is %s", returnType);
            free(returnType);
            
            char returnChars[32] = {0};
            method_getReturnType(myClassMethodList[i], returnChars, 32);
            NSLog(@"My class instance method return type is %s", returnChars);
            
            int parameterCount = 0;
            // include self,_cmd,and other custom argument
            parameterCount = method_getNumberOfArguments(myClassMethodList[i]);
            NSLog(@"My Class instance method arguments' count = %d", parameterCount);
            
            if (strcmp(sel_getName(method_getName(myClassMethodList[i])),"canBeReplacedByIMP") == 0) {
                method_invoke(myClassInstace, myClassMethodList[i]);
                method_setImplementation(myClassMethodList[i], (IMP)(myMethodBeSetIMP));
//                method_invoke(myClassInstace, myClassMethodList[i]);
            }
            
            //exchange method IMP
//            void method_exchangeImplementations( Method m1, Method m2)
            
            
//            char * method_copyArgumentType( Method method, unsigned int index)
        }
        free(myClassMethodList);
        
        unsigned int myClassClassMethodCount = 0;
        // class_copyMethodList() parameters diff, class
        Method *myClassClassMethodList = class_copyMethodList(object_getClass(myClass), &myClassClassMethodCount);
        for (int i = 0 ; i < myClassClassMethodCount; ++i) {
            // class method
            NSLog(@"My Class class method is %s", sel_getName(method_getName(myClassClassMethodList[i])));
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
            }
        }
        free(libs);
        
        const char *dynamicLibraryName = NULL;
        //  TODO: if cls ,the result is null, if myClass , the result is target's name
        dynamicLibraryName = class_getImageName(myClass);
        NSLog(@"My class dynamic class name is %s", dynamicLibraryName);
        
        
        
        
        
        
        
        unsigned int myClassAdoptProtocolCount = 0;
        __unsafe_unretained Protocol **myClassProtocols = class_copyProtocolList(myClass, &myClassAdoptProtocolCount);
        
        for (int i = 0; i < myClassAdoptProtocolCount; ++i) {
            Protocol *protocol = *(myClassProtocols + i);
            NSLog(@"My class adopts protocol name is %s", protocol_getName(protocol));
        }
        
        free(myClassProtocols);
        
        
        // if protocol not be compiled and linked, this method return nil
        Protocol *myProtocol = objc_getProtocol("MyProtocol");
        if (myProtocol) {
            NSLog(@"Get protocol OK");
            BOOL addProtocolResult = class_addProtocol(cls, myProtocol);
            if (addProtocolResult) {
                NSLog(@"cls be added a MyProtocol");
            } else {
                NSLog(@"cls not be added a MyProtocol");
            }
        } else {
            NSLog(@"Get protocol NO");
        }
        
        
        Protocol *myCustomProtocol = objc_allocateProtocol("MyCustomProtocol");
        SEL myCustomProtocolOptionalInstanceMethod = sel_registerName("MyCustomProtocolOptionalInstanceMethod");
        protocol_addMethodDescription(myCustomProtocol, myCustomProtocolOptionalInstanceMethod, "customInstaceMethod", NO, YES);
        SEL myCustomProtocolRequiredClassMethod = sel_registerName("MyCustomProtocolRequiredClassMethod");
        protocol_addMethodDescription(myCustomProtocol, myCustomProtocolRequiredClassMethod, "customClassMethod", YES, NO);
        
        // 只要是在上层实现的，在runtime都是可以获取，操作的！
//        void protocol_addProtocol(Protocol *proto, Protocol *addition)
//        void protocol_addProperty(Protocol *proto, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty)
//        struct objc_method_description *protocol_copyMethodDescriptionList(Protocol *p, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount)
//        BOOL protocol_conformsToProtocol(Protocol *proto, Protocol *other)
        
        objc_registerProtocol(myCustomProtocol);
        
        // 当协议中的方法是必须时，此方法就可以绕过编译器的编译检查
        BOOL addCustomProtocolResult = class_addProtocol(myClass, myCustomProtocol);
        if (addCustomProtocolResult) {
            NSLog(@"My class adopt MyCustomProtocol");
        } else {
            NSLog(@"My class don't adopt MyCustomProtocol");
        }
        
        
        
    }
    return 0;
}
