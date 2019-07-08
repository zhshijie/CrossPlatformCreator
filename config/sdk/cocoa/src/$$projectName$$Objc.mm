#import "HelloObjc.h"
#include "../../src/header/$$projectName$$.h"


@interface $$projectName$$Objc ()

@end

@implementation $$projectName$$Objc

- (void)hello {
    hello();
}

@end

#pragma mark - link cocoa

void loadOption() {}

void loadCocoaService()
{
    loadOption();
}
