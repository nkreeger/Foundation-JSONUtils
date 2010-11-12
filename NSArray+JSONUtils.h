//==============================================================================
//
//  NSArray+JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import <Foundation/Foundation.h>


@interface NSArray (JSONUtil)

+ (NSArray *)arrayForJSON:(NSString *)aJSONString;

@end
