//==============================================================================
//
//  JSONUtils.m
//  Foundation+JSONUtils
//
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import "JSONUtils.h"


EJSONBlockType
PeakNextJSONBlockType(NSString *aJSONString, NSUInteger aStartPosition)
{
  for (NSUInteger i = aStartPosition; i < [aJSONString length]; ++i) {
    unichar curChar = [aJSONString characterAtIndex:i];
    switch (curChar) {
      case '[':
        return eArrayBlock;
      case '{':
        return eObjectBlock;
    }
  }
  return eNone;
}

NSString*
GetNextJSONObjectString(NSString *aJSONString, NSUInteger aStartPosition)
{
  // Look for the first closing brace (note, some edge cases not covered yet)
  NSUInteger objectEndPos = aStartPosition;
  BOOL found = NO;
  while (!found && objectEndPos < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:objectEndPos++];
    switch (curChar) {
      case '}':
        found = YES;
        break;
    }
  }
  
  if (found) {
    NSRange range = NSMakeRange(aStartPosition, objectEndPos - aStartPosition);
    return [aJSONString substringWithRange:range];
  }
  return nil;
}

NSDictionary*
GetJSONObjectDictionary(NSString *aJSONObject)
{
  NSDictionary *jsonDict = [NSMutableDictionary dictionary];
  NSUInteger curLocation = 0;
  while (curLocation < [aJSONObject length]) {
    NSRange range;
    NSString *symbol = [aJSONObject jsonSymbolFromLocation:curLocation 
                                                  outRange:&range];
    if (!symbol) {
      break;
    }
    curLocation = range.location + range.length;

    NSObject *object = [aJSONObject jsonObjectFromLocation:curLocation
                                                  outRange:&range];
    curLocation = range.location + range.length;
    if (object) {
      [jsonDict setValue:object forKey:symbol];
    }
    
    curLocation++;
  }
  
  return jsonDict;
}

NSUInteger NextScanPoint(NSString *aJSONString, NSUInteger curIndex)
{
  // Scan until some ending chars are found.
  NSUInteger index = curIndex;
  while (index < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:index];
    switch (curChar) {
      case ',':
      case '}':
      case ']':
        return index;
    }
    index++;
  }
  return index;
}

NSArray*
GetJSONArray(NSString *aJSONString)
{
  NSMutableArray *array = [NSMutableArray array];
  NSUInteger curLocation = 0;
  NSUInteger arrayCount = [array count];
  while (curLocation < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:curLocation];
    switch (curChar) {
      // Strings
      case '\'':
        [array addObject:[aJSONString substringFromIndex:curLocation + 1
                                             toCharacter:'\'']];
        break;
      case '\"':
        [array addObject:[aJSONString substringFromIndex:curLocation + 1
                                             toCharacter:'\"']];
         break;
        
      case 't':
        [array addObject:[NSNumber numberWithBool:YES]];
        break;
      case 'f':
        [array addObject:[NSNumber numberWithBool:NO]];
        break;
        
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '.':
      {
        NSUInteger outLength;
        NSNumber *number = [aJSONString scanNumberFromIndex:curLocation
                                               numberLength:&outLength];
        [array addObject:number];
        break;
      }
    }

    ++curLocation;
    if (arrayCount != [array count]) {
      curLocation = NextScanPoint(aJSONString, curLocation);
      arrayCount = [array count];
    }
  }
  
  return array;
}

//------------------------------------------------------------------------------

@implementation NSString (MiscUtils)

- (NSString *)jsonSymbolFromLocation:(NSUInteger)aLocation
                            outRange:(NSRange *)aOutRange
{
  NSUInteger charIndex = aLocation;
  NSUInteger stringStart = aLocation;
  NSUInteger stringEnd = aLocation;
  BOOL doSearch = YES;
  BOOL foundStart = NO;
  while (charIndex < [self length] && doSearch) {
    unichar curChar = [self characterAtIndex:charIndex];
    switch (curChar) {
      case '{':
      case '}':
      case ' ':
      case ',':
        break;
        
      case ':':
        stringEnd = charIndex;
        doSearch = NO;
        break;
        
      default:
        if (!foundStart) {
          stringStart = charIndex;
          foundStart = YES;
        }
    }
    charIndex++;
  }
  
  if (foundStart) {
    *aOutRange = NSMakeRange(stringStart, stringEnd - stringStart);
    return [[self substringWithRange:*aOutRange] stringByTrimmingWhitespace];
  }
  
  return nil;
}

- (NSObject *)jsonObjectFromLocation:(NSUInteger)aLocation
                            outRange:(NSRange *)aOutRange
{
  NSUInteger charIndex = aLocation;
  BOOL doSearch = YES;
  while (charIndex < [self length] && doSearch) {
    unichar curChar = [self characterAtIndex:charIndex];
    switch (curChar) {
      // Booleans:
      case 't':
        doSearch = NO;
        *aOutRange =
          [self rangeOfString:@"true"
                      options:NSLiteralSearch
                        range:NSMakeRange(charIndex - 1, [self length] - charIndex)];
        return [NSNumber numberWithBool:YES];
        break;
      case 'f':
        doSearch = NO;
        *aOutRange =
          [self rangeOfString:@"false"
                      options:NSLiteralSearch
                        range:NSMakeRange(charIndex - 1, [self length] - charIndex)];
        return [NSNumber numberWithBool:NO];
        break;

      // Strings:
      case '\'':
      {
        NSRange startRange = [self rangeOfString:@"'"];
        NSRange backRange = [self rangeOfString:@"'"
                                              options:NSBackwardsSearch];
        *aOutRange = NSMakeRange(startRange.location + 1,
                                 backRange.location - startRange.location - 1);
        return [self substringWithRange:*aOutRange];
        break;
      }
      case '\"':
      {
        NSRange startRange = [self rangeOfString:@"\""];
        NSRange backRange = [self rangeOfString:@"\""
                                        options:NSBackwardsSearch];
        *aOutRange = NSMakeRange(startRange.location + 1,
                                 backRange.location - startRange.location - 1);
        return [self substringWithRange:*aOutRange];
        break;
      }

      // Null:
      case 'n':
        doSearch = NO;
        break;

      // Embedded object:
      case '{':
        doSearch = NO;
        NSString *jsonObject = GetNextJSONObjectString(self, charIndex);
        *aOutRange = [self rangeOfString:jsonObject];
        return GetJSONObjectDictionary(jsonObject);
        break;

      // Array:
      case '[':
        doSearch = NO;
        break;
        
      case ',':
      case '}':
        doSearch = NO;
        break;

      // Numbers:
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      {
        NSUInteger outLength;
        NSNumber *number = [self scanNumberFromIndex:charIndex 
                                        numberLength:&outLength];
        *aOutRange = NSMakeRange(charIndex, outLength);
        return number;
        break;
      }
    }
    
    charIndex++;
  }

  return nil;
}

- (NSString *)substringFromIndex:(NSUInteger)aStartIndex
                     toCharacter:(unichar)aStopChar
{
  NSUInteger index = aStartIndex;
  while (index < [self length]) {
    if ([self characterAtIndex:index] == aStopChar) {
      break;
    }
    index++;
  }
  return [self substringWithRange:NSMakeRange(aStartIndex, index - aStartIndex)];
}

- (NSNumber *)scanNumberFromIndex:(NSUInteger)aStartIndex
                     numberLength:(NSUInteger *)aOutLength
{
  NSMutableString *str = [NSMutableString string];
  BOOL doSearch = YES;
  NSUInteger index = aStartIndex;
  while (index < [self length] && doSearch) {
    unichar curChar = [self characterAtIndex:index];
    switch (curChar) {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '.':
        [str appendFormat:@"%c", curChar];
        break;
        
      default:
        doSearch = NO;
        break;
    }
    index++;
  }
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  return [nf numberFromString:str];
}

- (NSString *)stringByTrimmingWhitespace
{
  return [self stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceCharacterSet]];
}

@end
