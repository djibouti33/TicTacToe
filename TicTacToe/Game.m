//
//  Game.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import "Game.h"

#import "GameMark.h"

@implementation Game

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _board = [self newBoard];

    return self;
}

- (BOOL)isBoardFilled:(NSArray *)board
{
    return ![self.board containsObject:[GameMark none]];
}

- (NSArray *)getAvailableMovesForBoard:(NSArray *)board
{
    NSMutableArray *availableMoves = [NSMutableArray new];

    [board enumerateObjectsUsingBlock:^(GameMark *position, NSUInteger idx, BOOL *stop) {
        if ([position isEqual:[GameMark none]]) {
            [availableMoves addObject:@(idx)];
        }
    }];

    return availableMoves;
}

- (NSMutableArray *)newBoard
{
    NSMutableArray *board = [NSMutableArray new];

    for (int idx = 0; idx < 9; idx++) {
        board[idx] = [GameMark none];
    }

    self.currentGameState = GameState_XTurn;

    return board;
}

- (void)pressedSquare:(NSInteger)index
{
    if (![self.board[index] isEqual:[GameMark none]]) {
        return;
    }

    if (self.currentGameState == GameState_XTurn) {
        GameMark *x = [GameMark x];
        self.board[index] = x;
        [self.delegate squareMarked:x atPosition:index];
        self.currentGameState = GameState_OTurn;
        [self checkForGameOver];

        [self computerTakesTurn];
    } else if (self.currentGameState == GameState_OTurn) {
        GameMark *o = [GameMark o];
        self.board[index] = o;
        [self.delegate squareMarked:o atPosition:index];
        self.currentGameState = GameState_XTurn;
        [self checkForGameOver];
    }
}

- (void)computerTakesTurn
{
    if (self.currentGameState != GameState_OTurn) {
        return;
    }

    NSArray *possibleOutcomes = [NSArray new];
    NSMutableArray *scores = [NSMutableArray new];
    NSMutableArray *moves = [NSMutableArray new];

    NSArray *availableMoves = [self getAvailableMovesForBoard:self.board];

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [self.board mutableCopy];
        clonedBoard[[move integerValue]] = [GameMark o];
        NSInteger currentScore = [self min:clonedBoard];
        [scores addObject:@(currentScore)];
        [moves addObject:move];
    }

    possibleOutcomes = @[scores, moves];

    NSInteger bestMove = [self determineBestMove:possibleOutcomes];
    [self pressedSquare:bestMove];
}

#warning need to clean up and be more clear about moves vs. positions (determineBestMove, scoresAndPositions, etc.)

#define SCORES_INDEX 0
#define MOVES_INDEX 1

- (NSInteger)determineBestMove:(NSArray *)possibleOutcomes
{
    NSInteger bestScore = NSIntegerMin;
    NSInteger bestMove = 0;

    NSMutableArray *scores = possibleOutcomes[SCORES_INDEX];
    NSArray *moves = possibleOutcomes[MOVES_INDEX];

    for (NSInteger idx = 0; idx < scores.count; idx++) {
        NSInteger score = [scores[idx] integerValue];
        if (score > bestScore) {
            bestScore = score;
            bestMove = [moves[idx] integerValue];
        }
    }

    return bestMove;
}

//- (NSInteger)miniMax:(NSMutableArray *)board
//{
//    NSArray *xWinMarks;
//    NSArray *oWinMarks;
//
//    if (!xWinMarks) {
//        xWinMarks = @[ @(GameMark_X), @(GameMark_X), @(GameMark_X)];
//    }
//
//    if (!oWinMarks) {
//        oWinMarks = @[ @(GameMark_O), @(GameMark_O), @(GameMark_O)];
//    }
//
//    NSMutableArray *possibleWins = [NSMutableArray new];
//
//    // row wins
//    [possibleWins addObject:@[ @(0), @(1), @(2) ]];
//    [possibleWins addObject:@[ @(3), @(4), @(5) ]];
//    [possibleWins addObject:@[ @(6), @(7), @(8) ]];
//
//    // column wins
//    [possibleWins addObject:@[ @(0), @(3), @(6) ]];
//    [possibleWins addObject:@[ @(1), @(4), @(7) ]];
//    [possibleWins addObject:@[ @(2), @(5), @(8) ]];
//
//    // diagonal wins
//    [possibleWins addObject:@[ @(0), @(4), @(8) ]];
//    [possibleWins addObject:@[ @(2), @(4), @(6) ]];
//
//    for (NSArray *possibleWin in possibleWins) {
//        if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:oWinMarks]) {
//            return 10;
//        } else if ([[self getMarksAtIndicies:possibleWin forBoard:board] isEqualToArray:xWinMarks]) {
//            return -10;
//        }
//    }
//
//    if (![board containsObject:@(GameMark_None)]) {
//        return 0;
//    }
//
//    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
//    NSInteger bestScore = self.currentGameState == GameState_XTurn ? NSIntegerMax : NSIntegerMin;
//
//    for (NSNumber *move in availableMoves) {
//        NSMutableArray *clonedBoard = [board mutableCopy];
//
//        if (self.currentGameState == GameState_XTurn) {
//            clonedBoard[[move integerValue]] = @(GameMark_X);
//            NSInteger currentScore = [self miniMax:clonedBoard];
//            if (currentScore < bestScore) {
//                bestScore = currentScore;
//            }
//        } else if (self.currentGameState == GameState_OTurn) {
//            clonedBoard[[move integerValue]] = @(GameMark_O);
//            NSInteger currentScore = [self miniMax:clonedBoard];
//            if (currentScore > bestScore) {
//                bestScore = currentScore;
//            }
//        }
//    }
//
//    return bestScore;
//}

- (NSInteger)min:(NSMutableArray *)board
{
    NSMutableArray *possibleWins = [
        @[
            // row wins
            @[ @(0), @(1), @(2) ],
            @[ @(3), @(4), @(5) ],
            @[ @(6), @(7), @(8) ],

            // column wins
            @[ @(0), @(3), @(6) ],
            @[ @(1), @(4), @(7) ],
            @[ @(2), @(5), @(8) ],

            // diagonal wins
            @[ @(0), @(4), @(8) ],
            @[ @(2), @(4), @(6) ]
        ] mutableCopy
    ];

    for (NSArray *possibleWin in possibleWins) {
        NSString *markString = [self getMarksAtIndicies:possibleWin forBoard:board];

        if ([markString isEqualToString:@"XXX"]) {
            return -10;
        } else if ([markString isEqualToString:@"OOO"]) {
            return 10;
        }
    }

    if (![board containsObject:[GameMark none]]) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
    NSInteger bestScore = NSIntegerMax;

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [board mutableCopy];
        clonedBoard[[move integerValue]] = [GameMark x];
        NSInteger currentScore = [self max:clonedBoard];

        if (currentScore < bestScore) {
            bestScore = currentScore;
        }
    }

    return bestScore;
}

- (NSInteger)max:(NSMutableArray *)board
{
    NSMutableArray *possibleWins = [
        @[
            // row wins
            @[ @(0), @(1), @(2) ],
            @[ @(3), @(4), @(5) ],
            @[ @(6), @(7), @(8) ],

            // column wins
            @[ @(0), @(3), @(6) ],
            @[ @(1), @(4), @(7) ],
            @[ @(2), @(5), @(8) ],

            // diagonal wins
            @[ @(0), @(4), @(8) ],
            @[ @(2), @(4), @(6) ]
        ] mutableCopy
    ];

    for (NSArray *possibleWin in possibleWins) {
        NSString *marksAsString = [self getMarksAtIndicies:possibleWin forBoard:board];

        if ([marksAsString isEqualToString:@"XXX"]) {
            return -10;
        } else if ([marksAsString isEqualToString:@"OOO"]) {
            return 10;
        }
    }

    if (![board containsObject:[GameMark none]]) {
        return 0;
    }

    NSArray *availableMoves = [self getAvailableMovesForBoard:board];
    NSInteger bestScore = NSIntegerMin;

    for (NSNumber *move in availableMoves) {
        NSMutableArray *clonedBoard = [board mutableCopy];
        clonedBoard[[move integerValue]] = [GameMark o];
        NSInteger currentScore = [self min:clonedBoard];
        if (currentScore > bestScore) {
            bestScore = currentScore;
        }
    }

    return bestScore;
}

- (void)checkForGameOver
{
    if ([self isBoardFilled:self.board]) {
        self.currentGameState = GameState_Tie;
    }

    NSMutableArray *possibleWins = [
        @[
            // row wins
            @[ @(0), @(1), @(2) ],
            @[ @(3), @(4), @(5) ],
            @[ @(6), @(7), @(8) ],

            // column wins
            @[ @(0), @(3), @(6) ],
            @[ @(1), @(4), @(7) ],
            @[ @(2), @(5), @(8) ],

            // diagonal wins
            @[ @(0), @(4), @(8) ],
            @[ @(2), @(4), @(6) ]
        ] mutableCopy
    ];

    for (NSArray *possibleWin in possibleWins) {
        NSString *marksAsString = [self getMarksAtIndicies:possibleWin forBoard:self.board];

        if ([marksAsString isEqualToString:@"XXX"]) {
            self.currentGameState = GameState_XWin;
            NSLog(@"Game Over! X Wins!");
            return;
        } else if ([marksAsString isEqualToString:@"OOO"]) {
            self.currentGameState = GameState_OWin;
            NSLog(@"Game Over! O Wins!");
            return;
        }
    }
}

//- (GameState)checkWinForBoard:(NSArray *)board
//{
//    if (![board containsObject:[GameMark none]]) {
//        return GameState_Tie;
//    }
//
//
//}

- (NSString *)getMarksAtIndicies:(NSArray *)indicies forBoard:(NSArray *)board
{
    NSMutableString *marksAsString = [NSMutableString new];

    for (NSNumber *index in indicies) {
        NSInteger idx = [index integerValue];

        if ([board objectAtIndex:idx]) {
            GameMark *mark = board[idx];
            [marksAsString appendString:mark.description];
        }
    }

    return marksAsString;
}

@end