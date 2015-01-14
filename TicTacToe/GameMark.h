//
//  GameMark.h
//  TicTacToe
//
//  Created by Kevin Favro on 1/14/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MarkType) {
    MarkTypeX,
    MarkTypeO,
    MarkTypeNone
};

@class UIImage;

@interface GameMark : NSObject

@property (nonatomic, strong, readonly) UIImage *image;

+ (GameMark *)x;
+ (GameMark *)o;
+ (GameMark *)none;

@end
