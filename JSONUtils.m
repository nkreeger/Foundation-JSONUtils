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


NSUInteger NextScanPoint(NSString *aJSONString, NSUInteger curIndex)
{
  // Scan until some ending chars are found.
  NSUInteger index = curIndex;
  while (index < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:index];
    switch (curChar) {
      case ',':
      case '{':
      case '}':
      case '[':
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

NSDictionary*
GetJSONDictionary(NSString *aJSONString)
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSUInteger curLocation = NextScanPoint(aJSONString, 0);
  NSUInteger dictCount = [dict count];

  while (curLocation < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:curLocation];
    switch (curChar) {
      case ':':
      {
        NSString *key = [aJSONString reverseSubstringFromIndex:curLocation
                                                   toCharacter:' '];
        NSObject *value = nil;
        NSUInteger valueLocation = curLocation + 1;
        while (valueLocation < [aJSONString length]) {
          unichar curChar = [aJSONString characterAtIndex:valueLocation];
          switch (curChar) {
            case '\'':
              value = [aJSONString substringFromIndex:valueLocation + 1
                                          toCharacter:'\''];
              break;
            case '\"':
              value = [aJSONString substringFromIndex:valueLocation + 1
                                          toCharacter:'\"'];
              break;
              
            case 't':
              value = [NSNumber numberWithBool:YES];
              break;
            case 'f':
              value = [NSNumber numberWithBool:NO];
              break;
              
            case '{':
              value = GetJSONDictionary([aJSONString substringFromIndex:valueLocation]);
              // Need to do this in other places too.
              curLocation += NextScanPoint(aJSONString, valueLocation);
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
              value = [aJSONString scanNumberFromIndex:valueLocation
                                          numberLength:&outLength];
              break;
            }
          }
          
          ++valueLocation;
          if (value) {
            break;
          }
        }
        
        if (value) {
          [dict setValue:value forKey:key];
        }
        
        break;
      }
    }
    
    ++curLocation;
    if (dictCount != [dict count]) {
//      curLocation = NextScanPoint(aJSONString, curLocation);
//      dictCount = [dict count];
    }
  }

  return dict;
}

//------------------------------------------------------------------------------

@implementation NSString (MiscUtils)

- (NSString *)substringFromIndex:(NSUInteger)aStartIndex
                     toCharacter:(unichar)aStopChar
{
  NSUInteger index = aStartIndex;
  while (index < [self length]) {
    if ([self characterAtIndex:index] == aStopChar) {
      break;
    }
    ++index;
  }
  return [self substringWithRange:NSMakeRange(aStartIndex, index - aStartIndex)];
}

- (NSString *)reverseSubstringFromIndex:(NSUInteger)aStartIndex
                            toCharacter:(unichar)aStopChar
{
  //
  // XXXkreeger HACK HACK HACK, update the API to reflect these changes or
  //  something soon!
  //
  NSUInteger index = aStartIndex;
  while (index > 0) {
    if ([self characterAtIndex:index] == aStopChar ||
        [self characterAtIndex:index] == '{' ||
        [self characterAtIndex:index] == ',')
    {
      break;
    }
    --index;
  }
  return [self substringWithRange:NSMakeRange(index + 1, aStartIndex - index - 1)];
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
