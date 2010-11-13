#import <Foundation/Foundation.h>

#import "NSDictionary+JSONUtils.h"
#import "NSArray+JSONUtils.h"


int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // JSON Object tests
  NSString *jsonString;
  NSDictionary *jsonDict;
  NSArray *jsonArray;

  jsonString = @"{ error: true, value: 'a value here' }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 2);
  assert([[jsonDict valueForKey:@"error"] boolValue]);
  assert([[jsonDict valueForKey:@"value"] isEqualToString:@"a value here"]);
  
  jsonString = @" {foo:false,bar:\"this is a string\",asdf:1235} ";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 3);
  assert(![[jsonDict valueForKey:@"foo"] boolValue]);
  assert([[jsonDict valueForKey:@"bar"] isEqualToString:@"this is a string"]);
  assert([[jsonDict valueForKey:@"asdf"] intValue] == 1235);
  
  jsonString = @"{onekey:10}";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 1);
  assert([[jsonDict valueForKey:@"onekey"] intValue] == 10);
  
  jsonString = @"{ object: { foo: 'bar' } }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  NSDictionary *embeddedDict = [jsonDict valueForKey:@"object"];
  assert([jsonDict count] == 1);
  assert([embeddedDict isKindOfClass:[NSDictionary class]]);
  assert([embeddedDict count] == 1);
  assert([[embeddedDict valueForKey:@"foo"] isEqualToString:@"bar"]);
  
  
  // JSON array tests
  jsonString = @"['one', 'two', \"three\"]";
  jsonArray = [NSArray arrayForJSON:jsonString];
  assert([jsonArray count] == 3);
  assert([[jsonArray objectAtIndex:0] isEqualToString:@"one"]);
  assert([[jsonArray objectAtIndex:1] isEqualToString:@"two"]);
  assert([[jsonArray objectAtIndex:2] isEqualToString:@"three"]);
  
  jsonString = @"[true, false]";
  jsonArray = [NSArray arrayForJSON:jsonString];
  assert([jsonArray count] == 2);
  assert([[jsonArray objectAtIndex:0] boolValue]);
  assert(![[jsonArray objectAtIndex:1] boolValue]);
  
  jsonString = @"[123, 321, 12.21]";
  jsonArray = [NSArray arrayForJSON:jsonString];
  assert([jsonArray count] == 3);
  assert([[jsonArray objectAtIndex:0] intValue] == 123);
  assert([[jsonArray objectAtIndex:1] intValue] == 321);
  assert([[jsonArray objectAtIndex:2] floatValue] == 12.21f);

  NSLog(@"All Tests Passed");
  [pool drain];
  return 0;
}
