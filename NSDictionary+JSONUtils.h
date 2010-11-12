//==============================================================================
//
//  NSDictionary+JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import <Foundation/Foundation.h>


@interface NSDictionary (JSONUtils)

//
// @brief Returns a dictionary full of the JSON values passed in via a string.
// @param aJSONString The JSON value to convert to a dictionary.
// @return A NSDictionary containing the key/value pairs from the JSON, or nil
//         if the JSON is invalid.
//
+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString;

@end
