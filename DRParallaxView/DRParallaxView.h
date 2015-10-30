//
//  DRParallaxView.h
//  DRParallaxViewDemo
//
//  Created by dimkahr on 10/30/15.
//  Copyright © 2015 Dmitriy Romanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRParallaxView : UIView

@property BOOL needHighlight;

- (void)setGyroMotion:(BOOL)bl;
- (void)setLayersWithImages:(NSArray *)names;

@end
