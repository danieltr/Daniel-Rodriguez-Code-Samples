//
//  SceneFishMiniGame.h
//  Fantastic Fish
//
//  Created by Daniel Rodriguez
//  Copyright 2011 Freeverse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUIScreen.h"
#import "Renderer.h"
#import "SkinnedMeshNode.h"
#import "FUIElement.h"
#import "Fish.h"
#import "FishPlayDataSource.h"

//scene configuration variables
#define kDelayTime 6 // How long to wait before the game begins
#define kTargetFishLevel 1 //What level the fish will be in the mini game ~ currently set to one since it will only be special creatures
#define kTopConfinement 60 //Top hieght the user can move
#define kBottomConfinement 225 // Bottom height the user can move
#define kTimeBetweenSpeedUp 30 // The time it takes before the level starts to move faster
#define kNumberofHearts 3 // Number of lives the user has before the mini game ends
#define kHeartScore 1 // number of hearts a heart item gives

/* SceneFishMiniGame is where the fish mini game is setup and played. */

@interface SceneFishMiniGame : FUIScreen
{
	Renderer *render; // holds the 3d scene
	SkinnedMeshNode *fish; // holds the Skin mesh
	Fish *targetFish; //holds the fish data
	
	FishPlayDataSource *source; //holds the mini game data
	
	FUIElement *fishModelFrame; //holds the element for the fish
	FUIElement *item; //holds the element for the items 
	FUIElement *nomArea; //holds the element for nom area
	FUIElement *nomSign; //holds the element for yum sign
	FUIElement *yuckSign; //holds the element for the yum sign
	
	float elapsedTime; // time the user has been playing
	
    //we need to do this so we can survive existing with no gameworld or fishapedia ready
	BOOL inited;	
    
    //is the item the fish ate good or bad
	BOOL goodEat;	
    
    //is this the first run at the game
	BOOL firstTime;
	
	//The 3 tiles for the scrolling background
	Sprite*	tile1;
	Sprite*	tile2;
	Sprite*	tile3;
	
	NSMutableArray *backgroundCollection; // hold the image names for backgrounds
	NSMutableArray *eatCollection; // hold the image names for good items 
	NSMutableArray *pukeCollection; // hold the image names for bad items 
    
	FUIElement *playerCoinCount;// coin count element
	FUIElement *playerXPCount; // xp count element
	FUIElement *playerClamCount; // clam count element
	FUIElement *playerTotalTime; // time element
	FUIElement *heart1; // heart 1 element
	FUIElement *heart2; // heart 2 element
	FUIElement *heart3; // heart 3 element
	FUIElement *playerHearts; // heart container element
	
	float gameSpeed; //speed at which the game is going
	int goodItemChosen; //which good item has been chosen
	int badItemChosen; //which bad item has been chosen
	
	int hearts; //count of hearts
	
	BOOL dispenseItems;//should the game dispense an new item
	
	BOOL startMusic; //should the music start playing
	BOOL itemHit; //did the fish hit an item
	
	float scoreMultiplier; //How much will the score go up when the user gets a good item
}

-(void)ItemDispenser:(float)deltaT; // dispense and update the item on screen
-(BOOL)fishEat:(FUIElement *)eatenItemX; //See if an item was eaten by the fish
-(void)ScrollingBackdrop:(float)deltaT; //Update the backgrounds
-(void)ConfigureGame; //Setup the game for play
-(void)ResetGame; //Reset the game
-(void)HideStatusBar; //hid the status bar

@end
