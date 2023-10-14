//
//  ViewController.m
//  swizzlingTest
//
//  Created by 林信沂 on 2023/10/14.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hackReplaceMethod:[self class]];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"呼叫viewWillAppear");
}
-(void)hackReplaceMethod:(Class)swizzleClass{
    
    SEL mySelector = @selector(viewWillAppear:);
    SEL replaceSelector = @selector(hackFunction);
    //原本的方法
    Method myMethod = class_getInstanceMethod(swizzleClass, @selector(viewWillAppear:));
    //要替換的方法
    Method replaceMethod = class_getInstanceMethod(swizzleClass, @selector(hackFunction));
    IMP getReplaceImp = method_getImplementation(replaceMethod);
    IMP getMyImp = method_getImplementation(replaceMethod);
    //判斷swizzleClass類添加方法是否成功，如果成功代表swizzleClass類沒有這個方法，方法存在於父類別，如果直接替換調用父類別的方法會閃退
    BOOL didAddMethod = class_addMethod(swizzleClass, mySelector, getReplaceImp, method_getTypeEncoding(replaceMethod));
    if (didAddMethod){
        class_replaceMethod(swizzleClass, replaceSelector, getMyImp, method_getTypeEncoding(myMethod));
    }else{
        method_exchangeImplementations(myMethod, replaceMethod);
    }
}
-(void)hackFunction{
    NSLog(@"將本來要呼叫的viewWillAppear替換成呼叫hackFunction");
}

@end
