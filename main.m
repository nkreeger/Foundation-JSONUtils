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

#import <Foundation/Foundation.h>
#import "Foundation+JSONUtils.h"

/*
 NOTE: This method exists for some basic API unit tests of the JSON methods
       that are added to the Foundation library. Feel free to update the tests
       if any bugs surface during use of this API.
*/

int main (int argc, const char * argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  // JSON Object tests
  NSString *jsonString;
  NSDictionary *jsonDict;
  NSDictionary *embeddedDict;
  NSArray *jsonArray;

  jsonString = @"{ \"error\": true, \"value\": 'a value here' }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 2);
  assert([[jsonDict valueForKey:@"error"] boolValue]);
  assert([[jsonDict valueForKey:@"value"] isEqualToString:@"a value here"]);
  
  jsonString = @" {\"foo\":false,\"bar\":\"this is a string\",\"asdf\":1235} ";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 3);
  assert(![[jsonDict valueForKey:@"foo"] boolValue]);
  assert([[jsonDict valueForKey:@"bar"] isEqualToString:@"this is a string"]);
  assert([[jsonDict valueForKey:@"asdf"] intValue] == 1235);
  
  jsonString = @"{\"onekey\":10}";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 1);
  assert([[jsonDict valueForKey:@"onekey"] intValue] == 10);
  
  jsonString = @"{ \"object\": { \"foo\": 'bar' } }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  embeddedDict = [jsonDict valueForKey:@"object"];
  assert([jsonDict count] == 1);
  assert([embeddedDict isKindOfClass:[NSDictionary class]]);
  assert([embeddedDict count] == 1);
  assert([[embeddedDict valueForKey:@"foo"] isEqualToString:@"bar"]);
  
  jsonString = @"{ \"weirdstring\" : \"{asdf}\", \"success\" : true }";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 2);
  assert([[jsonDict valueForKey:@"weirdstring"] isEqualToString:@"{asdf}"]);
  assert([[jsonDict valueForKey:@"success"] boolValue]);
  
  jsonString = @"{\"success\":true,\"user\":{\"name\":\"Nick\",\"id\":1}}";
  jsonDict = [NSDictionary dictionaryForJSON:jsonString];
  assert([jsonDict count] == 2);
  assert([[jsonDict valueForKey:@"success"] boolValue]);
  embeddedDict = [jsonDict valueForKey:@"user"];
  assert([embeddedDict count] == 2);
  assert([[embeddedDict valueForKey:@"name"] isEqualToString:@"Nick"]);
  assert([[embeddedDict valueForKey:@"id"] intValue] == 1);
  
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
  
  jsonString = @"[{\"foo\" : true}, {\"rab\" : false}]";
  jsonArray = [NSArray arrayForJSON:jsonString];
  assert([jsonArray count] == 2);
  assert([[jsonArray objectAtIndex:0] count] == 1);
  assert([[jsonArray objectAtIndex:1] count] == 1);
  assert([[[jsonArray objectAtIndex:0] valueForKey:@"foo"] boolValue]);
  assert(![[[jsonArray objectAtIndex:1] valueForKey:@"rab"] boolValue]);

  // Foundation -> JSON Tests
  NSMutableDictionary *body = [NSMutableDictionary dictionaryWithObject:[NSDate date]
                                                                 forKey:@"date"];
  NSMutableArray *changes = [NSMutableArray array];
  NSMutableDictionary *object = [NSMutableDictionary dictionary];
  [object setObject:@"D159517B-CA22-408D-957B-1504F9CC97D5" forKey:@"id"];
  [object setObject:@"Hello World" forKey:@"title"];
  [object setObject:[NSNumber numberWithInt:1] forKey:@"status"];
  NSMutableDictionary *change = [NSMutableDictionary dictionary];
  [change setObject:object forKey:@"object"];
  [changes addObject:change];
  object = [NSMutableDictionary dictionary];
  [object setObject:@"BC7F984C-6F74-42B8-8DC1-1C7EDEB94234" forKey:@"id"];
  [object setObject:@"Hello Again" forKey:@"title"];
  [object setObject:[NSNumber numberWithInt:3] forKey:@"status"];
  change = [NSMutableDictionary dictionary];
  [change setObject:object forKey:@"object"];
  [changes addObject:change];
  [body setObject:changes forKey:@"changes"];
  NSString *expected = @"{\"date\":\"2011-01-24 19:08:00 -0800\",\"changes\": [{\"object\": {\"id\":\"D159517B-CA22-408D-957B-1504F9CC97D5\",\"title\":\"Hello World\",\"status\":1}},{\"object\": {\"id\":\"BC7F984C-6F74-42B8-8DC1-1C7EDEB94234\",\"title\":\"Hello Again\",\"status\":3}}]}";
  assert(![expected isEqualToString:[NSString JSONFromDictionary:body]]);


  NSLog(@"All Tests Passed");
  [pool drain];
  return 0;
}
