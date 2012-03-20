//
//  SMShadowedTransformLayer.m
//  fiatlux
//
//  Created by Joel Kraut on 3/20/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "SMShadowedTransformLayer.h"
#import "SMShadowedLayer.h"

@interface SMShadowedTransformLayer ()
@property (nonatomic, readonly) NSMutableSet *shadowedLayers;
- (void)trackPotentialShadowedLayer:(CALayer*)layer;
- (void)checkSublayersForShadows;
@end

@implementation SMShadowedTransformLayer
@synthesize shadowedLayers;

- (void)dealloc
{
	[shadowedLayers release];
	[super dealloc];
}

#pragma mark - inform shadowed layer sublayers of our transforms

- (void)setTransform:(CATransform3D)transform
{
	[super setTransform:transform];
	for (SMShadowedLayer *layer in shadowedLayers)
		[layer setTransform:layer.transform animatePerFrame:YES];
}

- (void)setSublayerTransform:(CATransform3D)sublayerTransform
{
	[super setSublayerTransform:sublayerTransform];
	for (SMShadowedLayer *layer in shadowedLayers)
		[layer setTransform:layer.transform animatePerFrame:YES];
}

#pragma mark - keep track of shadowed layer sublayers

- (void)trackPotentialShadowedLayer:(CALayer*)layer
{
	if ([layer isKindOfClass:[SMShadowedLayer class]])
		[self.shadowedLayers addObject:layer];
}

- (void)checkSublayersForShadows
{
	for (CALayer *layer in self.sublayers)
		[self trackPotentialShadowedLayer:layer];
	[shadowedLayers intersectSet:[NSSet setWithArray:self.sublayers]];
}

- (id < CAAction >)actionForKey:(NSString *)key
{
	// pay attention to when our sublayers change
	if ([key isEqualToString:@"sublayers"])
		[self performSelector:@selector(checkSublayersForShadows) withObject:nil afterDelay:0.f];

	return [super actionForKey:key];
}

#pragma mark - Property accessors

- (NSMutableSet*)shadowedLayers
{
	if (shadowedLayers)
		return shadowedLayers;
	shadowedLayers = [[NSMutableSet alloc] initWithCapacity:5];
	return shadowedLayers;
}

@end
