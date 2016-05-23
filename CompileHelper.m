//
//  CompileHelper.m
//  Popcorn
//
//  Created by Timothy Goodson on 5/23/16.
//  Copyright © 2016 TK-Squared, LLC. All rights reserved.
//

#import "CompileHelper.h"

@implementation CompileHelper

NSString* compileDate() {
    return [NSString stringWithUTF8String:__DATE__];
}

NSString* compileTime() {
    return [NSString stringWithUTF8String:__TIME__];
}

@end
