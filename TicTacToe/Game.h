//
//  Game.h
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameBoard.h"

@class GameMark;

@protocol GameDelegate <NSObject>
- (void)addMark:(GameMark *)mark atIndex:(NSInteger)index;
@end

@interface Game : NSObject

@property (nonatomic, assign) id<GameDelegate> delegate;

- (void)moveMadeAtIndex:(NSInteger)index;
- (void)resetGame;

@end
