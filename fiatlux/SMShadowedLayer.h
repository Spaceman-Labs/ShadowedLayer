//
//  SMShadowedLayer.h
//  
//
//  Created by Joel Kraut on 3/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

// Note: subclasses that draw content must call [super display]
@interface SMShadowedLayer : CALayer

// not animating per frame will yield better performance; however, the shadow
// and highlight will not animate correctly in situations where they'd undergo
// a non-linear animation (e.g. rotating the layer from -M_PI to M_PI)
- (void)setTransform:(CATransform3D)transform animatePerFrame:(BOOL)internalAnimate;

@property (nonatomic, assign) BOOL showShadow;
@property (nonatomic, strong) UIColor *shadowingColor;
@property (nonatomic, assign) float currentShadowOpacity;

@property (nonatomic, assign) BOOL showHighlight;
@property (nonatomic, strong) UIColor *specularColor;
@property (nonatomic, assign) float specularFalloff;
@property (nonatomic, assign) float currentSpecularOpacity;

@end
