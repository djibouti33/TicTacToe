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

    [self resetGame];

    return self;
}

- (void)resetGame
{
    self.board = [GameBoard new];
}

- (void)pressedSquare:(NSInteger)index
{
    if (![self.board.moves[index] isEqual:[GameMark none]]) {
        return;
    }

    if (self.board.currentGameState == GameState_XTurn) {
        GameMark *x = [GameMark x];
        self.board.moves[index] = x;
        [self.delegate squareMarked:x atPosition:index];
        self.board.currentGameState = GameState_OTurn;
        [self checkForGameOver];

        [self computerTakesTurn];
    } else if (self.board.currentGameState == GameState_OTurn) {
        GameMark *o = [GameMark o];
        self.board.moves[index] = o;
        [self.delegate squareMarked:o atPosition:index];
        self.board.currentGameState = GameState_XTurn;
        [self checkForGameOver];
    }
}

- (void)computerTakesTurn
{
    if (self.board.currentGameState != GameState_OTurn) {
        return;
    }

    NSArray *possibleOutcomes = [NSArray new];
    NSMutableArray *scores = [NSMutableArray new];
    NSMutableArray *moves = [NSMutableArray new];

    NSArray *availableMoves = [self.board availableMoves];

    for (NSNumber *move in availableMoves) {
        GameBoard *clonedBoard = [self.board copy];
        clonedBoard.moves[[move integerValue]] = [GameMark o];
        NSInteger currentScore = [self min:clonedBoard];
        [scores addObject:@(currentScore)];
        [moves addObject:move];
    }

    possibleOutcomes = @[scores, moves];

    NSInteger bestMove = [self determineBestMove:possibleOutcomes];
    [self pressedSquare:bestMove];
}

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

- (NSInteger)min:(GameBoard *)board
{
    [board updateGameStateForWin];

    switch (board.currentGameState) {
        case GameState_XWin:
            return -10;
            break;

        case GameState_OWin:
            return 10;
            break;

        case GameState_Tie:
            return 0;
            break;

        default:
            break;
    }

    NSArray *availableMoves = [board availableMoves];
    NSInteger bestScore = NSIntegerMax;

    for (NSNumber *move in availableMoves) {
        GameBoard *clonedBoard = [board copy];
        clonedBoard.moves[[move integerValue]] = [GameMark x];
        NSInteger currentScore = [self max:clonedBoard];

        if (currentScore < bestScore) {
            bestScore = currentScore;
        }
    }
    
    return bestScore;
}

- (NSInteger)max:(GameBoard *)board
{
    [board updateGameStateForWin];

    switch (board.currentGameState) {
        case GameState_XWin:
            return -10;
            break;

        case GameState_OWin:
            return 10;
            break;

        case GameState_Tie:
            return 0;
            break;

        default:
            break;
    }

    NSArray *availableMoves = [board availableMoves];
    NSInteger bestScore = NSIntegerMin;

    for (NSNumber *move in availableMoves) {
        GameBoard *clonedBoard = [board copy];
        clonedBoard.moves[[move integerValue]] = [GameMark o];
        NSInteger currentScore = [self min:clonedBoard];
        if (currentScore > bestScore) {
            bestScore = currentScore;
        }
    }
    
    return bestScore;
}

- (void)checkForGameOver
{
    [self.board updateGameStateForWin];

    switch (self.board.currentGameState) {
        case GameState_XWin:
            NSLog(@"Congratulations on beating the computer, but you might want to look for a different job.");
            break;

        case GameState_OWin:
            NSLog(@"Bummer! But you kind of expected that, didn't you?");
            break;

        case GameState_Tie:
            NSLog(@"A valiant effort");
            break;

        default:
            break;
    }
}

@end