//==============================================================================
//
//  NSDictionary+JSONUtils.m
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import "NSDictionary+JSONUtils.h"

#import "JSONUtils.h"


//------------------------------------------------------------------------------
// JSONUtils category implementation for JSON.

@implementation NSDictionary (JSONUtils)

+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString
{
  if (PeakNextJSONBlockType(aJSONString, 0) != eObjectBlock) {
    // This API assumes that the string starts with a '{' char.
    return nil;
  }  
  return GetJSONObjectDictionary(GetNextJSONObjectString(aJSONString, 0));
}

@end
