//
//  MVViewController.m
//  GameOfLife
//
//  Created by Matthew Voss on 3/28/14.
//  Copyright (c) 2014 Matthew Voss. All rights reserved.
//

#import "MVViewController.h"
#import "Cell.h"

@interface MVViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) NSMutableArray *cellsToUpDate;
@property (nonatomic, strong) NSMutableArray *cellsToCheck;

@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger cellSize;
@property (nonatomic) NSInteger iteration;
@property (nonatomic) NSInteger numberOfLiveCells;

@property (nonatomic, strong) NSTimer *lifeCheck;
@property (nonatomic, strong) UIView  *pause;
@property (nonatomic, strong) UILabel *pauseLabel;
@property (nonatomic, strong) UILabel *clearLabel;

@property (nonatomic) CGPoint cellInArray;
@property (nonatomic) CGRect  screenRect;

@end

@implementation MVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.iteration = 0;
    
    _screenRect = [[UIScreen mainScreen] bounds];
    if (_screenRect.size.width > 400) {
        self.cellSize = 10;
    } else {
        self.cellSize = 6;
    }
    
    self.pause = [[UIView alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 50, _screenRect.size.width, 50)];
    self.pause.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.pause];
    
    self.pauseLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, _screenRect.size.height - 50, _screenRect.size.width - 30, 50)];
    self.pauseLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pauseLabel];
    
    self.clearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 50, 30, 50)];
    self.clearLabel.textAlignment = NSTextAlignmentCenter;
    self.clearLabel.text = @"X";
    [self.view addSubview:self.clearLabel];
    
    self.numberOfColumns = (_screenRect.size.width / self.cellSize);
    self.numberOfRows = ((_screenRect.size.height - 50) / self.cellSize);
    NSLog(@"%d cells", _numberOfColumns * _numberOfRows);
   	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableArray *check = [NSMutableArray new];
    
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
            [self.view addSubview:thisCell.cellView];
            [thisCell.cellView setHidden:YES];
            [columnArray addObject:thisCell];
        }
        [rowArray addObject:columnArray];
    }
    self.cells = rowArray;
    [check addObject:_cells[0][0]];
    _cellsToCheck = check;

    CGPoint here = CGPointMake(6, 20);

    
    [self putCeditsAt:here];
}

-(void)putCeditsAt:(CGPoint)here
{
 
    [self insertBatPoint:here];
    [self insertYatPoint:CGPointMake(here.x + 6, here.y)];
    
    [self insertCatPoint:CGPointMake(here.x, here.y + 7)];
    [self insertHatPoint:CGPointMake(here.x + 6, here.y + 7)];
    [self insertRatPoint:CGPointMake(here.x + 12, here.y + 7)];
    [self insertIatPoint:CGPointMake(here.x + 18, here.y + 7)];
    [self insertSatPoint:CGPointMake(here.x + 24, here.y + 7)];
    
    [self insertCatPoint:CGPointMake(here.x, here.y + 14)];
    [self insertOatPoint:CGPointMake(here.x + 6, here.y + 14)];
    [self insertHatPoint:CGPointMake(here.x + 12, here.y + 14)];
    [self insertEatPoint:CGPointMake(here.x + 18, here.y + 14)];
    [self insertNatPoint:CGPointMake(here.x + 24, here.y + 14)];
    
    [self insertAatPoint:CGPointMake(here.x + 6, here.y + 21)];
    [self insertNatPoint:CGPointMake(here.x + 12, here.y + 21)];
    [self insertDatPoint:CGPointMake(here.x + 18, here.y + 21)];
    
    [self insertMatPoint:CGPointMake(here.x + 6, here.y + 28)];
    [self insertAatPoint:CGPointMake(here.x + 12, here.y + 28)];
    [self insertTatPoint:CGPointMake(here.x + 18, here.y + 28)];
    [self insertTatPoint:CGPointMake(here.x + 24, here.y + 28)];
    
    [self insertVatPoint:CGPointMake(here.x + 6, here.y + 35)];
    [self insertOatPoint:CGPointMake(here.x + 12, here.y + 35)];
    [self insertSatPoint:CGPointMake(here.x + 18, here.y + 35)];
    [self insertSatPoint:CGPointMake(here.x + 24, here.y + 35)];
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
        
        if (CGRectContainsPoint(self.clearLabel.frame, touchPoint)) {
            if ([self.lifeCheck isValid]) {
                [self.lifeCheck invalidate];
                self.pause.backgroundColor = [UIColor greenColor];;
                _iteration = 0;
                _pauseLabel.text = @" ";
            }
            [self removeAllLivingCells];
        } else if (CGRectContainsPoint(self.pause.frame, touchPoint)) {
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
            
            _cellInArray.x = touchPoint.x / _cellSize;
            _cellInArray.y = touchPoint.y / _cellSize;

            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Insert This"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Glider Gun", @"Turn On Cell", @"Hypno Pattern",@"Credits", nil];
            //make this the middle of the screen
            
            CGRect middle = CGRectMake((_screenRect.size.height - 300), 0, 10, 10);

            if (_screenRect.size.width > 320) {
                middle.origin.x = touchPoint.x;
                middle.origin.y = touchPoint.y;
            }
        
            [actionSheet showFromRect:middle inView:self.view animated:YES];
            
        }
    }
}

-(void)turnCellOnAt:(CGPoint)point
{
    int row = point.y;
    int col = point.x;
    if ((row < self.numberOfRows)&&(col < self.numberOfColumns)) {
        Cell *cell = _cells[row][col];
        if (cell.isAlive) {
            cell.isAlive = false;
            [cell.cellView setHidden:YES];
        } else {
            cell.isAlive = true;
            [self checkCellsthatSurrond:cell];
            [cell.cellView setHidden:NO];
        }
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Glider Gun"]) {
        [self insertGliderGunAtPoint:_cellInArray];
    } else if ([buttonTitle isEqualToString:@"Turn On Cell"]){
        [self turnCellOnAt:_cellInArray];
    } else if ([buttonTitle isEqualToString:@"Hypno Pattern"]){
        [self putColumnGoingUpAt:_cellInArray columnLength:1];
    } else if ([buttonTitle isEqualToString:@"Credits"]){
        [self putCeditsAt:_cellInArray];
    }
}

-(void)removeAllLivingCells
{
    for (int row = 0; row < _numberOfRows; row++) {
        for (int col = 0; col < _numberOfColumns; col++) {
            Cell *thisCell = _cells[row][col];
            thisCell.isAlive = false;
            thisCell.shouldBeAlive = false;
            [thisCell.cellView setHidden:YES];
            [_cellsToCheck removeObject:thisCell];
            [_cellsToUpDate removeObject:thisCell];
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
    _iteration++;
    
    [_cellsToCheck removeAllObjects];
    
    for (Cell *upDatedCell in _cellsToUpDate) {
        if (upDatedCell.shouldBeAlive) {
            [self checkCellsthatSurrond:upDatedCell];
            upDatedCell.isAlive = true;
            
            if ([upDatedCell.cellView isHidden]) {
                [upDatedCell.cellView setHidden:NO];
            }
            
        } else {
            [upDatedCell.cellView setHidden:YES];
            upDatedCell.isAlive = false;
        }
    }
    self.pauseLabel.text = [NSString stringWithFormat:@"Gen %ld Live %ld Check %lu", (long)_iteration, (long)_numberOfLiveCells, (unsigned long)_cellsToCheck.count];

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

//
// the following code is just preset shapes
// that can put put into the array at
// a row and column in the array with
// row = y and col = x
//


-(void)putColumnGoingUpAt:(CGPoint)point
             columnLength:(int)numberOfCells
{
    int col = point.x;
    int row = point.y;
    int cellCounter = 0;
    Cell *thisCell = [Cell new];
    
    while ((cellCounter < numberOfCells) &&  (row > 0)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        [thisCell.cellView setHidden:NO];
        [self checkCellsthatSurrond:thisCell];
        cellCounter++;
        row--;
    }
    if (row > 0) {
        point.y = row;
        [self putRowGoingLeftAt:point rowLength:numberOfCells+1];
    }
}

-(void)putRowGoingLeftAt:(CGPoint)point
               rowLength:(int)numberOfCells
{
    int col = point.x;
    int row = point.y;
    int cellCounter = 0;
    Cell *thisCell = [Cell new];
    
    while ((cellCounter < numberOfCells) &&  (col > 0)) {
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        [thisCell.cellView setHidden:NO];
        [self checkCellsthatSurrond:thisCell];
        cellCounter++;
        col--;
    }
    if (col > 0) {
        point.x = col;
        [self putColumnGoingDownAt:point columnLength:numberOfCells+1];
    }
}

-(void)putColumnGoingDownAt:(CGPoint)point
             columnLength:(int)numberOfCells
{
    int col = point.x;
    int row = point.y;
    int cellCounter = 0;
    Cell *thisCell = [Cell new];
    
    while ((cellCounter < numberOfCells) &&  (row < (_numberOfRows - 1))) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        [thisCell.cellView setHidden:NO];
        [self checkCellsthatSurrond:thisCell];
        cellCounter++;
        row++;
    }
    if (row < (_numberOfRows - 1)) {
        point.y = row;
        [self putRowGoingRightAt:point rowLength:numberOfCells+1];
    }
}

-(void)putRowGoingRightAt:(CGPoint)point
               rowLength:(int)numberOfCells
{
    int col = point.x;
    int row = point.y;
    int cellCounter = 0;
    Cell *thisCell = [Cell new];
    
    while ((cellCounter < numberOfCells) &&  (col < (_numberOfColumns - 1))) {
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        [thisCell.cellView setHidden:NO];
        [self checkCellsthatSurrond:thisCell];
        cellCounter++;
        col++;
    }
    if (col < (_numberOfColumns - 1)) {
        point.x = col;
        [self putColumnGoingUpAt:point columnLength:numberOfCells+1];
    }
}

-(void)insertGliderGunAtPoint:(CGPoint)point
{
    int row = point.y;
    int col = point.x;
    
    Cell *thisCell = [Cell new];
    
  if ((row < _numberOfRows - 11) && (col < _numberOfColumns - 38)) {
    
    thisCell = _cells[row][col + 24];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 1][col + 22];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 1][col + 24];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 12];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 13];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 20];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 21];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 34];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 2][col + 35];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 3][col + 11];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 3][col + 15];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 3][col + 20];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 3][col + 21];
    thisCell.isAlive = true;

    thisCell = _cells[row + 3][col + 34];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 3][col + 35];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col + 1];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col + 10];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col + 16];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col + 20];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 4][col + 21];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col];
    thisCell.isAlive = true;

    thisCell = _cells[row + 5][col + 1];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 10];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 14];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 16];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 17];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 22];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 5][col + 24];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 6][col + 10];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 6][col + 16];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 6][col + 24];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 7][col + 11];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 7][col + 15];
    thisCell.isAlive = true;
 
    thisCell = _cells[row + 8][col + 12];
    thisCell.isAlive = true;
    
    thisCell = _cells[row + 8][col + 13];
    thisCell.isAlive = true;

    for (int r = -1; r < 11; r++) {
        for (int c = -1; c < 38; c++) {
            Cell *checkCell = _cells[row + r][col + c];
            [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
            [_cellsToCheck addObject:_cells[row + r][col + c]];
            if (checkCell.isAlive) {
                [checkCell.cellView setHidden:NO];
            }
        }
    }
  }
    
}

-(void)insertAatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;

    Cell *thisCell = [Cell new];

    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 3];
        thisCell.isAlive = true;
 
        thisCell = _cells[row + 1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 1][col + 4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col + 2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col + 3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col + 4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 3][col + 4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 4][col + 4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertBatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {

        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
    
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertCatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
 
        thisCell = _cells[row][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 4][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 4][col + 2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row +4][col + 3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 4][col + 4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertDatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;

        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;

        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertEatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertFatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertGatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col + 1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertHatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
    
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertIatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 1][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertJatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertKatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertLatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];

                }
            }
        }
    }
}

-(void)insertMatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertNatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertOatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertPatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertQatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertRatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;

        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertSatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertTatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertUatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;

        thisCell = _cells[row + 1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertVatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row + 1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertWatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col];
        thisCell.isAlive = true;

        thisCell = _cells[row+3][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertXatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertYatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

-(void)insertZatPoint:(CGPoint)here
{
    int row = here.y;
    int col = here.x;
    
    Cell *thisCell = [Cell new];
    if ((row < _numberOfRows - 6) && (col < _numberOfColumns - 6)) {
        
        thisCell = _cells[row][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row][col+4];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+1][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+2][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+3][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+1];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+2];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+3];
        thisCell.isAlive = true;
        
        thisCell = _cells[row+4][col+4];
        thisCell.isAlive = true;
        
        for (int r = -1; r < 6; r++) {
            for (int c = -1; c < 6; c++) {
                Cell *checkCell = _cells[row + r][col + c];
                [_cellsToCheck removeObjectIdenticalTo:_cells[row + r][col + c]];
                [_cellsToCheck addObject:_cells[row + r][col + c]];
                if (checkCell.isAlive) {
                    [checkCell.cellView setHidden:NO];
                }
            }
        }
    }
}

@end