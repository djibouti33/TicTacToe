//
//  GameBoard.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/14/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import "GameBoard.h"

#import "GameMark.h"

@interface GameBoard ()
@property (nonatomic, strong) NSMutableArray *moves;

@end

@implementation GameBoard

- (instancetype)init
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _moves = [self setupNewBoard];
    _currentGameState = GameState_XTurn;

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    GameBoard *board = [GameBoard new];
    board.moves = [self.moves mutableCopyWithZone:zone];
    board.currentGameState = self.currentGameState;

    return board;
}

- (NSMutableArray *)setupNewBoard
{
    NSMutableArray *moves = [NSMutableArray new];

    for (int idx = 0; idx < 9; idx++) {
        moves[idx] = [GameMark none];
    }

    return moves;
}

- (BOOL)allMovesTaken
{
    return ![self.moves containsObject:[GameMark none]];
}

- (NSArray *)availableMoves
{
    NSMutableArray *availableMoves = [NSMutableArray new];

    [self.moves enumerateObjectsUsingBlock:^(GameMark *mark, NSUInteger idx, BOOL *stop) {
        if ([mark isEqual:[GameMark none]]) {
            [availableMoves addObject:@(idx)];
        }
    }];

    return availableMoves;
}

- (NSString *)marksAtIndicies:(NSArray *)indicies
{
    NSMutableString *marksAsString = [NSMutableString new];

    for (NSNumber *index in indicies) {
        NSInteger idx = [index integerValue];

        if ([self.moves objectAtIndex:idx]) {
            GameMark *mark = self.moves[idx];
            [marksAsString appendString:mark.description];
        }
    }

    return marksAsString;
}

- (void)updateGameStateForWin
{
    static dispatch_once_t once;
    static NSMutableArray *winningLines;
    dispatch_once(&once, ^{
        winningLines = [
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
    });

    for (NSArray *line in winningLines) {
        NSString *marksAsString = [self marksAtIndicies:line];
        
        if ([marksAsString isEqualToString:@"XXX"]) {
            self.currentGameState = GameState_XWin;
            return;
        } else if ([marksAsString isEqualToString:@"OOO"]) {
            self.currentGameState = GameState_OWin;
            return;
        }
    }

    if ([self allMovesTaken]) {
        self.currentGameState = GameState_Tie;
    }
}

- (BOOL)containsValidMarkAtIndex:(NSInteger)index
{
    return ![self.moves[index] isEqual:[GameMark none]];
}

- (void)placeMark:(GameMark *)mark atIndex:(NSInteger)index
{
    self.moves[index] = mark;
    self.currentGameState = ( self.currentGameState == GameState_XTurn ? GameState_OTurn : GameState_XTurn );
}

- (NSString *)gameStateDescription
{
    switch (self.currentGameState) {
        case GameState_XTurn:
            return @"Your Turn";
            break;

        case GameState_OTurn:
            return @"Computer's Turn";
            break;

        case GameState_XWin:
            return @"Congratulations on beating the computer, but you might want to look for a different job.";
            break;

        case GameState_OWin:
            return @"Bummer! To be expected though.";
            break;

        case GameState_Tie:
            return @"A valiant effort. The best you can do, really.";
            break;
    }
}

@end
