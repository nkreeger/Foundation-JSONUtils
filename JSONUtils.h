//==============================================================================
//
//  JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

/*
  NOTES:
   - Roll all of category extensions into this file?
   - Add a NSObject category for returning either a dictionary or an array
     instead of assuming what the JSON values are.
 */

#import <Foundation/Foundation.h>


//
// @brief Typedef for determing JSON start type.
//
typedef enum {
  eNone = 0,
  eObjectBlock = 1,
  eArrayBlock = 2
} EJSONBlockType;

//
// @brief Peak to determine what the next block type in a JSON string is.
// @param aJSONString The JSON string to peak into.
// @param aStartPosition The position to start scanning the string at.
// @return The next block type (either object or an array)
//
EJSONBlockType PeakNextJSONBlockType(NSString *aJSONString,
                                     NSUInteger aStartPosition);

//
// @brief
//
NSDictionary* GetJSONObjectDictionary(NSString *aJSONObject);

//
// @brief
//
NSArray* GetJSONArray(NSString *aJSONString);
NSDictionary* GetJSONDictionary(NSString *aJSONString);


//------------------------------------------------------------------------------
// NSString extensions (maybe stick this elsewhere)

@interface NSString (MiscUtils)

- (NSString *)stringByTrimmingWhitespace;
- (NSString *)substringFromIndex:(NSUInteger)aStartIndex
                     toCharacter:(unichar)aStopChar;
- (NSString *)reverseSubstringFromIndex:(NSUInteger)aStartIndex
                            toCharacter:(unichar)aStopChar;
- (NSNumber *)scanNumberFromIndex:(NSUInteger)aStartIndex
                     numberLength:(NSUInteger *)aOutLength;

@end
