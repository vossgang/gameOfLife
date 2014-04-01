//
//  Cell.h
//  GameOfLife
//
//  Created by Matthew Voss on 3/28/14.
//  Copyright (c) 2014 Matthew Voss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : NSObject

@property (nonatomic) bool isAlive;
@property (nonatomic) bool shouldBeAlive;
@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic, strong) UIView *cellView;

@end
