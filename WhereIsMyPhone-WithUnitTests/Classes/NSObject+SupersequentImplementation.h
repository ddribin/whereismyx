//
//  NSObjectSupersequentImplementation.h
//  SupersequentImplementation
//
//  Created by Matt Gallagher on 9/11/07.
//  Copyright 2007 OnceBuilt. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

@interface NSObject (SupersequentImplementation)

- (IMP)getImplementationOf:(SEL)lookup after:(IMP)imp;

@end

IMP impOfCallingMethod(id lookupObject, SEL selector);

#define invokeSupersequent(args...) \
	([self getImplementationOf:_cmd \
		after:impOfCallingMethod(self, _cmd)]) \
			(self, _cmd, ##args)

#define invokeSupersequentNoArgs() \
	([self getImplementationOf:_cmd \
		after:impOfCallingMethod(self, _cmd)]) \
			(self, _cmd)
