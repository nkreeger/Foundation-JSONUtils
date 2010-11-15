//
//  Foundation+JSONUtils.h, version 0.5
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


@interface NSString (JSONUtils)

//
// @brief Return the JSON value of the string.
// @return This method will return one of the following options:
//         - A NSArray pointer if the data represents a JSON array.
//         - A NSDictionary pointer if the data represents a JSON object.
//         - Nil if the string doesn't represent a valid JSON structure.
//
- (NSObject *)JSONValue;

@end


@interface NSDictionary (JSONUtils)

//
// @brief Returns a dictionary full of the JSON values passed in via a string.
// @param aJSONString The JSON value to convert to a dictionary.
// @return A NSDictionary containing the key/value pairs from the JSON, or nil
//         if the JSON is invalid.
//
+ (NSDictionary *)dictionaryForJSON:(NSString *)aJSONString;

@end


@interface NSArray (JSONUtil)

//
// @brief Returns an array full of the JSON values passed in via a string.
// @param aJSONString The JSON string to parse.
// @return A NSArray containing an array of dictionaries of parsed JSON data.
//
+ (NSArray *)arrayForJSON:(NSString *)aJSONString;

@end
