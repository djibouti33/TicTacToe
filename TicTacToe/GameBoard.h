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

@interface GameBoard : NSObject <NSCopying>

@property (nonatomic, strong) NSMutableArray *moves;
@property (nonatomic, assign) GameState currentGameState;

- (BOOL)allMovesTaken;
- (void)updateGameStateForWin;
- (NSArray *)availableMoves;
- (NSString *)marksAtIndicies:(NSArray *)indicies;


@end
