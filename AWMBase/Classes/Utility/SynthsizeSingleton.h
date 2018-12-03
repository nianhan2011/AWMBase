//
//  SynthsizeSingleton.h
//  Pods
//
//  Created by hugo on 2017/4/10.
//
//

#ifndef SynthsizeSingleton_h
#define SynthsizeSingleton_h

#import <objc/runtime.h>

#define LCR_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
+ (classname *)accessorMethodName;

#if __has_feature(objc_arc)
#define LCR_SYNTHESIZE_SINGLETON_RETAIN_METHODS
#else
#define LCR_SYNTHESIZE_SINGLETON_RETAIN_METHODS \
- (id)retain \
{ \
return self; \
} \
\
- (NSUInteger)retainCount \
{ \
return NSUIntegerMax; \
} \
\
- (oneway void)release \
{ \
} \
\
- (id)autorelease \
{ \
return self; \
}
#endif

#define LCR_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName) \
\
static classname *accessorMethodName##Instance = nil; \
\
+ (classname *)accessorMethodName \
{ \
@synchronized(self) \
{ \
if (accessorMethodName##Instance == nil) \
{ \
accessorMethodName##Instance = [super allocWithZone:NULL]; \
accessorMethodName##Instance = [accessorMethodName##Instance init]; \
method_exchangeImplementations(\
class_getClassMethod([accessorMethodName##Instance class], @selector(accessorMethodName)),\
class_getClassMethod([accessorMethodName##Instance class], @selector(LCR_lockless_##accessorMethodName)));\
method_exchangeImplementations(\
class_getInstanceMethod([accessorMethodName##Instance class], @selector(init)),\
class_getInstanceMethod([accessorMethodName##Instance class], @selector(LCR_onlyInitOnce)));\
} \
} \
\
return accessorMethodName##Instance; \
} \
\
+ (classname *)LCR_lockless_##accessorMethodName \
{ \
return accessorMethodName##Instance; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
return [self accessorMethodName]; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
} \
- (id)LCR_onlyInitOnce \
{ \
return self;\
} \
\
LCR_SYNTHESIZE_SINGLETON_RETAIN_METHODS

#define LCR_DECLARE_SINGLETON_FOR_CLASS(classname) LCR_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared##classname)
#define LCR_SYNTHESIZE_SINGLETON_FOR_CLASS(classname) LCR_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, shared##classname)

#endif /* SynthsizeSingleton_h */
