//
//  EnemyJetManuever.h
//  Top Gun 2
//
//  Created by Daniel Rodriguez on 5/28/10.
//  Copyright 2010 Freeverse. All rights reserved.
//  
//  This class is used for all of the enemy jet manuevers 
//

#import <Foundation/Foundation.h>
#import "Maneuver.h"

//pre-defined special moves that can be used for enemy fighters
#define ManeuverDone {-1, Vector3(-1, -1, -1)}
#define CobraEnd -2
#define CobraTurn {-3, Vector3(0, 0, -200)}, {0.5, Vector3(0, -10, -170)}, {0.5, Vector3(0, -30, -120)}, {0.7, Vector3(0, -29, -80)}
#define BarrelRollLeft -4
#define ShowFlankLeft -5
#define ShowFlankRight -6
#define CobraTurn360 {-7, Vector3(0, 30, -170)}, {0.5, Vector3(0,20, -150)}, {0.8, Vector3(0,  0, -130)}
#define CobraTurnSideL {-8, Vector3(0, 50, -170)}, {1.5, Vector3(-10, -15, -130)},  {1.5, Vector3(-160,  20, -130)}
#define CobraTurnSideR {-9, Vector3(0, 50, -170)}, {1.5, Vector3(10, -15, -130)},  {1.5, Vector3(160,  20, -130)}
#define BarrelRollRight -10

// time alloted for certain special moves
#define rollTime			2.0
#define cobraEndTime		2.5
#define cobraTurnTime		2.0
#define cobraTurn360Time	1.0
#define cobraTurnSideTime	2.0

//max moves an enemy jet can have
#define kMaxMoves			25

// States
enum 
{
	StartMoving,
};

//Holds the time and postion a manuevers needs. If time is a negative number, it refers to a specific move listed above.
struct mySpawnMoves 
{
	float	time;
	Vector3 position;
};

//Container for enemy moves
typedef struct {
	 mySpawnMoves moves[kMaxMoves];
} spawnCollection;

//Base class setup
@interface EnemyJetManuever : Maneuver 
{
	int moveIndex;// current move index
	Vector3 offsetPosition;	//used for offsetting when there are enemy jet formations	
	spawnCollection myMoves; // container for enemy moves
}

@property (nonatomic, assign) spawnCollection myMoves;
@property Vector3 offsetPosition;

//Set the moves from airspace.m
-(void)setMySpawnMoves:(mySpawnMoves*)theMoves;


@end
