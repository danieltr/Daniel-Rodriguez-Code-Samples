//
//  EnemyManuever.m
//  Top Gun 2
//
//  Created by Daniel Rodriguez on 5/28/10.
//  Copyright 2010 Freeverse. All rights reserved.
//  
//  This class is used for all of the enemy jet manuevers 
//

#import "EnemyManuever.h"


@implementation EnemyManuever


#define kFlybyBounds 8.0f

int moveIndex; // current move index
@synthesize offsetPosition; //used for offsetting when there are enemy jet formations
@synthesize myMoves; // container for enemy moves

//Set the moves that the enemy will make
-(void)setMySpawnMoves:(mySpawnMoves*)theMoves
{

	for (int i = 0; i < kMaxMoves; i++)
	{
		myMoves.moves[i] = theMoves[i];
	}
}

//Check what the next move for the enemy will be and set it
-(int)StateFollowingState:(int)state
{

	if(myMoves.moves[moveIndex].time == -1) 
        return ManeuverEnded;
	
	return StartMoving;
}

//Perform the end state of enemy jet
-(void)StateEnded:(int)state
{

	switch (state) 
	{
		case ManeuverInitialized:
			moveIndex = 0;	
			mOwner.position = myMoves.moves[moveIndex].position;
			mOwner->mFaction = GenericEnemy;
			if(myMoves.moves[moveIndex].time == -5)//Show the jet flanking left on exit 
                [super setIsFlankLeft: TRUE];
			if(myMoves.moves[moveIndex].time == -6)//Show the jet flanking right on exit
                [super setIsFlankRight: TRUE];
			break;
		default:
			break;
	}
	
	if(autoOrient)
	{
		[super StateEnded:(state)]; //Used for jet orientation
	}
}

//Check the time for the state to see if it's a special case move
-(float)timeForState:(int)state
{
	
	moveIndex++;
	
	if(myMoves.moves[moveIndex].time == -1)	//Check if the jet maneuvers are done
        return 0;
	else if(myMoves.moves[moveIndex].time == -4){//Check if the jet is rolling
		[super setIsRolling: TRUE];
		[self setRollDir:-1];
		return rollTime;
	}
	else if(myMoves.moves[moveIndex].time == -2){//Check if finishing Cobra Manuever
		[super setIsCobraEnd: TRUE];	
		return cobraEndTime;
	}
	else if(myMoves.moves[moveIndex].time == -3){//Check if U Turing with Cobra Manuever
		[super setIsCobraTurn: TRUE];	
		return cobraTurnTime;
	}
	else if(myMoves.moves[moveIndex].time == -7){//Check if 360 Cobra Manuever
		[super setIsCobraTurn360:TRUE];	
		return cobraTurn360Time;
	}	
	else if(myMoves.moves[moveIndex].time == -8){//Check if Side Cobra Left Manuever
		[super setIsCobraTurnSideL:TRUE];	
		return cobraTurnSideTime;
	}else if(myMoves.moves[moveIndex].time == -9){//Check if Side Cobra Right Manuever
		[super setIsCobraTurnSideR:TRUE];	
		return cobraTurnSideTime;
	}	
	else if(myMoves.moves[moveIndex].time == -10){//Check if the jet is rolling
		[super setIsRolling: TRUE];
		[self setRollDir:1];
		return rollTime;
	}	
	else if(state == StartMoving)//Check if the jet needs to start moving 
        return myMoves.moves[moveIndex].time;
		
	return 0;
		
}

//Move the enemy foward towards it's next position and update it
-(void)UpdateState:(int)state withInterval:(float)deltaT toTimeRatio:(float)ratio
{
    //Check if the enemy is rolling
	if(isRolling)
		if(rollTime*ratio == rollTime) 
            [super setIsRolling: FALSE];
	
    //Update the postion of the enemy
	Vector3 temp = Vector3((myMoves.moves[moveIndex-1].position.x*(1.0 - ratio) + myMoves.moves[moveIndex].position.x*ratio + offsetPosition.x), 
						   (myMoves.moves[moveIndex-1].position.y*(1.0 - ratio) + myMoves.moves[moveIndex].position.y*ratio + offsetPosition.y), 
						   (myMoves.moves[moveIndex-1].position.z*(1.0 - ratio) + myMoves.moves[moveIndex].position.z*ratio + offsetPosition.z));
	
    //Set the postition for the enemy
	mOwner.position = temp;
	
    //Handle jet orietation
	if(autoOrient) 
        [super UpdateState:(state) withInterval:deltaT toTimeRatio:ratio]; //Used for jet orientation
	else 
        mOwner->mOrientation.y = 90;//Set jet to defualt orientation

}

@end
