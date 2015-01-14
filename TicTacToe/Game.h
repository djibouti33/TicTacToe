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

typedef NS_ENUM(NSUInteger, GameMark) {
    GameMark_X,
    GameMark_O,
    GameMark_None,
};

@protocol GameDelegate <NSObject>
- (void)squareMarked:(NSInteger)mark atPosition:(NSInteger)position;

@end

@interface Game : NSObject

@property (nonatomic, assign) GameState currentGameState;
@property (nonatomic, strong) NSMutableArray *board;
@property (nonatomic, assign) id<GameDelegate> delegate;

- (void)pressedSquare:(NSInteger)index;
- (BOOL)isBoardEmpty;
- (NSMutableArray *)resetBoard;


@end
