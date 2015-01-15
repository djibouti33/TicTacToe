//
//  GameBoard.h
//  TicTacToe
//
//  Created by Kevin Favro on 1/14/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GameState) {
    GameState_XTurn,
    GameState_OTurn,
    GameState_XWin,
    GameState_OWin,
    GameState_Tie
};

@class GameMark;

@interface GameBoard : NSObject <NSCopying>

@property (nonatomic, assign) GameState currentGameState;

- (NSArray *)availableMoves;
- (BOOL)allMovesTaken;
- (void)updateGameStateForWin;
- (NSString *)marksAtIndicies:(NSArray *)indicies;
- (BOOL)containsValidMarkAtIndex:(NSInteger)index;
- (void)placeMark:(GameMark *)mark atIndex:(NSInteger)index;

@end
