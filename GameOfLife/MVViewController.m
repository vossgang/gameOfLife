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
@property (nonatomic, strong) NSMutableArray *cellsToUpDate;
@property (nonatomic, strong) NSMutableArray *cellsToCheck;

@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger cellSize;
@property (nonatomic) NSInteger iteration;
@property (nonatomic) NSInteger numberOfLiveCells;

@property (nonatomic, strong) NSTimer *lifeCheck;
@property (nonatomic, strong) UIView *pause;
@property (nonatomic, strong) UILabel *pauseLabel;


@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *check = [NSMutableArray new];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.iteration = 0;
    self.cellSize = 8;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.pause = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height - 50, screenRect.size.width, 50)];
    self.pause.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.pause];
    self.pauseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screenRect.size.height - 50, screenRect.size.width, 50)];
    self.pauseLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pauseLabel];
    
    self.numberOfColumns = (screenRect.size.width / self.cellSize);
    self.numberOfRows = ((screenRect.size.height - 50) / self.cellSize);
    NSLog(@"%d", _numberOfColumns * _numberOfRows);
    NSMutableArray *rowArray = [NSMutableArray new];
    for (int row = 0; row < self.numberOfRows; row++) {
        NSMutableArray *columnArray = [NSMutableArray new];
        for (int column = 0; column < self.numberOfColumns; column++) {
            Cell *thisCell = [Cell new];
            thisCell.cellView = [[UIView alloc] initWithFrame:CGRectMake((column * self.cellSize), (row * self.cellSize), self.cellSize, self.cellSize)];
            thisCell.cellView.layer.cornerRadius = (_cellSize / 2.5);
            thisCell.cellView.layer.masksToBounds = YES;
            thisCell.row = row;
            thisCell.column = column;
            thisCell.cellView.backgroundColor = [UIColor blueColor];
            [columnArray addObject:thisCell];
        }
        [rowArray addObject:columnArray];
    }
    self.cells = rowArray;
    [check addObject:_cells[0][0]];
    _cellsToCheck = check;
    
    
    CGPoint here = CGPointMake(1, 20);
    [self insertGliderGunAtPoint:here];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setUpTimer
{
    self.lifeCheck = [NSTimer scheduledTimerWithTimeInterval:.25
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
                _iteration = 0;
                _pauseLabel.text = @" ";
            }else{
                [self setUpTimer];
                self.pause.backgroundColor = [UIColor redColor];
                }
        } else {
            int row = (touchPoint.y / _cellSize);
            int col = (touchPoint.x / _cellSize);
            
            Cell *cell = _cells[row][col];
            
                if (cell.isAlive) {
                    cell.isAlive = false;
                    [cell.cellView removeFromSuperview];
                } else {
                    [self insertGliderGunAtPoint:CGPointMake(cell.column, cell.row)];
                }
            }
        
        }
    
}



- (void)checkForLife
{
    _numberOfLiveCells = 0;
    
    NSLog(@"%lu cells to check", (unsigned long)_cellsToCheck.count);
    
    NSMutableArray *updatedCells = [NSMutableArray new];
    for (Cell *cellToCheck in _cellsToCheck) {
        int row = cellToCheck.row;
        int column = cellToCheck.column;
        
            int numberOfLiveNeighbors = 0;
            Cell *thisCell = _cells[row][column];
        
        
            if ((column > 0) && (row > 0) && (column < (_numberOfColumns - 2)) && (row < (_numberOfRows - 2))) {

                numberOfLiveNeighbors  = [self.cells[row - 1][column - 1] isAlive] +
                                         [self.cells[row - 1][column] isAlive] +
                                         [self.cells[row - 1][column + 1] isAlive] +
                                         [self.cells[row][column - 1] isAlive] +
                                         [self.cells[row][column + 1] isAlive] +
                                         [self.cells[row + 1][column - 1] isAlive] +
                                         [self.cells[row + 1][column] isAlive] +
                                         [self.cells[row + 1][column + 1] isAlive];

                switch (numberOfLiveNeighbors) {
                    case 2:
                        if ([_cells[row][column] isAlive]) {
                            thisCell.shouldBeAlive = true;
                            [updatedCells addObject:thisCell];
                        }
                        break;
                    case 3:
                        thisCell.shouldBeAlive = true;
                        [updatedCells addObject:thisCell];
                        break;
                    default:
                        thisCell.shouldBeAlive = false;
                        break;
                }
                if (thisCell.isAlive) {
                    _numberOfLiveCells++;
                }

            } else {
                thisCell.shouldBeAlive = false;
            }
            if (thisCell.shouldBeAlive != thisCell.isAlive) {
                [updatedCells removeObjectIdenticalTo:thisCell];
                [updatedCells addObject:thisCell];
            }
        }
    _cellsToUpDate = updatedCells;
    
    [self updateCellView];

}

-(void)updateCellView
{
    self.iteration++;
    
    [_cellsToCheck removeAllObjects];
    
    for (Cell *upDatedCell in _cellsToUpDate) {
        if (upDatedCell.shouldBeAlive) {
            [self checkCellsthatSurrond:upDatedCell];
            upDatedCell.isAlive = true;
            [upDatedCell.cellView removeFromSuperview];
            [self.view addSubview:upDatedCell.cellView];
        } else {
            [upDatedCell.cellView removeFromSuperview];
            upDatedCell.isAlive = false;
        }
    }
    self.pauseLabel.text = [NSString stringWithFormat:@"Iteration %ld Living %ld Checking %lu", (long)_iteration, (long)_numberOfLiveCells, (unsigned long)_cellsToCheck.count];

}


-(void)checkCellsthatSurrond:(Cell *)thisCell
{
    int row = thisCell.row;
    int col = thisCell.column;
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row-1][col-1]];
    [_cellsToCheck addObject:_cells[row-1][col-1]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row-1][col]];
    [_cellsToCheck addObject:_cells[row-1][col]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row-1][col+1]];
    [_cellsToCheck addObject:_cells[row-1][col+1]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row][col-1]];
    [_cellsToCheck addObject:_cells[row][col-1]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row][col]];
    [_cellsToCheck addObject:_cells[row][col]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row][col+1]];
    [_cellsToCheck addObject:_cells[row][col+1]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row+1][col-1]];
    [_cellsToCheck addObject:_cells[row+1][col-1]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row+1][col]];
    [_cellsToCheck addObject:_cells[row+1][col]];
    
    [_cellsToCheck removeObjectIdenticalTo:_cells[row+1][col+1]];
    [_cellsToCheck addObject:_cells[row+1][col+1]];

}

-(void)insertGliderGunAtPoint:(CGPoint)point
{
    int row = point.y;
    int col = point.x;
    
    Cell *thisCell = [Cell new];
    
  if ((row < _numberOfRows - 11) && (col < _numberOfColumns - 38)) {
    
    thisCell = _cells[row][col + 24];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 1][col + 22];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 1][col + 24];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 12];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 13];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 20];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 21];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 34];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 2][col + 35];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 3][col + 11];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 3][col + 15];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 3][col + 20];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 3][col + 21];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];

    thisCell = _cells[row + 3][col + 34];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 3][col + 35];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col + 1];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col + 10];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col + 16];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col + 20];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 4][col + 21];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];

    thisCell = _cells[row + 5][col + 1];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 10];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 14];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 16];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 17];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 22];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 5][col + 24];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 6][col + 10];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 6][col + 16];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 6][col + 24];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 7][col + 11];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 7][col + 15];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
 
    thisCell = _cells[row + 8][col + 12];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];
    
    thisCell = _cells[row + 8][col + 13];
    thisCell.isAlive = true;
      [self checkCellsthatSurrond:thisCell];

  }
    
}



@end
