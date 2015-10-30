//
//  DRParallaxView.m
//  DRParallaxViewDemo
//
//  Created by dimkahr on 10/30/15.
//  Copyright © 2015 Dmitriy Romanov. All rights reserved.
//

#define iff 0.9 // Internal views Frame Factor
#define hff 2.5 // Highlight view Frame Factor


#import <CoreMotion/CoreMotion.h>
#import "DRParallaxView.h"

@implementation DRParallaxView{
    
    CMMotionManager *motionManager;
    
    CGPoint point1;
    CGPoint point2;
    
    UIImageView *highlightIV;
    
    float currentHf;
    float currentVf;
    
    BOOL enableMotion;
    
}

- (void)makeup{
    
    self.clipsToBounds = true;
    self.backgroundColor = [UIColor clearColor];
    
    _needHighlight = true;
    
    enableMotion = true;
    
    point1 = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
}

- (void)setLayersWithImages:(NSArray *)names{
    [self makeup];
    
    int tag = 0;
    
    CGRect lRect = [self setScaleFactor:iff inRect:self.bounds];
    
    for (NSString *imageName in names) {
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:lRect];
            imageView.layer.allowsEdgeAntialiasing = true;
            imageView.layer.cornerRadius = 10.;
            imageView.clipsToBounds = true;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = tag++;
            
            [imageView setImage:image];
            
            [self addSubview:imageView];
            
        }
        
    }
    
    [self addHighlight];
    
}

- (void)addHighlight{
    highlightIV = [[UIImageView alloc] initWithFrame:[self setScaleFactor:hff inRect:self.bounds]];
    
    highlightIV.contentMode = UIViewContentModeScaleAspectFit;
    highlightIV.tag = self.subviews.count+50;
    highlightIV.alpha = 0;
    [highlightIV setImage:[UIImage imageNamed:@"ImageHighlight"]];
    
    [self addSubview:highlightIV];
}


#pragma mark transformation

- (void)setScaleForFirstPoint:(CGPoint)p1 secodPoint:(CGPoint)p2 animated:(BOOL)animated{
    
//    NSLog(@"p1 - %@", NSStringFromCGPoint(p1));
//    NSLog(@"p2 - %@", NSStringFromCGPoint(p2));
    
    float hMove = (p2.x - p1.x)/(self.bounds.size.width * 100);
    float vMove = (p2.y - p1.y)/(self.bounds.size.height * -100);
    
    [self setHorisontalFactor:hMove verticalFactor:vMove animated:animated];
}

- (void)setHorisontalFactor:(float)hf verticalFactor:(float)vf animated:(BOOL)animated{
    
    //NSLog(@"setH - %f, setV - %f", hf, vf);
    
    if (animated) {
        DRParallaxView * __weak weakSelf = self;
        [UIView animateWithDuration:.2 animations:^{
            [weakSelf setHorisontalFactor:hf verticalFactor:vf];
        }];
    } else {
        [self setHorisontalFactor:hf verticalFactor:vf];
    }
    
}

- (void)setHorisontalFactor:(float)hf verticalFactor:(float)vf{
    
    if (ABS(hf) < (self.bounds.size.width*0.00001)) {
        currentHf = hf;
    } else {
        currentHf = self.bounds.size.width*0.00001 * ((hf<0)?-1:1);
    }
    
    if (ABS(vf) < (self.bounds.size.height*0.00001)) {
        currentVf = vf;
    } else {
        currentVf = self.bounds.size.height*0.00001 * ((vf<0)?-1:1);
    }
    
    for (UIView *v in self.subviews) {
        
        NSInteger tag = v.tag;
        
        float moveHValue = tag * currentHf * 600;
        float rotateHValue =  currentHf * 15;
        
        float moveVValue = (tag * -1) * currentVf * 600;
        float rotateVValue =  currentVf * 15;
        
        
        CATransform3D t = CATransform3DIdentity;
        t = CATransform3DMakeTranslation(moveHValue, moveVValue, 0);
        t.m34 = -5.0/500.0;
        
        t = CATransform3DRotate(t, rotateHValue, 0, 1, 0);
        t = CATransform3DRotate(t, rotateVValue, 1, 0, 0);
        v.layer.transform = t;
        
    }
}


#pragma mark touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    enableMotion = false;
    
    UITouch *touch=[touches anyObject];
    CGPoint p0 = [touch locationInView:self];
    
    if (_needHighlight) {
        [UIView animateWithDuration:.1 animations:^{
            highlightIV.alpha = .4;
        }];
    }
    
    [self setScaleForFirstPoint:point1 secodPoint:p0 animated:false];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    point2 = [touch locationInView:self];
    
    [self setScaleForFirstPoint:point1 secodPoint:point2 animated:false];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    enableMotion = true;
    
    if (_needHighlight) {
        [UIView animateWithDuration:.1 animations:^{
            highlightIV.alpha = 0;
        }];
    }
    
    [self setHorisontalFactor:0 verticalFactor:0 animated:true];
}


#pragma mark motion

- (void)setGyroMotion:(BOOL)bl{
    
    motionManager = [[CMMotionManager alloc] init];
    
    if([motionManager isGyroAvailable]) {
        
        if (bl) {
            
            if([motionManager isGyroActive] == NO) {
                
                [motionManager setGyroUpdateInterval:0.01];
                
                DRParallaxView * __weak weakSelf = self;
                
                [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                   withHandler:^(CMDeviceMotion *data, NSError *error) {
                                                       
                                                       
                                                       if (enableMotion) {
                                                           float xRR = data.gravity.x * 0.01;
                                                           float yRR = data.gravity.y * 0.01;
                                                           
                                                           [weakSelf setHorisontalFactor:xRR verticalFactor:yRR];
                                                       }
                                                       
                                                   }];
            }
            
        } else {
            [motionManager stopGyroUpdates];
        }
        
    } else {
        NSLog(@"Gyroscope not Available!");
    }
    
}


#pragma mark helpers

- (CGRect)setScaleFactor:(float)sf inRect:(CGRect)rect{
    return CGRectMake((rect.size.width - (rect.size.width*sf))/2,
                      (rect.size.height - (rect.size.height*sf))/2,
                      rect.size.width*sf,
                      rect.size.height*sf);
}

@end
