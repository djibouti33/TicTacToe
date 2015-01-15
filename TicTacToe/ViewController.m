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
@property (weak, nonatomic) IBOutlet UILabel *gameStateDescriptionLabel;
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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.game = [Game new];
    self.game.delegate = self;
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    [self.game moveMadeAtIndex:sender.tag];
}

- (IBAction)resetGame:(UIBarButtonItem *)sender
{
    for (UIButton *button in self.buttons) {
        [button setImage:nil forState:UIControlStateNormal];
    }

    [self.game resetGame];
}

#pragma mark - GameDelegate

- (void)addMark:(GameMark *)mark atIndex:(NSInteger)index
{
    UIButton *button = self.buttons[index];
    [button setImage:mark.image forState:UIControlStateNormal];
}

- (void)gameStateChanged:(NSString *)description
{
    self.gameStateDescriptionLabel.text = description;
}
@end
