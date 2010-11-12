//==============================================================================
//
//  NSDictionary+JSONUtils.m
//  @author Nick Kreeger <nick.kreeger@rd.io>
//
//==============================================================================

#import "NSDictionary+JSONUtils.h"

#import "JSONUtils.h"


//------------------------------------------------------------------------------
// REMOVE ME METHODS
@interface NSDictionary (JSONUtils_Private)

+ (NSDictionary *)dictionaryForJSONOld:(NSString *)aJSONObject;
+ (NSDictionary *)_parseJSONObject:(NSString *)aJSONObject;
+ (NSObject *)_objectForJSONValue:(NSString *)aJSONValue;

@end

//------------------------------------------------------------------------------
// JSONUtils category implementation for JSON.

@implementation NSDictionary (JSONUtils)

+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString
{
  // Dictionary assumes that the JSON value will be 
  return nil;
}


// -----> OLD STUFF:
+ (NSDictionary *)dictionaryForJSONOld:(NSString *)aJSONString
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
  NSDictionary *jsonDict = nil;

  for (unsigned int i = 0; i < [openingBracesArray count]; i++) {
    unsigned int openingIndex = [[openingBracesArray objectAtIndex:i] intValue];
    unsigned int closingIndex = [[closingBracesArray objectAtIndex:i] intValue];
    NSRange strRange = NSMakeRange(openingIndex,
                                   closingIndex - openingIndex + 1);
    
    if ([openingBracesArray count] == 1) {
      jsonDict = [self _parseJSONObject:[aJSONString substringWithRange:strRange]];
    }
    else {
      // hack, fix me later.
    }
  }

  return jsonDict;
}

+ (NSDictionary *)_parseJSONObject:(NSString *)aJSONObject
{
  NSDictionary *dict = [NSMutableDictionary dictionary];

  // TODO: Strip out all the braces to make this a bit easier (right?).
  // TODO: Work until all the ':' characters have been found.
  NSRange range = [aJSONObject rangeOfString:@":"];
  while (range.location != NSNotFound) {
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
    NSString *symbol =
      [[aJSONObject substringWithRange:symRange] stringByTrimmingWhitespace];
    
    NSRange valueRange = NSMakeRange(valueStart, valueEnd - valueStart);
    NSString *jsonvalue = [aJSONObject substringWithRange:valueRange];
    NSObject *value = [self _objectForJSONValue:jsonvalue];
    
    [dict setValue:value forKey:symbol];

    range = [aJSONObject rangeOfString:@":"
                               options:NSLiteralSearch
                                 range:NSMakeRange(range.location + 1,
                                                   [aJSONObject length] - range.location - 1)];
  }
  
  return dict;
}

+ (NSObject *)_objectForJSONValue:(NSString *)aJSONValue
{
  NSObject *value = nil;
  // Assume what the value might be by peaking at the string.
  NSString *jsonValue = [aJSONValue stringByTrimmingWhitespace];
  unichar firstChar = [jsonValue characterAtIndex:0];
  switch (firstChar) {
    case '\'':
    {
      NSRange startRange = [aJSONValue rangeOfString:@"'"];
      NSRange backRange = [aJSONValue rangeOfString:@"'"
                                            options:NSBackwardsSearch];
      NSRange strRange = NSMakeRange(startRange.location + 1,
                                     backRange.location - startRange.location -1);
      value = [aJSONValue substringWithRange:strRange];
      break;
    }
    case '\"':
      // TODO: Strip out the quotes
      break;
      
    case 't':
      value = [NSNumber numberWithBool:YES];
      break;
    case 'n':
      // Nil will fall through
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
