//
//  JSONUtils.m
//  NSDictionary+JSONUtils
//
//  Created by Nick Kreeger on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSONUtils.h"


EJSONBlockType
PeakNextJSONBlockType(NSString *aJSONString, unsigned int aStartPosition)
{
  for (unsigned int i = aStartPosition; i < [aJSONString length]; ++i) {
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

//------------------------------------------------------------------------------

@implementation NSString (MiscUtils)

- (NSString *)stringByTrimmingWhitespace
{
  return [self stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceCharacterSet]];
}

@end
