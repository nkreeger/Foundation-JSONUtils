#import <Foundation/Foundation.h>

#import "NSDictionary+JSONUtils.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  /*
   * TODO: Add some docs for each test.
   */
  
  // Test one
  NSString *jsonString = @"{ error: true, value: 'a value here' }";
  NSDictionary *jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 2);
  assert([[jsonDict valueForKey:@"error"] boolValue]);
  assert([[jsonDict valueForKey:@"value"] isEqualToString:@"a value here"]);
  
  // Test two
  jsonString = @" {foo:false,bar:\"this is a string\",asdf:1235} ";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 3);
  assert(![[jsonDict valueForKey:@"foo"] boolValue]);
  assert([[jsonDict valueForKey:@"bar"] isEqualToString:@"this is a string"]);
  assert([[jsonDict valueForKey:@"asdf"] intValue] == 1235);
  
  // Test three
  jsonString = @"{onekey:10}";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 1);
  assert([[jsonDict valueForKey:@"onekey"] intValue] == 10);
  
  // Test four - embedded JSON object
  jsonString = @"{ object: { foo: 'bar' } }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  NSLog(@"%@", jsonDict);
  NSDictionary *embeddedDict = [jsonDict valueForKey:@"object"];
  assert([jsonDict count] == 1);
  assert([embeddedDict isKindOfClass:[NSDictionary class]]);
  assert([embeddedDict count] == 1);
  assert([[embeddedDict valueForKey:@"foo"] isEqualToString:@"bar"]);

  
  NSLog(@"All Tests Passed");
  [pool drain];
  return 0;
}
