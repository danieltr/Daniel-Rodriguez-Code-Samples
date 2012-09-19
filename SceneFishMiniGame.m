//
//  SceneFishMiniGame.m
//  Fantastic Fish
//
//  Created by Daniel Rodriguez
//  Copyright 2011 Freeverse. All rights reserved.
//

#import "SceneFishMiniGame.h"
#import "UserDataManager.h"
#import "EmpireAppDelegate.h"
#import "Fish.h"
#import "MasterStructs.h"
#import "GameDriver.h"
#import "SceneFishGameMenu.h"
#import "SceneFishGameResults.h"
#import "NGPipes.h"

#include "DefaultEffect.h"
#include "DefaultAlphaTestEffect.h"
#include "SkinnedEffect.h"
#include "GenericParticles.h"
#include "flickAds.h"

/* SceneFishMiniGame is where the fish mini game is setup and played. */

@implementation SceneFishMiniGame

-(id) init {
	[super init];
}

-(void)dealloc
{
	//Clear out background images
	[tile1 release];
	[tile2 release];
	[tile3 release];
	
    //Clear out the fish data
	FishMaster *master = [[ManifestManager manager] FishNamed:[UserDataManager manager].currentFishForMini];
	[[TextureManager sharedManager] RelinquishTexture:[[TextureManager sharedManager] GetTextureNamed:master->texture[kTargetFishLevel]]];
	[[MeshManager singleton] RelinquishMesh:[[MeshManager singleton] GetMeshNamed:master->model[kTargetFishLevel]]];
	[[AnimationManager singleton] RelinquishAnimation:[[AnimationManager singleton] GetAnimationNamed:master->fastSwimAnimation[kTargetFishLevel]]];
	[[SkinManager singleton] RelinquishSkin:[[SkinManager singleton] GetSkinNamed:master->skin[kTargetFishLevel]]];
	
    // delet the fish if it exists
	if(fish)
	{
		delete fish;
		fish = NULL;
	}
    
    //delete the rendered scene if it exists
	if(render)
	{
		delete render;
		render = NULL;
	}
    
    //clear whatever else is left
	[super dealloc];
	
}
-(void)performAction:(FUIElement *)element
{	
    //Exit the mini game
	if(element==[self GetElementByName:@"plusButton"])
	{
		NSLog(@"Return to Gameworld");
		[[GameDriver driver] scheduleRemovalOfContext:[FishPlayDataSource dataSource]];
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[[UserDataManager manager] enterTankByIdentifier:[UserDataManager manager].currentTankID ofUsername:[UserDataManager manager].currentUsername];
		
		[[GameDriver driver] PerformLoad];
	}
}

//load the Scenes buttons and other ui items
-(NSString *)XMLFileName
{
	return @"SceneFishMiniGame.xml";
}

-(void)OnEnter
{
	[super OnEnter];
    
	startMusic = YES;
	[UserDataManager manager].beginMiniGame = YES;

    //Set all of the game variables for a fresh play through
	itemHit = NO;
	[self ResetGame];
	
    //Get UI elements for the scene
	playerCoinCount = [self GetElementByName:@"playerCoinCount"];
	playerClamCount = [self GetElementByName:@"playerClamCount"];
	playerXPCount = [self GetElementByName:@"playerXPCount"];
	playerTotalTime = [self GetElementByName:@"totalTime"];
	heart1 = [self GetElementByName:@"heart1"];
	heart2 = [self GetElementByName:@"heart2"];
	heart3 = [self GetElementByName:@"heart3"];
	fishModelFrame = [self GetElementByName:@"fishModelFrame"];
	item = [self GetElementByName:@"item"];
	nomArea = [self GetElementByName:@"nomArea"];
	nomSign = [self GetElementByName:@"nomSign"];
	yuckSign = [self GetElementByName:@"yuckSign"];
	
    //Set the users data to the appropraite fields 
	[playerCoinCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalCoins] withAnimation:NO];
	[playerClamCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalClams] withAnimation:NO];
	[playerXPCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalxp] withAnimation:NO];
	[playerTotalTime SetText:[NSString stringWithFormat:@"0" ] withAnimation:NO];
	
    //Setup the fish
	FishMaster *master = [[ManifestManager manager] FishNamed:[UserDataManager manager].currentFishForMini];
	[[TextureManager sharedManager] LoadTexture:master->texture[kTargetFishLevel]];
	[[MeshManager singleton] LoadSceneNode:master->model[kTargetFishLevel]];
	[[AnimationManager singleton] LoadAnimation:master->fastSwimAnimation[kTargetFishLevel]];
	[[SkinManager singleton] LoadSkin:master->skin[kTargetFishLevel]];
	
	//build a SkinnedMeshNode for the fish, same trick as the avatars in the tank gallery
	render = new Renderer((Renderer::GLESVersion)[GLStateManager manager].glesVersion);
	AnimatedMesh *mesh = [[AnimatedMesh alloc] init];
	[mesh SetAnimationModelSkinWithName:master->fastSwimAnimation[kTargetFishLevel] withModelName:master->model[kTargetFishLevel] withSkinName:master->skin[kTargetFishLevel]];
	
	fish = new SkinnedMeshNode(mesh);
	fish->mCanBePicked = false;
	fish->mLocalMatrix.LoadIdentity();
	fish->mWorldMatrix.LoadIdentity();
	
	Vector3 meshScale = [[MeshManager singleton] GetSizeNamed:master->model[kTargetFishLevel]];
	Vector3 meshOffset = [[MeshManager singleton] GetOffsetFromOrigin:master->model[kTargetFishLevel]];
	
	float meshTargetScale = 40.0;
	float scaleFactor = meshTargetScale/meshScale.Magnitude();
	
	fish->mLocalMatrix.Translate(Vector3(-meshOffset.z, 0, 0));
	fish->mLocalMatrix.Scale(Vector3(scaleFactor, scaleFactor, scaleFactor));
	
	fish->SetTexture2DName(master->texture[kTargetFishLevel]);
	
	if([GLStateManager manager]->skinnedEffect != NULL)
	{
		fish->SetEffectInstance([GLStateManager manager]->skinnedEffect->CreateInstance(mesh->skinModel.skinCount));
		fish->GetEffectInstance()->GetEffect()->GetDepthState(0, 0)->mEnabled = true;
		fish->GetEffectInstance()->GetEffect()->GetAlphaState(0, 0)->mBlendEnabled = true;
		fish->GetEffectInstance()->GetEffect()->GetCullState(0, 0)->mEnabled = false;
	}
	
    //Setup the initial time
	elapsedTime = kDelayTime;
	
    //setup the first background tile
	tile1 = [Sprite new];
	tile1->mIsBillboard = NO;
	tile1->mUseExactSize = NO;
	tile1->mUseFadeAway = NO;
	tile1->mPos = Vector3(256,320,1);
	tile1->mSize = Vector3(256,256,1);
	tile1->mUseAlpha = NO;
	
    //setup the second background tile
	tile2 = [Sprite new];
	tile2->mIsBillboard = NO;
	tile2->mUseExactSize = NO;
	tile2->mUseFadeAway = NO;
	tile2->mPos = Vector3(512,320,1);
	tile2->mSize = Vector3(256,256,1);
	tile2->mUseAlpha = NO;
	
    //setup the third background tile
	tile3 = [Sprite new];
	tile3->mIsBillboard = NO;
	tile3->mUseExactSize = NO;
	tile3->mUseFadeAway = NO;
	tile3->mPos = Vector3(768,320,1);
	tile3->mSize = Vector3(256,256,1);
	tile3->mUseAlpha = NO;
	
    //Setup the Ads at the bottom of the mini game
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		[[flickBannerAd defaultAd] viewDidAppearInFrame:CGRectMake(kSmallBannerRectIPad) inSuperview:[[[EmpireAppDelegate singleton].navigationController topViewController] view]];
	}
	else
	{
		[[flickBannerAd defaultAd] viewDidAppearInFrame:CGRectMake(kSmallBannerRectIPhone) inSuperview:[[[EmpireAppDelegate singleton].navigationController topViewController] view]];
	}	
}

- (void) OnExit 
{
	[super OnExit];
    
	if([GLStateManager manager]->skinnedEffect != NULL)
	{
		fish->GetEffectInstance()->GetEffect()->GetAlphaState(0, 0)->mBlendEnabled = false;
		fish->GetEffectInstance()->GetEffect()->GetCullState(0, 0)->mEnabled = false;
	}
    //disable bottom ads
	[[flickBannerAd defaultAd] viewWillDisappear];
}

-(void)Update:(float)deltaT
{
	[super Update:deltaT];
	
    //Setup the game if we need to
	if([FishPlayDataSource dataSource] && !inited)
	{
		[self ConfigureGame];
		inited = YES;
	}
    //Start game if it's already setup
    else if([UserDataManager manager].beginMiniGame){
		[UserDataManager manager].totalTime += deltaT;// update time played
        if(dispenseItems){ 
            //Start playing music if it hasn't started playing yet
			if(startMusic){
				startMusic = NO;
				if([[SoundLibrary library] IsMusicPlaying])
					[[SoundLibrary library] forceStopMusic];
				[[SoundLibrary library] BeginMusicFile:@"music/store/shopScreen2.mp3" withRestart:NO withLooping:YES];
				[[SoundLibrary library] StartMusic];
			}
            
			//push out another item
			[self ItemDispenser:deltaT];
			//increment game speed
            gameSpeed = ([UserDataManager manager].totalTime)/kTimeBetweenSpeedUp + 1;
		}
        
	}
    //update fish animation
	fish->Update(deltaT);
    //update background scroll
	[self ScrollingBackdrop:deltaT];
    
    //check if a new item needs to be dispensed 
	if(elapsedTime <= 0 && [UserDataManager manager].beginMiniGame && !dispenseItems)
		dispenseItems = YES;
	
}

//Setup variables for the game
-(void)ConfigureGame
{
    //Get all of the mini game data
	source = [FishPlayDataSource dataSource];
    
    //Get an array of images for the background
	backgroundCollection = [[source getScrollTiles] mutableCopy];
	
    //Get items that help the user
	eatCollection = [[source getGoodItems] mutableCopy];
    
    //Get items that hurt the user
	pukeCollection = [[source getBadItems] mutableCopy];
	
    //Setup the score multiplier
	scoreMultiplier =  int([source getScoreMultipliersFor:[UserDataManager manager].currentFishForMini]);
	if(scoreMultiplier <= 0 || !scoreMultiplier)
		scoreMultiplier = 1;
    
	goodEat = YES;
	firstTime = YES;
	
    //Set up random background images
	[tile1 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];
	[tile2 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];
	[tile3 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];
	
}
-(void)ResetGame
{
    //Since the game is being reset just do it once until the game is setup again
	[UserDataManager manager].resetMiniGame = NO;
    
    //Reset time
	elapsedTime = kDelayTime;
	
    //Stop dispensing Items
	dispenseItems = NO;
    
    //Show all of the hearts again
	[heart1 SetAlpha:1];
	[heart2 SetAlpha:1];
	[heart3 SetAlpha:1];
	
    //Reset game speed
	gameSpeed = 1;
    
    //Reset time
	[UserDataManager manager].totalTime = 0;
	
    //Reset heart cound
    hearts = kNumberofHearts;
	
    //Reset Scores
	[UserDataManager manager].totalCoins = 0;
	[UserDataManager manager].totalClams = 0;
	[UserDataManager manager].totalxp = 0;
	goodItemChosen = 0;
	badItemChosen = 0;
    
	[playerCoinCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalCoins] withAnimation:NO];
	[playerClamCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalClams] withAnimation:NO];
	[playerXPCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalxp] withAnimation:NO];
	[playerTotalTime SetText:[NSString stringWithFormat:@"0"] withAnimation:NO];
	
}

//Scroll the background
-(void)ScrollingBackdrop:(float)deltaT
{
    //Move them by the current gameSpeed
	tile1->mPos.x -= gameSpeed;
	tile2->mPos.x -= gameSpeed;
	tile3->mPos.x -= gameSpeed;
	
    //Push tile 2 back and change the image
	if(tile1->mPos.x <= 0){
		tile1->mPos.x = tile3->mPos.x + tile3->mSize.x;
		[tile1 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];
	}

    //Push tile 2 back and change the image
	if(tile2->mPos.x <= 0){
		tile2->mPos.x = tile1->mPos.x + tile1->mSize.x;
		[tile2 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];
	}
    
    //Push tile 3 back and change the image
	if(tile3->mPos.x <= 0){
		tile3->mPos.x = tile2->mPos.x + tile2->mSize.x;
		[tile3 SetSpriteSheet:[backgroundCollection objectAtIndex:(arc4random() % [backgroundCollection count])]];		
	}
    
    //update the time
	elapsedTime -= deltaT;
}

//Dispense Items for the users and update them
-(void)ItemDispenser:(float)deltaT
{
    //setup a default y postition
	int yPosition = 0;
	
    //Check if the item has reached the left side of the screen
    if(item->mPosition.x <= -[item GetSize].x || itemHit){
		//item has not been hit and needs to be pushed back off the screen on the right side
        itemHit = NO;
		item->mPosition.x = 480;
		elapsedTime = kDelayTime;
		
        //get a new random height for the item
		yPosition = (arc4random() % kBottomConfinement);
		
        //Set the minimum the item's why can be
		if(yPosition < 25)
			yPosition = 25;
		
        //Check if the item should be a good or bad item
		if([source getGoodItemsChance] >= (float)random()/RAND_MAX){
			//Create a random good item
            int q = 0;
			float randI = ((float)random()/RAND_MAX);
			for(int i = 0; i < [source numberOfGoodItems]; i++ ){
				if([source chanceForGoodItem:i] > randI)
					q++;
				else
					break;
			}
			if(q != 0)
				goodItemChosen = (arc4random() % q);
			else 
				goodItemChosen = 0;
			
			[item SetSize:[source SizeForGoodItem:goodItemChosen]];
			[item SetGraphic:[source ImageNameForGoodItem:goodItemChosen]];
			item->mLoadedTex = [source TextureCoordinatesForGoodItem:goodItemChosen]; 
            goodEat = YES;
		}else{
            //Create a random bad item
			int q = 0;
			float randI = ((float)random()/RAND_MAX);
			for(int i = 0; i < [source numberOfBadItems]; i++ ){
				if([source chanceForBadItem:i] > randI)
					q++;
				else
					break;
			}
			if(q != 0)
				badItemChosen = (arc4random() % q);
			else 
				badItemChosen = 0;
			
			[item SetSize:[source SizeForBadItem:badItemChosen]];
			[item SetGraphic:[source ImageNameForBadItem:badItemChosen]];
			item->mLoadedTex = [source TextureCoordinatesForBadItem:badItemChosen]; 
			goodEat = NO;
		}
		
	}
	
	//Set the items posititon
	[item SetPosition:Vector3(item->mPosition.x - gameSpeed*2 ,((yPosition != 0) ? yPosition : item->mPosition.y), 0.0f)];
	
    //Check if the fish ate this item
	if([self fishEat:item])
    {
        //Fish Ate this item
		itemHit = YES;
        
        //Setup the signs positions
		nomSign->mPosition.y = fishModelFrame->mPosition.y + fishModelFrame->mSize.y/2 - 70;
		yuckSign->mPosition.y = fishModelFrame->mPosition.y + fishModelFrame->mSize.y/2 - 70;
        
		if(goodEat){
            //Ate a good item
			Vector3 gains = [source gainsForGoodItem:goodItemChosen];
            
            //Update the Users Coins
			if(gains.y){
				[UserDataManager manager].totalCoins += (gains.y * scoreMultiplier);
				[playerCoinCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalCoins] withAnimation:NO];
			}
            
            //Update the Users Clams
			if(gains.z){
				[UserDataManager manager].totalClams += gains.z;
				[playerClamCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalClams] withAnimation:NO];
			}

            //Update the Users Coins XP
			if(gains.x){
				[UserDataManager manager].totalxp += gains.x;
				[playerXPCount SetText:[NSString stringWithFormat:@"x%i", [UserDataManager manager].totalxp] withAnimation:NO];
			}
			
            //Give user and extra heart
			if([[source nameForGoodItem:goodItemChosen] isEqualToString:@"Heart"]){
				++hearts;
				if(hearts > kNumberofHearts)
					hearts = kNumberofHearts;
				
				if(hearts == kNumberofHearts){
					[heart3 SetAlpha:1];
					[heart2 SetAlpha:1];
					[heart1 SetAlpha:1];
				}
				if(hearts < kNumberofHearts){
					[heart2 SetAlpha:1];
					[heart1 SetAlpha:1];
				}
                
				[playerTotalTime SetText:[NSString stringWithFormat:@"%i", int([UserDataManager manager].totalTime) * ([UserDataManager manager].totalCoins + [UserDataManager manager].totalClams + [UserDataManager manager].totalxp + kHeartScore)] withAnimation:NO];
			}else{
				[playerTotalTime SetText:[NSString stringWithFormat:@"%i", int([UserDataManager manager].totalTime) * ([UserDataManager manager].totalCoins + [UserDataManager manager].totalClams + [UserDataManager manager].totalxp)] withAnimation:NO];
			}
			[self playAnimationBlockNamed:@"nomAnim"];
            
		}
		else{
             //Ate a bad item so player looses a heart
			--hearts;
            
			[heart3 SetAlpha:0];
			if(hearts < 2)
				[heart2 SetAlpha:0];
			if(hearts < 1) 
				[heart1 SetAlpha:0];

			[self playAnimationBlockNamed:@"yuckAnim"];
			
            //Check if the player has lost the mini game
			if(hearts <= 0){
                //Player has lost game is over so show the game results
				item->mPosition.x = 480;
				[UserDataManager manager].beginMiniGame = NO;
				
				[self HideStatusBar];
				
				[[FUIManager sharedManager] showModalScreen:SCREEN_FISH_GAME_RESULTS];
			}
		}
		elapsedTime = 0;
		NSLog(@"Ate that item - Show Nom anim");
	}
	if(item->mPosition.x < -1*(item->mSize.y))
		elapsedTime = 0;
    
}

//Check if the fish has collided with any items
-(BOOL)fishEat:(FUIElement *)eatenItemX
{
	//Item Collision
	if(eatenItemX->mPosition.x <= (nomArea->mPosition.x + nomArea->mSize.x) &&
       (eatenItemX->mPosition.x + eatenItemX->mSize.x) >= nomArea->mPosition.x &&
       (eatenItemX->mPosition.y + eatenItemX->mSize.y) >= nomArea->mPosition.y  &&
       eatenItemX->mPosition.y <= (nomArea->mPosition.y + nomArea->mSize.y)
	   )
	{
        //Play approriate sound effect
		if(goodEat)
			[SoundLibrary QuickPlaySound:@"sfx/coin.wav"];
		else
			[SoundLibrary QuickPlaySound:@"sfx/Negative.wav"];
		
		return YES;
	}
	return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the tap postition for the fish
	Vector2 touchVector = [[GameDriver driver] touchToGameLocation:[touches anyObject]];
	
    //Confine the position of the fish
	if(touchVector.y < kTopConfinement)
		touchVector.y = kTopConfinement;
	else if(touchVector.y > kBottomConfinement)
		touchVector.y = kBottomConfinement;
	
    // Set the begining postition for the fish
	fishModelFrame->mPosition.y = touchVector.y - fishModelFrame->mSize.y/2;
	[nomArea SetPosition:Vector3(nomArea->mPosition.x ,touchVector.y  - nomArea->mSize.y/2, 0.0f)];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get the move postition for the fish
	Vector2 touchVector = [[GameDriver driver] touchToGameLocation:[touches anyObject]];
	
    //Confine the position of the fish
	if(touchVector.y < kTopConfinement)
		touchVector.y = kTopConfinement;
	else if(touchVector.y > kBottomConfinement)
		touchVector.y = kBottomConfinement;
	
    //Update the postion of the fish with the finger movement
	fishModelFrame->mPosition.y = touchVector.y - fishModelFrame->mSize.y/2;
	[nomArea SetPosition:Vector3(nomArea->mPosition.x ,touchVector.y  - nomArea->mSize.y/2, 0.0f)];
	
	[super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Check if the user tapped the exit button
	FUIElement *exitButton = [self GetElementByName:@"plusButton"];
	Vector2 touchVector = [[GameDriver driver] touchToGameLocation:[touches anyObject]];
	if(touchVector.x > exitButton->mPosition.x && touchVector.y > exitButton->mPosition.y)
	{
		// KJB NGPipes - Intent to add friends
		[NGPipes recordFriendAddWithScreen:@"SceneFishMiniGame" wButton:@"BottomBar"];
		
		//if we are in the tutorial, nope
		if(![[UserDataManager manager] isTutorial])
			[[FUIManager sharedManager] navigateTo:SCREEN_FIND_FRIENDS];
	}
	FUIElement *closeButton = [self GetElementByName:@"closeButtonTouchZone"];
	
    if(touchVector.x > closeButton->mPosition.x && touchVector.y < closeButton->mPosition.y + closeButton->mSize.y)
	{
        //
		[UserDataManager manager].exitMiniGame = YES;
	}
	
}

// Hide the status bar
-(void)HideStatusBar
{
	[playerCoinCount SetAlpha:0];
	[playerClamCount SetAlpha:0];
	[playerXPCount SetAlpha:0];
	[playerTotalTime SetAlpha:0];
	[heart1 SetAlpha:0];
	[heart2 SetAlpha:0];
	[heart3 SetAlpha:0];
	[[self GetElementByName:@"statusbar"] SetAlpha:0];
	[[self GetElementByName:@"mediumSizedGoldCoin"] SetAlpha:0];
	[[self GetElementByName:@"mediumSizedClam"] SetAlpha:0];
	[[self GetElementByName:@"blueStar"] SetAlpha:0];	
	[[self GetElementByName:@"Time"] SetAlpha:0];	
	[[self GetElementByName:@"closeButton"] SetAlpha:0];	
}

// Render the mini game
-(void)Render
{
	//render the background
	[tile1 Render];
	[tile2 Render];
	[tile3 Render];
	
	//render the fish
	glClear(GL_DEPTH_BUFFER_BIT);//so we can be sure this is seen
    
	//disable stuff in preparation for buffer render
	[[GLStateManager manager] setVertexProperty:VERTEX_TEXCOORD toEnabled:NO];
	[[GLStateManager manager] setVertexProperty:VERTEX_POSITION toEnabled:NO];
	[[GLStateManager manager] setVertexProperty:VERTEX_COLOR toEnabled:NO];
    
	GLStateManager* glMan = [GLStateManager manager];
	
	[fishModelFrame EnterRenderSpace];
	
	[glMan pushMatrix];
	[glMan ConfigureScene:Scene3D];
	
	[glMan RequireLighting:NO];
	[glMan RequireDepth:YES];
	[glMan RequireCulling:NO];
	[glMan RequireBlending:YES mode:BlendingMasked];
	[glMan RequireTextures:YES];
	
	[glMan setVertexConstantProperty:VERTEX_COLOR byComponent1:1 c2:1 c3:1 c4:1];

	//enter 3D world
	[glMan PlaceCamera:Vector3(0,0,30) aimedAt:Vector3(0,0,0) withUpVector:Vector3(0,1,0)];
	
	[glMan scaleX:(0.8) Y:(0.8) Z:(0.8) ];
	[GLStateManager manager].offlineCameraUpdate = YES;
	
	if(0 && glMan.glesVersion == kEAGLRenderingAPIOpenGLES1)
	{
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc (GL_GEQUAL, 0.2);
	}
    
    //Render the user's fish
	render->Draw(fish);
	
	if([GLStateManager manager].glesVersion == kEAGLRenderingAPIOpenGLES2)
	{
		render->SetProgram([[GLStateManager manager] GetBaseShaderProgram]);
		[GLStateManager manager]->currentProgram = -1;//[[GLStateManager manager] GetBaseShaderProgram];
		[[GLStateManager manager] selectAppropriateShader];
	}
	
	if(0 && glMan.glesVersion == kEAGLRenderingAPIOpenGLES1)
	{
		glDisable(GL_ALPHA_TEST);
	}
	
	//undo all this
	[glMan popMatrix];
	
	[fishModelFrame LeaveRenderSpace];
    
	//rednder the menus and items
	[super Render];
	
    //show plus button again when exiting mini game
	if([UserDataManager manager].exitMiniGame){
		[self performAction:[self GetElementByName:@"plusButton"]];
	}
	
}
@end
