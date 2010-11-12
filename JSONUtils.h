//==============================================================================
//  JSONUtils.h
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//==============================================================================

#import <Foundation/Foundation.h>


//
// @brief Typedef for determing JSON start type.
//  XXXkreeger: Could use a "smart" NSObject category method for returning
//              The array or dictionary version. (to-think-about)
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
                                     unsigned int aStartPosition);


//------------------------------------------------------------------------------
// NSString extensions (maybe stick this elsewhere)

@interface NSString (MiscUtils)

- (NSString *)stringByTrimmingWhitespace;

@end
