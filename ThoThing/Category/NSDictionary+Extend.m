//
//  NSObject.m
//  iKorway
//
//  Created by SUNG WOOK MOON on 09. 10. 15..
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Extend.h"

#pragma mark NSDictionary Custom Keys
#define __Key_X @"__CK_X"
#define __Key_Y @"__CK_Y"
#define __Key_Width @"__CK_Width"
#define __Key_Height @"__CK_Height"
#define __Key_Origin @"__CK_Origin"
#define __Key_Size @"__CK_Size"

@implementation  NSDictionary (Extend)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (id)objectForKey_YM:(id)aKey
{
    id object = [self objectForKey:aKey];
    
    NSString *str_Value = @"";
    if (![object isKindOfClass:[NSNull class]])
    {
        str_Value = [self objectForKey:aKey];
    }
    
    if( object == nil )
    {
        return @"";
    }
    
    return  str_Value;
}
#pragma clang diagnostic pop


+ (NSDictionary *)dictionaryWithCGPoint:(CGPoint)point {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:point.x],__Key_X,
			[NSNumber numberWithFloat:point.y],__Key_Y,
			nil];
}
- (CGPoint)CGPointValue {
	return CGPointMake([[self objectForKey:__Key_X] floatValue], [[self objectForKey:__Key_Y] floatValue]);
}

+ (NSDictionary *)dictionaryWithCGSize:(CGSize)size {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:size.width],__Key_Width,
			[NSNumber numberWithFloat:size.height],__Key_Height,
			nil];
}
- (CGSize)CGSizeValue {
	return CGSizeMake([[self objectForKey:__Key_Width] floatValue], [[self objectForKey:__Key_Height] floatValue]);
}

+ (NSDictionary *)dictionaryWithCGRect:(CGRect)rect {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[self dictionaryWithCGPoint:rect.origin],__Key_Origin,
			[self dictionaryWithCGSize:rect.size],__Key_Size,
			nil];
}
- (CGRect)CGRectValue {
	CGRect _r;
	_r.origin = [[self objectForKey:__Key_Origin] CGPointValue];
	_r.size = [[self objectForKey:__Key_Size] CGSizeValue];
	return _r;
}

@end