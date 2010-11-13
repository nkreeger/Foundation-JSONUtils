//==============================================================================
//
//  NSArray+JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import "NSArray+JSONUtils.h"

#import "JSONUtils.h"


@implementation NSArray (JSONUtil)

+ (NSArray *)arrayForJSON:(NSString *)aJSONString
{
  if (PeakNextJSONBlockType(aJSONString, 0) != eArrayBlock) {
    // This API assumes that the string starts with a '[' char.
    return nil;
  }

  return GetJSONArray(aJSONString);
}

@end
