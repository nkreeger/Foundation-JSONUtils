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

//
// @brief Returns an array full of the JSON values passed in via a string.
// @param aJSONString The JSON string to parse.
// @return A NSArray containing an array of dictionaries of parsed JSON data.
//
+ (NSArray *)arrayForJSON:(NSString *)aJSONString;

@end
