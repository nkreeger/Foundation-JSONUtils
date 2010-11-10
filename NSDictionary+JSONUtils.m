//==============================================================================
//
//  NSDictionary+JSONUtils.m
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import "NSDictionary+JSONUtils.h"

#define DEBUG_MSG 1


@interface NSDictionary (JSONUtils_Private)

+ (void)_parseJSONObject:(NSString *)aJSONObject;
+ (NSObject *)_objectForJSONValue:(NSString *)aJSONValue;

@end

//------------------------------------------------------------------------------

@implementation NSDictionary (JSONUtils)

+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString
{
  // Find all the opening and closing curly braces.
  NSMutableArray *openingBracesArray = [NSMutableArray array];
  NSMutableArray *closingBracesArray = [NSMutableArray array];
  
  // NOTE: Not ideal, maybe AppKit has a API for doing this kind of thing.
  for (unsigned int i = 0; i < [aJSONString length]; i++) {
    char curChar = [aJSONString characterAtIndex:i];
    switch (curChar) {
      case '{':
        [openingBracesArray addObject:[NSNumber numberWithInt:i]];
        break;
      case '}':
        [closingBracesArray addObject:[NSNumber numberWithInt:i]];
        break;
    }
  }
#if DEBUG_MSG
  NSLog(@"---- BRACES:");
  NSLog(@"----   opening: %i", [openingBracesArray count]);
  NSLog(@"----   closing: %i", [closingBracesArray count]);
#endif
  
  // Ensure that there is at least one layer.
  if ([openingBracesArray count] == 0) {
    NSLog(@"Invalid JSON string: %@", aJSONString);
    return nil;
  }
  // Ensure that there is an matching amount of curly pairs.
  if ([openingBracesArray count] != [closingBracesArray count]) {
    NSLog(@"Malformed JSON string: %@", aJSONString);
    return nil;
  }
  
  // Append the first 'layer' at least for now...
  for (unsigned int i = 0; i < [openingBracesArray count]; i++) {
    unsigned int openingIndex = [[openingBracesArray objectAtIndex:i] intValue];
    unsigned int closingIndex = [[closingBracesArray objectAtIndex:i] intValue];
    NSRange strRange = NSMakeRange(openingIndex,
                                   closingIndex - openingIndex + 1);
    [self _parseJSONObject:[aJSONString substringWithRange:strRange]];
  }

  return nil;
}

+ (void)_parseJSONObject:(NSString *)aJSONObject
{
  // TODO: Strip out all the braces to make this a bit easier (right?).
  // TODO: Work until all the ':' characters have been found.
  NSLog(@"JSONOBJECT: %@", aJSONObject);
  NSRange range = [aJSONObject rangeOfString:@":"];
  if (range.location != NSNotFound) {
    // Find the start of the symbol.
    unsigned int symStart = range.location;
    while (symStart > 0) {
      if ([aJSONObject characterAtIndex:symStart] == ' ' ||
          [aJSONObject characterAtIndex:symStart] == '{')
      {
        break;
      }
      symStart--;
    }
    
    // Find the value portion.
    unsigned int valueStart = range.location + 1;
    unsigned int valueEnd = valueStart;
    while (valueEnd < [aJSONObject length]) {
      if ([aJSONObject characterAtIndex:valueEnd] == ',' ||
          [aJSONObject characterAtIndex:valueEnd] == '}')
      {
        break;
      }
      valueEnd++;
    }
    
    
    NSRange symRange = NSMakeRange(symStart, range.location - symStart);
    NSString *symbol = [aJSONObject substringWithRange:symRange];
    NSLog(@"SYMBOL: %@", symbol);
    
    NSRange valueRange = NSMakeRange(valueStart, valueEnd - valueStart);
    NSString *value = [aJSONObject substringWithRange:valueRange];
    NSLog(@"VALUE: %@", value);
    [self _objectForJSONValue:value];
  }
  
  // Try to parse a symbol...
}

+ (NSObject *)_objectForJSONValue:(NSString *)aJSONValue
{
  NSObject *value = nil;
  // Assume what the value might be by peaking at the string.
  NSString *jsonValue = [aJSONValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  unichar firstChar = [jsonValue characterAtIndex:0];
  switch (firstChar) {
    case '\'':
    case '\"':
      // TODO: Strip out the quotes
      NSLog(@" --> json value is a STRING");
      break;
      
    case 't':
      value = [NSNumber numberWithBool:YES];
      break;
    case 'f':
      value = [NSNumber numberWithBool:NO];
      break;
      
    // * Number case
    // * JSON bracket case
    // * [] bracket case?
  }

  return value;
}

@end
