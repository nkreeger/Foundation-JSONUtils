#import <Foundation/Foundation.h>

#import "NSDictionary+JSONUtils.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // insert code here...
  NSString *jsonString = @"{ error: true, value: 'a value here' }";
  NSDictionary *jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([[jsonDict valueForKey:@"error"] boolValue]);
  assert([[jsonDict valueForKey:@"value"] isEqualToString:@"a value here"]);
  
  jsonString = @" {foo:false,bar:\"this is a string\",asdf:1235} ";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert(![[jsonDict valueForKey:@"foo"] boolValue]);
  assert([[jsonDict valueForKey:@"bar"] isEqualToString:@"this is a string"]);
  assert([[jsonDict valueForKey:@"asdf"] intValue] == 1235);
  
  NSLog(@"All Tests Passed");
  [pool drain];
  return 0;
}
