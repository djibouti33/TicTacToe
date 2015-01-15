//
//  ViewController.m
//  TicTacToe
//
//  Created by Kevin Favro on 1/9/15.
//  Copyright (c) 2015 Kevin Favro. All rights reserved.
//

#import "ViewController.h"

#import "Game.h"
#import "GameMark.h"

@interface ViewController () <GameDelegate>
@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)buttonPressed:(UIButton *)sender;
- (IBAction)resetGame:(UIBarButtonItem *)sender;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (!self) {
        return nil;
    }

    _game = [Game new];
    _game.delegate = self;

    return self;
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    [self.game pressedSquare:sender.tag];
}

- (IBAction)resetGame:(UIBarButtonItem *)sender
{
    for (UIButton *button in self.buttons) {
        [button setTitle:@"Button" forState:UIControlStateNormal];
    }

    [self.game newBoard];
}

#pragma mark - GameDelegate

- (void)squareMarked:(GameMark *)mark atPosition:(NSInteger)position
{
    UIButton *button = self.buttons[position];
    [button setTitle:mark.description forState:UIControlStateNormal];
}

@end
