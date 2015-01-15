//
//  Game.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import "Game.h"

#import "GameMark.h"

@interface Game ()
@property (nonatomic, strong) GameBoard *board;
@end

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

- (void)moveMadeAtIndex:(NSInteger)index
{
    if ([self.board containsValidMarkAtIndex:index]) {
        return;
    }

    if (self.board.currentGameState == GameState_XTurn) {
        GameMark *x = [GameMark x];
        [self.board placeMark:x atIndex:index];
        [self.delegate addMark:x atIndex:index];
        [self checkForGameOver];

        [self computerTakesTurn];
    } else if (self.board.currentGameState == GameState_OTurn) {
        GameMark *o = [GameMark o];
        [self.board placeMark:o atIndex:index];
        [self.delegate addMark:o atIndex:index];
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
        [clonedBoard placeMark:[GameMark o] atIndex:[move integerValue]];
        NSInteger currentScore = [self miniMax:clonedBoard];
        [scores addObject:@(currentScore)];
        [moves addObject:move];
    }

    possibleOutcomes = @[scores, moves];

    NSInteger bestMove = [self determineBestMove:possibleOutcomes];
    [self moveMadeAtIndex:bestMove];
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

- (NSInteger)miniMax:(GameBoard *)board
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
    NSInteger bestScore = ( board.currentGameState == GameState_XTurn ? NSIntegerMax : NSIntegerMin );

    for (NSNumber *move in availableMoves) {
        GameBoard *clonedBoard = [board copy];

        if (board.currentGameState == GameState_XTurn) {
            [clonedBoard placeMark:[GameMark x] atIndex:[move integerValue]];
            NSInteger currentScore = [self miniMax:clonedBoard];
            if (currentScore < bestScore) {
                bestScore = currentScore;
            }
        } else if (board.currentGameState == GameState_OTurn) {
            [clonedBoard placeMark:[GameMark o] atIndex:[move integerValue]];
            NSInteger currentScore = [self miniMax:clonedBoard];
            if (currentScore > bestScore) {
                bestScore = currentScore;
            }
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