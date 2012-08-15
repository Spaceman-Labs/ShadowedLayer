//
//  SMShadowedLayer.m
//  
//
//  Created by Joel Kraut on 3/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "SMShadowedLayer.h"

#import <UIKit/UIKit.h>

@interface SMShadowedLayer() {
	CALayer *shadowLayer;
	CALayer *specularLayer;
	BOOL parentIsTransformLayer;
}

@property (nonatomic, assign) float _animator;

- (void)respondToTransform:(CATransform3D)transform;

@end

@implementation SMShadowedLayer

@synthesize shadowingColor, showShadow,
			specularColor, specularFalloff, showHighlight;
@dynamic currentShadowOpacity,
		 currentSpecularOpacity;

@dynamic _animator;

#pragma mark - Life cycle

- (id)init
{
	if ((self = [super init]))
	{
		shadowLayer = [CALayer layer];
		shadowLayer.opacity = 0.f;
		[self addSublayer:shadowLayer];
		self.shadowingColor = [UIColor colorWithWhite:0.f alpha:.75f];
		
		specularLayer = [CALayer layer];
		specularLayer.opacity = 0.f;
		specularLayer.hidden = YES;
		[self addSublayer:specularLayer];
		self.specularColor = [UIColor colorWithWhite:1.f alpha:.9f];
		specularFalloff = 64.f;

		showShadow = YES;
		showHighlight = NO;
	}
	return self;
}


- (void)addSublayer:(CALayer *)layer
{
	[self insertSublayer:layer below:shadowLayer];
}

#pragma mark - Reasons to reconstruct the shadow layer's mask

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	shadowLayer.frame = bounds;
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.frame = bounds;
	specularLayer.mask = [self constructShadowMask];
}

- (void)setContents:(id)contents
{
	[super setContents:contents];
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.mask = [self constructShadowMask];
}

- (void)setContentsCenter:(CGRect)contentsCenter
{
	[super setContentsCenter:contentsCenter];
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.mask = [self constructShadowMask];
}

- (void)setContentsGravity:(NSString *)contentsGravity
{
	[super setContentsGravity:contentsGravity];
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.mask = [self constructShadowMask];
}

- (void)setContentsRect:(CGRect)contentsRect
{
	[super setContentsRect:contentsRect];
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.mask = [self constructShadowMask];
}

- (void)setContentsScale:(CGFloat)contentsScale
{
	[super setContentsScale:contentsScale];
	shadowLayer.mask = [self constructShadowMask];
	specularLayer.mask = [self constructShadowMask];
}

#pragma mark - Animation triggers

- (void)setTransform:(CATransform3D)transform
{
	[self setTransform:transform animatePerFrame:YES];
}

- (void)setTransform:(CATransform3D)transform animatePerFrame:(BOOL)internalAnimate
{
	[super setTransform:transform];
	if (internalAnimate)
		self._animator = self._animator ? 0.f : 1.f;
	[self respondToTransform:transform];
}

#pragma mark - Shadow and highlight configuration

- (void)setShowHighlight:(BOOL)show
{
	showHighlight = show;
	specularLayer.hidden = !showHighlight;
}

- (void)setSpecularColor:(UIColor *)color
{
	if ([color isEqual:specularColor])
		return;
	specularColor = color;
	specularLayer.backgroundColor = specularColor.CGColor;
}

- (float)currentSpecularOpacity
{
	return specularLayer.opacity;
}

- (void)setCurrentSpecularOpacity:(float)currentSpecularOpacity
{
	specularLayer.opacity = currentSpecularOpacity;
}

- (void)setShowShadow:(BOOL)show
{
	showShadow = show;
	shadowLayer.hidden = !showShadow;
}

- (void)setShadowingColor:(UIColor *)color
{
	if ([color isEqual:shadowingColor])
		return;
	shadowingColor = color;
	shadowLayer.backgroundColor = shadowingColor.CGColor;
}

- (float)currentShadowOpacity
{
	return shadowLayer.opacity;
}

- (void)setCurrentShadowOpacity:(float)currentShadowOpacity
{
	shadowLayer.opacity = currentShadowOpacity;
}

#pragma mark - Internal logic

- (void)display
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	[self respondToTransform:((CALayer*)self.presentationLayer).transform];
	[CATransaction commit];
}

- (void)respondToTransform:(CATransform3D)transform
{
	// add in the parent's transforms
	CALayer *superlayer = self.superlayer.presentationLayer;
	if (!superlayer)
		return;
	
	transform = CATransform3DConcat(superlayer.sublayerTransform, transform);
	if (parentIsTransformLayer)
		transform = CATransform3DConcat(superlayer.transform, transform);
	CATransform3D normal;
	memset(&normal, 0, sizeof(CATransform3D));
	normal.m31 = 1.f;
	// get the normal to the transformed surface
	CATransform3D newNormal = CATransform3DConcat(transform, normal);
	float magnitude = sqrtf(newNormal.m11 * newNormal.m11 + newNormal.m21 * newNormal.m21 + newNormal.m31 * newNormal.m31);
	// technically correct, but we don't use the results of these
	//newNormal.m11 /= magnitude;
	//newNormal.m21 /= magnitude;
	newNormal.m31 /= magnitude;
	float dotProduct = newNormal.m31;
	shadowLayer.opacity = fmaxf(0, fminf(1, (1.f - dotProduct)));
	specularLayer.opacity = fmaxf(0, fminf(1, powf(dotProduct, specularFalloff)));
}

- (CALayer*)constructShadowMask
{
	if (!self.contents)
		return nil;
	CALayer *mask = [CALayer layer];
	mask.frame = shadowLayer.bounds;
	mask.contents = self.contents;
	mask.contentsRect = self.contentsRect;
	mask.contentsCenter = self.contentsCenter;
	mask.contentsGravity = self.contentsGravity;
	mask.contentsScale = self.contentsScale;
	
	return mask;
}

- (id < CAAction >)actionForKey:(NSString *)key
{
	// if we're under a transform layer, we also need to account for its transform
	if ([key isEqualToString:@"onOrderIn"])
		parentIsTransformLayer = ([self.superlayer isKindOfClass:[CATransformLayer class]]);

	return [super actionForKey:key];
}

#pragma mark - Class Methods

+ (BOOL)needsDisplayForKey:(NSString *)key
{
	if ([key isEqualToString:@"_animator"])
		return YES;
	return [super needsDisplayForKey:key];
}

+ (id < CAAction >)defaultActionForKey:(NSString *)key
{
	if ([key isEqualToString:@"_animator"])
		return [CABasicAnimation animation];
	return [super defaultActionForKey:key];
}

@end
