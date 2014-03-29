//
//  MVViewController.m
//  GameOfLife
//
//  Created by Matthew Voss on 3/28/14.
//  Copyright (c) 2014 Matthew Voss. All rights reserved.
//

#import "MVViewController.h"
#import "Cell.h"

@interface MVViewController ()

@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger cellSize;
@property (nonatomic, strong)  NSTimer *lifeCheck;
@property (nonatomic, strong) UIView *pause;
@property (nonatomic, strong) NSMutableArray *copiedArray;


@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellSize = 20;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.pause = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height - 50, screenRect.size.width, 50)];
    self.pause.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.pause];
    
    self.numberOfColumns = (screenRect.size.width / self.cellSize);
    self.numberOfRows = ((screenRect.size.height - 50) / self.cellSize);
    
    
    NSMutableArray *rowArray = [NSMutableArray new];
    for (int row = 0; row < self.numberOfRows; row++) {
        NSMutableArray *columnArray = [NSMutableArray new];
        for (int column = 0; column < self.numberOfColumns; column++) {
            Cell *newCell = [[Cell alloc] initWithFrame:CGRectMake((column * self.cellSize), (row * self.cellSize), self.cellSize, self.cellSize)];
            newCell.layer.borderWidth = 1;
            newCell.layer.borderColor = [[UIColor darkGrayColor] CGColor];
            newCell.backgroundColor = [UIColor blackColor];
            [self.view addSubview:newCell];
            [columnArray addObject:newCell];
        }
        [rowArray addObject:columnArray];
    }
    self.cells = rowArray;
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setUpTimer
{
    self.lifeCheck = [NSTimer scheduledTimerWithTimeInterval:.5
                                                      target:self
                                                    selector:@selector(checkForLife)
                                                    userInfo:nil
                                                    repeats:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (CGRectContainsPoint(self.pause.frame, touchPoint)) {
            if ([self.lifeCheck isValid]) {
                [self.lifeCheck invalidate];
                self.pause.backgroundColor = [UIColor greenColor];;
            }else{
                [self setUpTimer];
                self.pause.backgroundColor = [UIColor redColor];
                }
        } else {
            for (Cell *cell in self.view.subviews) {
                if (CGRectContainsPoint(cell.frame, touchPoint)) {
                    if (cell.isAlive) {
                        cell.isAlive = false;
                        cell.backgroundColor = [UIColor blackColor];
                    } else {
                        cell.isAlive = true;
                        cell.backgroundColor = [UIColor blueColor];
                    }
                }
            }
        }
    }
}



- (void)checkForLife
{
    
    NSMutableArray *rowArray = [NSMutableArray new];
    for (int row = 0; row < _numberOfRows; row++) {
        NSMutableArray *columnArray = [NSMutableArray new];
        for (int column = 0; column < _numberOfColumns; column++) {
            int numberOfLiveNeighbors = 0;
            Cell *thisCell = [[Cell alloc] initWithFrame:CGRectMake((column * self.cellSize), (row * self.cellSize), self.cellSize, self.cellSize)];
            thisCell.layer.borderWidth = 1;
            thisCell.layer.borderColor = [[UIColor darkGrayColor] CGColor];
            thisCell.backgroundColor = [UIColor blackColor];
            

            if ((column > 0) && (row > 0) && (column < (_numberOfColumns - 2)) && (row < (_numberOfRows - 2))) {


                if ([self.cells[row - 1][column - 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row - 1][column] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row - 1][column + 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row][column - 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row][column + 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row + 1][column - 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row + 1][column] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                if ([self.cells[row + 1][column + 1] isAlive]) {
                    numberOfLiveNeighbors++;
                }
                
                switch (numberOfLiveNeighbors) {
                    case 2:
                        if ([_cells[row][column] isAlive]) {
                            thisCell.isAlive = true;
                        }
                        break;
                    case 3:
                        if (!thisCell.isAlive) {
                            thisCell.isAlive = true;
                        }
                        break;
                    default:
                        thisCell.isAlive = false;
                        break;
                }
                
                
            } else {
                thisCell.isAlive = false;
                thisCell.backgroundColor = [UIColor blackColor];
            }
            [columnArray addObject:thisCell];

        }
        [rowArray addObject:columnArray];
    }
    _cells = rowArray;
    [self updateCellView];

}

-(void)updateCellView
{
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    for (int row = 0; row < _numberOfRows; row++) {
        for (int column = 0; column < _numberOfColumns; column++) {
            Cell *livingCell = _cells[row][column];
            [self.view addSubview:livingCell];
            if (livingCell.isAlive) {
                livingCell.backgroundColor = [UIColor blueColor];
            } else {
                livingCell.backgroundColor = [UIColor blackColor];
            }
            _cells[row][column] = livingCell;
        }
    }
    [self.view addSubview:self.pause];

    
}



@end
