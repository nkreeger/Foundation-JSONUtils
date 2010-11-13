//==============================================================================
//
//  Foundation+JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

/*
  NOTES:
   - Add a NSObject category for returning either a dictionary or an array
     instead of assuming what the JSON values are.
 */

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


@interface NSArray (JSONUtil)

//
// @brief Returns an array full of the JSON values passed in via a string.
// @param aJSONString The JSON string to parse.
// @return A NSArray containing an array of dictionaries of parsed JSON data.
//
+ (NSArray *)arrayForJSON:(NSString *)aJSONString;

@end
