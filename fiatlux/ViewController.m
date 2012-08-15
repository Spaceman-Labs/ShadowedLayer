//
//  ViewController.m
//  fiatlux
//
//  Created by Joel Kraut on 3/14/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "ViewController.h"
#import "SMShadowedLayer.h"
#import "SMTransformLayer.h"

@interface ViewController ()
{
	SMShadowedLayer *layer;
	SMTransformLayer *transformLayer;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	CATransform3D perspective = CATransform3DIdentity;
	perspective.m34 = -1.f/1000.f;
	self.view.layer.sublayerTransform = perspective;
	self.view.backgroundColor = [UIColor grayColor];
	
	transformLayer = [SMTransformLayer layer];
	[self.view.layer addSublayer:transformLayer];
	
	layer = [SMShadowedLayer layer];
	layer.showHighlight = YES;
	[transformLayer addSublayer:layer];
	
	UIImage *image = [UIImage imageNamed:@"logo_periwinkle"];
	layer.contents = (id)image.CGImage;
	
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.view addGestureRecognizer:pan];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	[self.view addGestureRecognizer:tap];
}

- (void)pan:(UIPanGestureRecognizer*)pan
{
	CGPoint location = [pan locationInView:self.view];
	CGSize viewSize = self.view.bounds.size;
	location = CGPointMake((location.x - viewSize.width / 2) / viewSize.width,
						   (location.y - viewSize.height / 2) / viewSize.height);
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * location.x, 0, 1, 0), -M_PI * location.y, 1, 0, 0);
	// if I weren't using SMShadowedTransformLayer, here I would simply do:
	// [layer setTransform:layer.transform animatePerFrame:YES];
	[CATransaction commit];
}

- (void)tap:(UITapGestureRecognizer*)tap
{
	CGPoint location = [tap locationInView:self.view];
	CGSize viewSize = self.view.bounds.size;
	location = CGPointMake((location.x - viewSize.width / 2) / viewSize.width,
						   (location.y - viewSize.height / 2) / viewSize.height);
	[CATransaction begin];
	[CATransaction setAnimationDuration:1.f];
	transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI * location.x, 0, 1, 0), -M_PI * location.y, 1, 0, 0);
	// if I weren't using SMShadowedTransformLayer, here I would simply do:
	// [layer setTransform:layer.transform animatePerFrame:YES];
	[CATransaction commit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLayoutSubviews
{
	CGSize viewSize = self.view.bounds.size;
	layer.frame = CGRectMake(viewSize.width/2 - 150, viewSize.height/2 - 150, 300, 300);
	transformLayer.frame = self.view.bounds;
}

@end
