//
//  Game.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import "Game.h"

#define SCORES_INDEX 0
#define POSITIONS_INDEX 1

@interface Game ()
@property (nonatomic, assign) NSInteger depth;
@end

@implementation Game

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return nil;
    }

//    _currentGameState = GameState_XTurn;

    _board = [self resetBoard];
    _depth = 0;

    return self;
}

- (BOOL)isBoardEmpty
{
    for (int i = 0; i < self.board.count - 1; i++) {
        if (![[self.board objectAtIndex:i] isEqualToNumber:[self.board lastObject]]) {
            return false;
        }
    }
    return true;
}

- (BOOL)isBoardFilled
{
    if ([self.board containsObject:@(GameMark_None)]) {
        return false;
    }

    return true;
}

- (NSArray *)getAvailableMovesForBoard:(NSArray *)board
{
    NSMutableArray *tempArray = [NSMutableArray new];
    [board enumerateObjectsUsingBlock:^(NSNumber *position, NSUInteger idx, BOOL *stop) {
        if ([position isEqualToNumber:@(GameMark_None)]) {
            [tempArray addObject:@(idx)];
        }
    }];

    return tempArray;
}

- (NSMutableArray *)resetBoard
{
    NSMutableArray *tempBoard = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        tempBoard[i] = @(GameMark_None);
    }

    self.currentGameState = GameState_XTurn;

    return tempBoard;
}

- (void)pressedSquare:(NSInteger)index
{
    if (![self.board[index] isEqual: @(GameMark_None)]) {
        return;
    }

    if (self.currentGameState == GameState_XTurn) {
        self.board[index] = @(GameMark_X);
        [self.delegate squareMarked:GameMark_X atPosition:index];
        self.currentGameState = GameState_OTurn;
        [self checkForGameOver];

        [self computerMakesMove];
    } else if (self.currentGameState == GameState_OTurn) {
        self.board[index] = @(GameMark_O);
        [self.delegate squareMarked:GameMark_O atPosition:index];
        self.currentGameState = GameState_XTurn;
        [self checkForGameOver];
    }
}

- (NSInteger)computerMakesMove
{
#warning lame to return 0 up top and at the bottom of this method
    if (self.currentGameState != GameState_OTurn) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:self.board];
    NSMutableArray *scoresAndMoves = [NSMutableArray new];
    NSMutableArray *scores = [NSMutableArray new];
    NSMutableArray *moves = [NSMutableArray new];

    for (NSNumber *move in availableMoves) {

        NSMutableArray *clonedBoard = [self.board mutableCopy];
        clonedBoard[[move integerValue]] = @(GameMark_O);
        NSInteger currentScore = [self min:clonedBoard];
        [scores addObject:[NSNumber numberWithInteger:currentScore]];
        [moves addObject:move];
        self.depth = 0;
    }

    scoresAndMoves[0] = scores;
    scoresAndMoves[1] = moves;

    NSInteger bestMove = [self determineBestMove:scoresAndMoves];
    [self pressedSquare:bestMove];

    return 0;
}

#warning need to clean up and be more clear about moves vs. positions (determineBestMove, scoresAndPositions, etc.)

- (NSInteger)determineBestMove:(NSMutableArray *)scoresAndMoves
{
    NSInteger bestIndex = 0;
    NSInteger bestScore = NSIntegerMin;

    for (NSInteger idx = 0; idx < ((NSMutableArray *)scoresAndMoves[SCORES_INDEX]).count; idx++) {
        NSInteger integerScore = [scoresAndMoves[SCORES_INDEX][idx] integerValue];
        if (integerScore > bestScore) {
            bestScore = integerScore;
            bestIndex = idx;
        }
    }

    return [scoresAndMoves[POSITIONS_INDEX][bestIndex] integerValue];
}

- (NSInteger)miniMax:(NSMutableArray *)board
{
    self.depth += 1;

    NSArray *xWinMarks;
    NSArray *oWinMarks;

    if (!xWinMarks) {
        xWinMarks = @[ @(GameMark_X), @(GameMark_X), @(GameMark_X)];
    }

    if (!oWinMarks) {
        oWinMarks = @[ @(GameMark_O), @(GameMark_O), @(GameMark_O)];
    }

    NSMutableArray *possibleWins = [NSMutableArray new];

    // row wins
    [possibleWins addObject:@[ @(0), @(1), @(2) ]];
    [possibleWins addObject:@[ @(3), @(4), @(5) ]];
    [possibleWins addObject:@[ @(6), @(7), @(8) ]];

    // column wins
    [possibleWins addObject:@[ @(0), @(3), @(6) ]];
    [possibleWins addObject:@[ @(1), @(4), @(7) ]];
    [possibleWins addObject:@[ @(2), @(5), @(8) ]];

    // diagonal wins
    [possibleWins addObject:@[ @(0), @(4), @(8) ]];
    [possibleWins addObject:@[ @(2), @(4), @(6) ]];

    for (NSArray *possibleWin in possibleWins) {
        if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:oWinMarks]) {
            return 10;
        } else if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:xWinMarks]) {
            return -10;
        }
    }

    if (![board containsObject:@(GameMark_None)]) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
    NSInteger bestScore = self.currentGameState == GameState_XTurn ? NSIntegerMax : NSIntegerMin;

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [board mutableCopy];

        if (self.currentGameState == GameState_XTurn) {
            clonedBoard[[move integerValue]] = @(GameMark_X);
            NSInteger currentScore = [self miniMax:clonedBoard];
            if (currentScore < bestScore) {
                bestScore = currentScore;
            }
        } else if (self.currentGameState == GameState_OTurn) {
            clonedBoard[[move integerValue]] = @(GameMark_O);
            NSInteger currentScore = [self miniMax:clonedBoard];
            if (currentScore > bestScore) {
                bestScore = currentScore;
            }
        }
    }

    return bestScore;
}

- (NSInteger)min:(NSMutableArray *)board
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.depth += 1;

    NSArray *xWinMarks;
    NSArray *oWinMarks;

    if (!xWinMarks) {
        xWinMarks = @[ @(GameMark_X), @(GameMark_X), @(GameMark_X)];
    }

    if (!oWinMarks) {
        oWinMarks = @[ @(GameMark_O), @(GameMark_O), @(GameMark_O)];
    }

    NSMutableArray *possibleWins = [NSMutableArray new];

    // row wins
    [possibleWins addObject:@[ @(0), @(1), @(2) ]];
    [possibleWins addObject:@[ @(3), @(4), @(5) ]];
    [possibleWins addObject:@[ @(6), @(7), @(8) ]];

    // column wins
    [possibleWins addObject:@[ @(0), @(3), @(6) ]];
    [possibleWins addObject:@[ @(1), @(4), @(7) ]];
    [possibleWins addObject:@[ @(2), @(5), @(8) ]];

    // diagonal wins
    [possibleWins addObject:@[ @(0), @(4), @(8) ]];
    [possibleWins addObject:@[ @(2), @(4), @(6) ]];

    for (NSArray *possibleWin in possibleWins) {
        if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:oWinMarks]) {
            return 10;
        } else if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:xWinMarks]) {
            return -10;
        }
    }

    if (![board containsObject:@(GameMark_None)]) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
    NSInteger bestScore = NSIntegerMax;

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [board mutableCopy];
        clonedBoard[[move integerValue]] = @(GameMark_X);
        NSInteger currentScore = [self max:clonedBoard];

        if (currentScore < bestScore) {
            bestScore = currentScore;
        }
    }

    return bestScore;
}

- (NSInteger)max:(NSMutableArray *)board
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.depth += 1;

    NSArray *xWinMarks;
    NSArray *oWinMarks;

    if (!xWinMarks) {
        xWinMarks = @[ @(GameMark_X), @(GameMark_X), @(GameMark_X)];
    }

    if (!oWinMarks) {
        oWinMarks = @[ @(GameMark_O), @(GameMark_O), @(GameMark_O)];
    }

    NSMutableArray *possibleWins = [NSMutableArray new];

    // row wins
    [possibleWins addObject:@[ @(0), @(1), @(2) ]];
    [possibleWins addObject:@[ @(3), @(4), @(5) ]];
    [possibleWins addObject:@[ @(6), @(7), @(8) ]];

    // column wins
    [possibleWins addObject:@[ @(0), @(3), @(6) ]];
    [possibleWins addObject:@[ @(1), @(4), @(7) ]];
    [possibleWins addObject:@[ @(2), @(5), @(8) ]];

    // diagonal wins
    [possibleWins addObject:@[ @(0), @(4), @(8) ]];
    [possibleWins addObject:@[ @(2), @(4), @(6) ]];

    for (NSArray *possibleWin in possibleWins) {
        if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:oWinMarks]) {
            return 10;
        } else if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:xWinMarks]) {
            return -10;
        }
    }

    if (![board containsObject:@(GameMark_None)]) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
    NSInteger bestScore = NSIntegerMin;

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [board mutableCopy];
        clonedBoard[[move integerValue]] = @(GameMark_O);
        NSInteger currentScore = [self min:clonedBoard];
        if (currentScore > bestScore) {
            bestScore = currentScore;
        }
    }

    return bestScore;
}

- (void)checkForGameOver
{
    if ([self isBoardFilled]) {
        self.currentGameState = GameState_Tie;
    }

#warning turn these back to static after refactoring
//    static NSArray *xWinMarks;
//    static NSArray *oWinMarks;
    NSArray *xWinMarks;
    NSArray *oWinMarks;

    if (!xWinMarks) {
        xWinMarks = @[ @(GameMark_X), @(GameMark_X), @(GameMark_X)];
    }

    if (!oWinMarks) {
        oWinMarks = @[ @(GameMark_O), @(GameMark_O), @(GameMark_O)];
    }

    NSMutableArray *possibleWins = [NSMutableArray new];

    // row wins
    [possibleWins addObject:@[ @(0), @(1), @(2) ]];
    [possibleWins addObject:@[ @(3), @(4), @(5) ]];
    [possibleWins addObject:@[ @(6), @(7), @(8) ]];

    // column wins
    [possibleWins addObject:@[ @(0), @(3), @(6) ]];
    [possibleWins addObject:@[ @(1), @(4), @(7) ]];
    [possibleWins addObject:@[ @(2), @(5), @(8) ]];

    // diagonal wins
    [possibleWins addObject:@[ @(0), @(4), @(8) ]];
    [possibleWins addObject:@[ @(2), @(4), @(6) ]];

    for (NSArray *possibleWin in possibleWins) {
#warning possibly ditch the isEqualToArray and instead convert the array into an NSSet and check for one member
        if ([[self getMarksAtIndicies:possibleWin forBoard:self.board] isEqualToArray:xWinMarks]) {
            self.currentGameState = GameState_XWin;
            NSLog(@"Game Over! X Wins!");
            return;
        } else if ([[self getMarksAtIndicies:possibleWin forBoard:self.board] isEqualToArray:oWinMarks]) {
            self.currentGameState = GameState_OWin;
            NSLog(@"Game Over! O Wins!");
            return;
        }
    }
}

- (NSArray *)getMarksAtIndicies:(NSArray *)indicies forBoard:(NSArray *)board
{
    NSMutableArray *marks = [NSMutableArray new];

    for (NSNumber *index in indicies) {
        NSInteger intIndex = [index integerValue];

        if ([board objectAtIndex:intIndex]) {
            NSNumber *mark = board[intIndex];
            [marks addObject:mark];
        }
    }

    NSArray *finalArray = [NSArray arrayWithArray:marks];

    return finalArray;
}


@end
