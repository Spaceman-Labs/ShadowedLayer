//
//  SMTransformLayer.h
//  fiatlux
//
//  Created by Joel Kraut on 3/20/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

//  This class exists only to be aware of SM layers that care about transforms.
//  If you're not using SMShadowedLayer, you don't need this.

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <QuartzCore/QuartzCore.h>

@interface SMTransformLayer : CATransformLayer

@end
