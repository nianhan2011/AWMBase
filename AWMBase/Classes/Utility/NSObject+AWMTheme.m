//
//  NSObject+AWMTheme.m
//
//  Created by 殷凡 on 2018/8/7.
//

#import "NSObject+AWMTheme.h"

static const void * __AWMRetainNoOp( CFAllocatorRef allocator, const void * value ) {return value ;}
static void __AWMReleaseNoOp( CFAllocatorRef allocator, const void * value ) {}
static CFMutableArrayRef _themeColorPool;
static UIColor *_currentThemeColor;

@implementation NSObject (AWMTheme)
- (void)addToThemeColorPool:(NSString *)propertyName {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
        _themeColorPool = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
    });
    // 如果对象为_UIAppearance，直接返回
    Class appearanceClass = NSClassFromString(@"_UIAppearance");
    if ([self isMemberOfClass:appearanceClass]) return;
    // 键：对象地址+属性名 值：对象
    NSString *pointString = [NSString stringWithFormat:@"%p%@", self, propertyName];
//    CFStringRef keys[1] = {(__bridge_retained CFStringRef)pointString};
    CFStringRef *keys = malloc(sizeof(CFStringRef));
    *keys = (__bridge_retained CFStringRef)pointString;
    void **values = malloc(sizeof(void *));
    *values = (__bridge_retained void *)self;
    CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
    CFDictionaryValueCallBacks valueCallbacks = kCFTypeDictionaryValueCallBacks;
    valueCallbacks.retain = __AWMRetainNoOp;
    valueCallbacks.release = __AWMReleaseNoOp;

    CFDictionaryRef dicRef = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, 1, &keyCallbacks, &valueCallbacks);
    // 判断是否已经在主题色池中
    for (CFIndex i = 0; i < CFArrayGetCount(_themeColorPool); i ++) {
        CFDictionaryRef subDicRef = CFArrayGetValueAtIndex(_themeColorPool, i);
        if (CFDictionaryContainsKey(subDicRef, *keys) && CFDictionaryContainsValue(subDicRef, *values)) return;
    }
    CFArrayAppendValue(_themeColorPool, dicRef);
    if (_currentThemeColor) { // 已经设置主题色，直接设置
        [self setValue:_currentThemeColor forKey:propertyName];
    }
    CFGetRetainCount(dicRef);
    CFRelease(*keys);
    CFRelease(*values);
    free(keys);
    free(values);
    CFRelease(dicRef);
}

/**
 * 设置主题色
 * color : 主题色
 */
- (void)setThemeColor:(UIColor *)color
{
    _currentThemeColor = color;
    // 遍历缓主题池，设置统一主题色
    for (CFIndex i = 0; i < CFArrayGetCount(_themeColorPool); i ++) {
        NSDictionary *subDic = (__bridge NSDictionary *)(CFArrayGetValueAtIndex(_themeColorPool, i)) ;
        // 取出key
        NSString *objectKey = nil;
        NSEnumerator *enumerator = [subDic keyEnumerator];
        NSString *key;
        while (key = [enumerator nextObject]) {
            objectKey = key;
            break;
        }
        id object = subDic[key];
        if (object == nil) {
            continue;
        }
        // 取出属性值
        NSString *propertyName = [objectKey substringFromIndex:[[NSString stringWithFormat:@"%p", object] length]];
        // 给对象的对应属性赋值（使用KVC）
        [object setValue:color forKeyPath:propertyName];
    }
}
@end
