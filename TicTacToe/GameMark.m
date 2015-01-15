//
//  GameMark.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/14/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameMark.h"

@interface GameMark ()
@property (nonatomic, assign) MarkType markType;
@end

@implementation GameMark

+ (GameMark *)x
{
    return [[GameMark alloc] initWithMarkType:MarkTypeX];
}

+ (GameMark *)o
{
    return [[GameMark alloc] initWithMarkType:MarkTypeO];
}

+ (GameMark *)none
{
    return [[GameMark alloc] initWithMarkType:MarkTypeNone];
}

- (instancetype)initWithMarkType:(MarkType)type
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _markType = type;

    return self;
}

- (UIImage *)image
{
    switch (self.markType) {
        case MarkTypeX:;
            return [UIImage imageNamed:@"xImage"];
            break;

        case MarkTypeO:
            return [UIImage imageNamed:@"oImage"];
            break;

        case MarkTypeNone:
            return [UIImage imageNamed:@"noneImage"];
            break;
    }
}

- (NSString *)description
{
    switch (self.markType) {
        case MarkTypeX:
            return @"X";
            break;

        case MarkTypeO:
            return @"O";
            break;

        case MarkTypeNone:
            return @"-";
            break;
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return true;
    } else if (![other isKindOfClass:[GameMark class]]) {
        return false;
    } else {
        return [self isEqualToGameMark:(GameMark *)other];
    }
}

- (BOOL)isEqualToGameMark:(GameMark *)mark
{
    return [self.description isEqualToString:mark.description];
}

@end
