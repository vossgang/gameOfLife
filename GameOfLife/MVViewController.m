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



@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellSize = 10;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.numberOfColumns = (screenRect.size.width / self.cellSize);
    self.numberOfRows = (screenRect.size.height / self.cellSize);
    
    
    NSMutableArray *rowArray = [NSMutableArray new];
    for (int row = 0; row < self.numberOfRows; row++) {
        NSMutableArray *columnArray = [NSMutableArray new];
        for (int column = 0; column < self.numberOfColumns; column++) {
            Cell *newCell = [[Cell alloc] initWithFrame:CGRectMake((column * self.cellSize), (row * self.cellSize), self.cellSize, self.cellSize)];
            newCell.layer.borderWidth = 1;
            newCell.layer.borderColor = [[UIColor grayColor] CGColor];
            newCell.backgroundColor = [UIColor blackColor];
            [self.view addSubview:newCell];
            [columnArray addObject:newCell];
            
            if (!(arc4random() % 8)) {
                newCell.isAlive = true;
                newCell.backgroundColor = [UIColor blueColor];
            }
            
        }
        [rowArray addObject:columnArray];
    }
    self.cells = rowArray;
    
    [self setUpTimer];
    
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



- (void)checkForLife
{
    
    for (int row = 0; row < _numberOfRows - 1; row++) {
        for (int column = 0; column < _numberOfColumns; column++) {
            int numberOfLiveNeighbors = 0;
            Cell *thisCell = self.cells[row][column];

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
                if ([self.cells[row][column - 1] isAlive]) {
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
            }
            _cells[row][column] = thisCell;

        }
    }
    [self updateCellView];

}

-(void)updateCellView
{
    for (int row = 0; row < _numberOfRows; row++) {
        for (int column = 0; column < _numberOfColumns; column++) {
            Cell *livingCell = _cells[row][column];
            if (livingCell.isAlive) {
                livingCell.backgroundColor = [UIColor blueColor];
            } else {
                livingCell.backgroundColor = [UIColor blackColor];
            }
            _cells[row][column] = livingCell;
        }
    }
    
    
}

@end
