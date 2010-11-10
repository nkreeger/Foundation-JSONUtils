#import <Foundation/Foundation.h>

#import "NSDictionary+JSONUtils.h"

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // insert code here...
  NSString *jsonString = @"{ error: true, value: 'a value here' }";
  NSDictionary *jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  NSLog(@"jsonValue: %@", jsonDict);
  
  [pool drain];
  return 0;
}
