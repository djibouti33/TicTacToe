//
//  Game.h
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
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

@protocol GameDelegate <NSObject>
- (void)squareMarked:(GameMark *)mark atPosition:(NSInteger)position;

@end

@interface Game : NSObject

@property (nonatomic, assign) GameState currentGameState;
@property (nonatomic, strong) NSMutableArray *board;
@property (nonatomic, assign) id<GameDelegate> delegate;

- (void)pressedSquare:(NSInteger)index;
- (NSMutableArray *)newBoard;


@end
