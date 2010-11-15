//
//  Foundation+JSONUtils.m
//
//  Copyright (c) 2010, Nick Kreeger <nick.kreeger@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Foundation+JSONUtils.h"


//------------------------------------------------------------------------------

@interface NSString (MiscUtils)

- (NSString *)stringByTrimmingWhitespace;
- (NSString *)substringFromIndex:(NSUInteger)aStartIndex
                     toCharacter:(unichar)aStopChar;
- (NSString *)reverseJSONKeyFromIndex:(NSUInteger)aStartIndex;
- (NSNumber *)scanNumberFromIndex:(NSUInteger)aStartIndex;
- (NSUInteger)closingBracket:(unichar)aBracketChar
                   fromIndex:(NSUInteger)aStartIndex;
- (NSObject *)jsonObjectFromIndex:(NSUInteger)aStartIndex
                       skipArrays:(BOOL)aSkipArrays
                   outSearchIndex:(NSUInteger *)aOutSearchIndex;

@end

//------------------------------------------------------------------------------
// TODO Clean up these methods, roll them into NSString.

NSArray* GetJSONArray(NSString *aJSONString);
NSDictionary* GetJSONDictionary(NSString *aJSONString);

//------------------------------------------------------------------------------

NSUInteger
NextScanPoint(NSString *aJSONString, NSUInteger curIndex)
{
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
  NSUInteger curLocation = NextScanPoint(aJSONString, 0);
  while (curLocation < [aJSONString length]) {
    NSUInteger newLocation = 0;
    NSObject *value = [aJSONString jsonObjectFromIndex:curLocation
                                            skipArrays:YES
                                        outSearchIndex:&newLocation];
    if (value) {
      [array addObject:value];
      curLocation = newLocation;
    }
    else {
      ++curLocation;
    }
  }
  return array;
}

NSDictionary*
GetJSONDictionary(NSString *aJSONString)
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSUInteger curLocation = NextScanPoint(aJSONString, 0);
  while (curLocation < [aJSONString length]) {
    unichar curChar = [aJSONString characterAtIndex:curLocation];
    switch (curChar) {
      case ':':
      {
        NSString *key = [aJSONString reverseJSONKeyFromIndex:curLocation];
        if (!key) {
          break;
        }
        NSUInteger newLocation = 0;
        NSObject *value = [aJSONString jsonObjectFromIndex:curLocation
                                                skipArrays:NO
                                            outSearchIndex:&newLocation];
        if (!value) {
          break;
        }

        [dict setValue:value forKey:key];
        curLocation = newLocation;        
        break;
      }
    }
    ++curLocation;
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

- (NSString *)reverseJSONKeyFromIndex:(NSUInteger)aStartIndex
{
  // Go backwards to find the key's value that is wrapped in quotes.
  NSUInteger index = aStartIndex;
  NSUInteger closingQuoteIndex = 0;
  NSUInteger openingQuoteIndex = 0;
  BOOL foundClosingQuotes = NO;
  BOOL foundOpeningQuotes = NO;
  while (index > 0) {
    if ([self characterAtIndex:index] == '\"') {
      if (!foundClosingQuotes) {
        closingQuoteIndex = index;
        foundClosingQuotes = YES;
      }
      else {
        openingQuoteIndex = index;
        foundOpeningQuotes = YES;
        break;
      }
    }
    --index;
  }
  if (foundOpeningQuotes && foundClosingQuotes) {
    NSRange range = NSMakeRange(openingQuoteIndex + 1,
                                closingQuoteIndex - openingQuoteIndex - 1);
    return [self substringWithRange:range];
  }
  return nil;
}

- (NSNumber *)scanNumberFromIndex:(NSUInteger)aStartIndex
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

- (NSUInteger)closingBracket:(unichar)aBracketChar
                   fromIndex:(NSUInteger)aStartIndex
{
  NSUInteger index = aStartIndex;
  while (index < [self length]) {
    // For now assume that any closing bracket is OK. (Fix me later)
    // XXXkreeger: Use this method stub for now. Down the road I'm going to
    // want to add some support for figuring out if a bracket is in a string.
    if ([self characterAtIndex:index] == aBracketChar) {
      return index;
    }
    ++index;
  }
  return NSNotFound;
}

- (NSObject *)jsonObjectFromIndex:(NSUInteger)aStartIndex
                       skipArrays:(BOOL)aSkipArrays
                   outSearchIndex:(NSUInteger *)aOutSearchIndex
{
  // NOTE: Most of these methods can be converted to categories of NSString right?
  NSUInteger index = aStartIndex;
  while (index < [self length]) {
    unichar curChar = [self characterAtIndex:index];
    switch (curChar) {
      case '\'':
        *aOutSearchIndex = NextScanPoint(self, index);
        return [self substringFromIndex:index + 1 toCharacter:'\''];
        
      case '\"':
        *aOutSearchIndex = NextScanPoint(self, index);
        return [self substringFromIndex:index + 1 toCharacter:'\"'];
        
      case 't':
        *aOutSearchIndex = NextScanPoint(self, index);
        return [NSNumber numberWithBool:YES];
        
      case 'f':
        *aOutSearchIndex = NextScanPoint(self, index);
        return [NSNumber numberWithBool:NO];
        
      case '{':
        *aOutSearchIndex = [self closingBracket:'}' fromIndex:index];
        return GetJSONDictionary([self substringFromIndex:index]);
        
      case '[':
        if (!aSkipArrays) {
          *aOutSearchIndex = [self closingBracket:']' fromIndex:index];
          return GetJSONArray([self substringFromIndex:index]);
        }
        
      case 'n':
        // Null objects aren't super useful, just return out of this method.
        return nil;
        
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
        *aOutSearchIndex = NextScanPoint(self, index);
        return [self scanNumberFromIndex:index];
    }
    ++index;
  }
  return nil;
}

- (NSString *)stringByTrimmingWhitespace
{
  return [self stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceCharacterSet]];
}

@end

//------------------------------------------------------------------------------

@implementation NSString (JSONUtils)

- (NSObject *)jsonValue
{
  for (NSUInteger i = 0; i < [self length]; ++i) {
    unichar curChar = [self characterAtIndex:i];
    switch (curChar) {
      case '[':
        return [NSArray arrayForJSON:self];
        break;
      case '{':
        return [NSDictionary dictionaryForJSON:self];
        break;
    }
  }
  return nil;
}

@end

//------------------------------------------------------------------------------
  
@implementation NSDictionary (JSONUtils)

+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString
{
  return GetJSONDictionary(aJSONString);
}

@end

//------------------------------------------------------------------------------

@implementation NSArray (JSONUtil)

+ (NSArray *)arrayForJSON:(NSString *)aJSONString
{
  return GetJSONArray(aJSONString);
}

@end
