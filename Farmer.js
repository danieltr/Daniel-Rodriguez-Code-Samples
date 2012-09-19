//
//  Farmer.js
//  DragonCraft
//
//  Created by Daniel Rodriguez
//  Copyright 2012 Freeverse. All rights reserved.
//  
//  This class handles the troops and farmers that walk around the city.  
//

var Core		= require('../../../NGCore/Client/Core').Core;
var GL2			= require('../../../NGCore/Client/GL2').GL2;


//--------------------------------------------------------------------
// Farmer path data
//--------------------------------------------------------------------
// 0 - 28 building spots
//29 - 35 , 42 Intersections (non building spots with many available spots
//36 - 47 Paths between spots

//priorty
// 4 - spot with multiple connections
// 3 - spot with 1 connection / dead end
// 2 - non spot with >2 connections
// 1 - non spot with 2 connections or less

var PATHS = {

	0:  {position: [692, 345],  priorty:4, available: [14, 27]},
	1:  {position: [787, 605],  priorty:4, available: [14, 26, 30]},
	2:  {position: [215, 463],  priorty:4, available: [3, 28, 42]},
	3:  {position: [ 95, 442],  priorty:3, available: [2]},
	4:  {position: [105, 290],  priorty:4, available: [5, 45]},
	5:  {position: [151, 202],  priorty:4, available: [4, 6]},
	6:  {position: [205, 118],  priorty:4, available: [5, 7]},
	7:  {position: [328, 111],  priorty:4, available: [6, 31]},
	8:  {position: [589, 249],  priorty:4, available: [27, 35]},
	9:  {position: [865, 257],  priorty:4, available: [10, 36]},
	10: {position: [907, 346],  priorty:3, available: [9]},
	11: {position: [322, 420],  priorty:2, available: [42, 43]},
	12: {position: [510, 475],  priorty:2, available: [37, 43]},
	13: {position: [920, 481],  priorty:3, available: [30]},
	14: {position: [746, 481],  priorty:4, available: [0, 1]},
	15: {position: [213, 858],  priorty:3, available: [ 'mysterycave']},
	16: {position: [907, 584],  priorty:3, available: [30]},
	17: {position: [734, 905],  priorty:3, available: [20]},
	18: {position: [360, 615],  priorty:4, available: [28, 38]},
	19: {position: [580, 623],  priorty:4, available: [26, 38]},
	20: {position: [560, 924],  priorty:4, available: [17, 25, 44]},
	21: {position: [306, 935],  priorty:3, available: [44]},
	22: {position: [250, 770],  priorty:4, available: [40, 41]},
	23: {position: [ 90, 640],  priorty:4, available: [39, 40]},
	24: {position: [755, 100],  priorty:3, available: [ 'wall1']},
	25: {position: [565, 770],  priorty:3, available: [20]},
	26: {position: [655, 570],  priorty:2, available: [1, 19, 37]},
	27: {position: [645, 280],  priorty:2, available: [0, 8, 46]},
	28: {position: [260, 550],  priorty:2, available: [2, 18, 39]},
	29: {position: [360, 835],  priorty:1, available: [41, 44]},
	30: {position: [875, 570],  priorty:2, available: [1, 13, 16]},
	31: {position: [400, 130],  priorty:1, available: [7, 32]},	
	32: {position: [425, 155],  priorty:1, available: [31, 33]},	
	33: {position: [340, 240],  priorty:1, available: [32, 45]},	
	34: {position: [420, 315],  priorty:1, available: [35, 45]},	
	35: {position: [480, 310],  priorty:1, available: [8, 34]},	
	36: {position: [805, 285],  priorty:1, available: [9, 46]},	
	37: {position: [620, 495],  priorty:1, available: [12, 26]},	
	38: {position: [450, 600],  priorty:1, available: [18, 19]},	
	39: {position: [210, 580],  priorty:1, available: [23, 28]},	
	40: {position: [140, 760],  priorty:1, available: [22, 23]},
	41: {position: [310, 793],  priorty:1, available: [22, 29]},
	42: {position: [275, 440],  priorty:1, available: [2, 11]},
	43: {position: [445, 450],  priorty:1, available: [11, 12]},
	44: {position: [440, 930],  priorty:2, available: [20, 21, 29]},
	45: {position: [366, 282],  priorty:2, available: [4, 33, 34]},
	46: {position: [730, 230],  priorty:1, available: [27, 36]},
	
	array: {length:47},
};

//--------------------------------------------------------------------
// Setup the entities that walk around the city
//--------------------------------------------------------------------
var Farmer = 
{ 
	3:		{
			 name: 'Cart',size: [41, 41], angle: 0, time: 100,
			 images: ['animations/horseDrawn_cart_01.png', 
					  'animations/horseDrawn_cart_02.png', 
					  'animations/horseDrawn_cart_03.png', 
					  'animations/horseDrawn_cart_04.png', 
					  'animations/horseDrawn_cart_05.png', 
					  'animations/horseDrawn_cart_06.png', 
					  'animations/horseDrawn_cart_07.png', 
					  'animations/horseDrawn_cart_08.png', 
					  'animations/horseDrawn_cart_09.png', 
					  'animations/horseDrawn_cart_10.png', 
					  'animations/horseDrawn_cart_11.png', 
					  'animations/horseDrawn_cart_12.png']
			},
	2:		{
			 name: 'Riders', size: [26, 26], angle: 0, time: 100,
			 images: ['animations/horseRiders_0001.png', 
					  'animations/horseRiders_0002.png', 
					  'animations/horseRiders_0003.png', 
					  'animations/horseRiders_0004.png', 
					  'animations/horseRiders_0005.png', 
					  'animations/horseRiders_0006.png', 
					  'animations/horseRiders_0007.png', 
					  'animations/horseRiders_0008.png', 
					  'animations/horseRiders_0009.png', 
					  'animations/horseRiders_0010.png', 
					  'animations/horseRiders_0011.png', 
					  'animations/horseRiders_0012.png']
			},
	0:		{
			 name: 'Pikeman', size:[40, 40], angle: 0, time: 400,
			 images: ['animations/pikeman_formations_01.png', 
					  'animations/pikeman_formations_02.png']
			},
	1:		{
			 name: 'WildDog', size: [16, 10], angle: 0, time: 100,
			 images: ['animations/wildDog_0001.png', 
					  'animations/wildDog_0002.png', 
					  'animations/wildDog_0003.png', 
					  'animations/wildDog_0004.png',
					  'animations/wildDog_0005.png',
					  'animations/wildDog_0006.png']
			},
	4:		{
			 name: 'Farmer', size: [16, 16], angle: 90, time: 900,
			 images: ['animations/animated_farmer_1.png', 
					  'animations/animated_farmer_2.png']
			},
	array:	{
			 length: 2
			}
	
};

//--------------------------------------------------------------------
// create a farmer singleton
//--------------------------------------------------------------------
var theFarmer = Core.Class.singleton(
{
	initialize: function()
	{
        //Determines how fast the farmer will walk around the city
		this.FarmerAnimTime = 100;
		
	},
    
	//--------------------------------------------------------------------
	// get the angle that the farmer is walking in
	//--------------------------------------------------------------------    
	getAnlge: function(/*farmer*/farmer)
	{
		return farmer.angle;
	},
    
	//--------------------------------------------------------------------
	// Get a Farmer type based on the users level
	//--------------------------------------------------------------------    
	getFarmer: function(/*int*/level)
	{
		var rand = (Math.floor(Math.random()*(Farmer.array.length)));
		return Farmer[rand];
	},
    
	//--------------------------------------------------------------------
	// setup farmer animations
	//--------------------------------------------------------------------    
	createFarmerAnimation: function(/*farmer*/farmer)
	{	
		this.FarmerAnimTime = farmer.time + (Math.floor(Math.random()*(50)));//get a random animation time for farmer
		var anim = this._createNewAnimations(farmer, this.FarmerAnimTime);
		return anim;
	},

	//--------------------------------------------------------------------
	// get a random speed for the farmer
	//--------------------------------------------------------------------    
	getFarmerSpeed: function()
	{
		return  100 + (Math.floor(Math.random()*(100)));
	},	
    
	//--------------------------------------------------------------------
	// determine which farmer was tapped on
	//--------------------------------------------------------------------    
	targetTouched: function(/*touch*/touch)
	{
		var targets = touch.getTouchTargets();
		for(var i = 0, j=targets.length; i < j; i++)
		{
            if(targets[i].index != undefined)
			{
                return targets[i].index;
			}
		}
		return null;
											  
	},	
    
	//--------------------------------------------------------------------
	// create a farmer animation for this farmer
	//--------------------------------------------------------------------    
	_createNewAnimations: function(/*farmer*/anim, /*int*/time)
	{
		var newAnim = new GL2.Animation();
		
		for(var i = 0, j=anim.images.length; i < j; i++)
		{	
			newAnim.pushFrame(new GL2.Animation.Frame(assetPrefix() + anim.images[i], time, anim.size, [0.5, 0.5], [0, 0, 1, 1]));
		}
		
		return newAnim;
	},
											  
});

//--------------------------------------------------------------------
// Holds all of the sprite layering info
//--------------------------------------------------------------------
var SpritePriorities = require('../../Screens/CityView').SpritePriorities;

exports.Farmer = Core.MessageListener.subclass(
{
	initialize: function(/*node*/node, /*int*/amount)
	{
        //Check if the setting to show farmers is on
		this.isActive = UserInfo.getPreference("fullGraphicsFX");
		
		this.node = node; //base node farmer will be attached to
		this.spotsWithBuildings = this.getSpotsWithBuildings();//Get the spots that the user has buildings on - used to fade farmer in an out
		
		//don't include wall or mystery cave when choosing a randomspot
		this.wall1 = 24;
		this.cave = 15;
		
        this.amount = amount;//how many farmers should be mae
		this._farmerContainer; //used to holdall of the farmers

		this.hotSpotPositions = PATHS;//holds all of the paths

		//distance from a spot before fading in/out 
		this.fadeDistance = 25;
		
        //Check if it's okay to create new farmers
		if(this.isActive)
			this.createFarmers();
	},
    
    //--------------------------------------------------------------------
    // Create all of the farmers that will be walking around the city
    //--------------------------------------------------------------------
	createFarmers: function()
	{
		this._farmerContainer = new Array(this.amount); // array that contains all of the farmers
		
		for(var i = 0; i < this.amount; i++)
		{
            //setup farmer containers
			this._farmerContainer[i] = [];
			
            //what type of unit this famer is
			this._farmerContainer[i].type = theFarmer.getFarmer(Player.getCastleLevel());
			
            //angle the farmer is walking
            this._farmerContainer[i].angle = theFarmer.getAnlge(this._farmerContainer[i].type);
			
            //used to store what path's the farmer has walked down
			this._farmerContainer[i].path = [];
            
            //set the farmer speed
			this._farmerContainer[i].speed = theFarmer.getFarmerSpeed();
			
            //the previous spot the farmer was at - used so farmer doesn't walk back and forth
			this._farmerContainer[i].previousSpot = this.getRandomSpot();// The spot you were last at / spot to start from
			
            //the final destination for the farmer
            this._farmerContainer[i].mainGoal = this.getRandomSpot();//final spot
			
            //the next spot the farmer will go to
            this._farmerContainer[i].nextSpot = this.getRandomSpotFor(this._farmerContainer[i].previousSpot);//spot you're movign towards
			
            //the start point of farmer
			this._farmerContainer[i].path.start = this.getPositionAt(this._farmerContainer[i].previousSpot);//starting position
			
            //current distance to goal
            this._farmerContainer[i].path.goal = this.getPositionAt(this._farmerContainer[i].nextSpot);//next position
			
			//total distance to next spot
			var fPath = this._farmerContainer[i].path; 
            
			//how far the farmer has walked
            this._farmerContainer[i].path.distance = this.getDistance( fPath.start.position[1], fPath.goal.position[1], fPath.start.position[0], fPath.goal.position[0]);
			
            //what path is the farmer on
			this._farmerContainer[i].path.current = 0;
			
            //how much distance remains until farmer reaches next path point
            this._farmerContainer[i].path.distanceRemaining = 0;
			
            //Setup the farmer node
			this._farmerContainer[i].node = new GL2.Node();
			this._farmerContainer[i].node.setPosition( this._farmerContainer[i].path.start.position[0], this._farmerContainer[i].path.start.position[1]); // set position to starting point			
			this._farmerContainer[i].node.setDepth(SpritePriorities.buildings + this._farmerContainer[i].node.getPosition().getY()/1000);
			
            //Change the depth of the farmer if they are moving towards the castle
            if(this._farmerContainer[i].previousSpot == 11 || this._farmerContainer[i].nextSpot == 11)
            	this._farmerContainer[i].node.setDepth(SpritePriorities.buildings - 1); 
                
            this.node.addChild(this._farmerContainer[i].node);	

			//flip farmer if needed
			if(this._farmerContainer[i].path.goal.position[0] < this._farmerContainer[i].path.start.position[0])
				this._farmerContainer[i].node.setScale(-1, 1);
			
            //setup the farmer display                     					 
			this._farmerContainer[i].display = new GL2.Sprite();
			this._farmerContainer[i].display.ownAnimation(theFarmer.createFarmerAnimation(this._farmerContainer[i].type));
			this._farmerContainer[i].display.setPosition(-8,8); // set position to starting point
			this._farmerContainer[i].display.setRotation(this._farmerContainer[i].angle);					   
			this._farmerContainer[i].node.addChild(this._farmerContainer[i].display);
			
            //setup the farmers touch target
			var nodePosition = this._farmerContainer[i].node.getPosition();
			this._farmerContainer[i].toucher = new GL2.TouchTarget();
			this._farmerContainer[i].toucher.index = i;
			this._farmerContainer[i].toucher.setSize(this._farmerContainer[i].type.size);			
			this._farmerContainer[i].toucher.setDepth(-1);//make sure buildings have priority touch
			this._farmerContainer[i].toucher.setPosition(nodePosition.getX() - this._farmerContainer[i].type.size[0]/2 -8, nodePosition.getY() - this._farmerContainer[i].type.size[1]/2 + 8);					   
			this.node.addChild(this._farmerContainer[i].toucher);
			this._farmerContainer[i].toucher.getTouchEmitter().addListener(this, this.onTouchPlay);		
		}	
	},
    
    //--------------------------------------------------------------------
    // Used when the user toggles the full graphics settings
    //--------------------------------------------------------------------    
	setIsActive: function(/*bool*/bool)
	{
		if(this.isActive == bool)
			return;
		
		this.isActive = bool;
		
		if(this.isActive)
			this.createFarmers(); // if it is active create and show farmers
		else
			this.destroy();// if it is not active destroy them
	},
    
    //--------------------------------------------------------------------
    // Remove all of the farmers from the city
    //--------------------------------------------------------------------     
	destroy: function()
	{
		if(this._farmerContainer)
		{
			for(var i = 0; i < this.amount; i++)
			{
				if(this._farmerContainer[i].toucher)
				{
					this._farmerContainer[i].toucher.destroy();
					this._farmerContainer[i].toucher = null;
				}
				
				if(this._farmerContainer[i].display)
				{			
					this._farmerContainer[i].display.destroy();
					this._farmerContainer[i].display = null;
				}
				
				if(this._farmerContainer[i].node)
				{			
					this._farmerContainer[i].node.destroy();
					this._farmerContainer[i].node = null;
				}
				this._farmerContainer[i] = null;
			}
		}
		this._farmerContainer = null;
	},

    //--------------------------------------------------------------------
    // Return city spots with buildings on them
    //-------------------------------------------------------------------- 	
	getSpotsWithBuildings: function()
	{
		var cityLayout = Player.getCityLayout();
		var buildingSpots = [];
		for(var i = 0; i < cityLayout.length; i++)
		{
			var currentBuilding = cityLayout[i].builtTech;
			
			if(currentBuilding != null && currentBuilding != '' && currentBuilding != 'mysterycave' && currentBuilding != 'wall1')
			{
				buildingSpots.push(i);
			}
		}
		
		return buildingSpots;
	},

    //--------------------------------------------------------------------
    // Used to see if farmer needs to fade in an out
    //-------------------------------------------------------------------- 	
	checkForSpot: function(/*array*/spotsToCheck, /*int*/spot) 
    {
		for(var i=0; i<spotsToCheck.length; i++) 
        {
			if (spotsToCheck[i] == spot) 
				return true;
		}
		return false
	},

    //--------------------------------------------------------------------
    // Used to see if farmer needs to fade in an out
    //--------------------------------------------------------------------	
	isSpotSafe: function(/*int*/spot, /*int*/farmerIndex)
	{
		if(spot == this._farmerContainer[farmerIndex].previousSpot)// don't return to previous slot
			return false;
		else if(this.hotSpotPositions[spot].priorty == 3)// Dead end and not goal
			return false;
		else
			return true;
	},
    
    //--------------------------------------------------------------------
    // Check if the spot is the main goal
    //--------------------------------------------------------------------    
	isSpotGoal: function(/*int*/spot, /*int*/farmerIndex)
	{
		return (spot == this._farmerContainer[farmerIndex].mainGoal);
	},
    
    //--------------------------------------------------------------------
    // Used to see if farmer needs to fade in an out
    //--------------------------------------------------------------------
	getPositionAt:function(/*int*/spot)
	{
		return this.hotSpotPositions[spot];
	},
    
    //--------------------------------------------------------------------
    // Get a new random spot for farmer
    //--------------------------------------------------------------------    
	getRandomSpot: function()
	{	
		var randSpot = this.spotsWithBuildings[Math.floor(Math.random()*(this.spotsWithBuildings.length))];
		
		while (randSpot == this.wall1 || randSpot == this.cave)//prevent it from picking mystery cave or wall1
			randSpot = this.spotsWithBuildings[Math.floor(Math.random()*(this.spotsWithBuildings.length))];
		
		return randSpot;
	},
    
    //--------------------------------------------------------------------
    // Used to see if farmer needs to fade in an out
    //--------------------------------------------------------------------    
	getRandomSpotFor: function(/*int*/spot)
	{
		var availableSlots = this.hotSpotPositions[spot].available;
		var randomSpot = (Math.floor(Math.random()*(availableSlots.length)));
		return availableSlots[randomSpot];
	},
    
    //--------------------------------------------------------------------
    // Get the next random spot the farmer should walk to
    //--------------------------------------------------------------------       
	getNextRandomSpotFor:function(/*int*/spot, /*int*/index)
	{	
		var availableSlots = this.hotSpotPositions[spot].available;
		var realSlots = [];
		//Check if any are the main goal
		for(var i = 0; i < availableSlots.length; i++)
        {
            //done checking reached goal
			if(availableSlots[i] == this._farmerContainer[index].mainGoal)
            {
				//farmer reached his goal "Good, Bad, I'm the guy with the gun!"
				this._farmerContainer[index].mainGoal = this.getRandomSpot();
				return availableSlots[i];
			}
            else if (this.isSpotSafe(availableSlots[i], index))
            {
				realSlots.push(availableSlots[i]);//farmer move to spots
			}
		}
		
		var randomSpot = (Math.floor(Math.random()*(realSlots.length)));
		var nexSpot = realSlots[randomSpot];
		
		if(nexSpot  === undefined)
        {
			//farmer most likley got stuck in limbo, filled with regret, waiting to die alone
			return this._farmerContainer[index].previousSpot;
		}
		return nexSpot;
		
	},	
    
    //--------------------------------------------------------------------
    // Animate the farmer
    //--------------------------------------------------------------------       
	animate: function(/*float*/delta)
	{
        //if farmers are not active, then do nothing
		if(this.isActive)
		{
            //if there are no farmers, stop right here
			if(!this._farmerContainer)
				return;
                
			for(var i = 0; i < this.amount; i++)
            {
                //setup containers for this particular farmer
				this._deltaX = delta;
				this._deltaY = delta;					 
                this.startingPoint = this._farmerContainer[i].path.start;
				this.goalPoint =  this._farmerContainer[i].path.goal;
				var currentX = this._farmerContainer[i].node.getPosition().getX();
				var currentY = this._farmerContainer[i].node.getPosition().getY();

                //determines at what ratio the farmer needs to move in the x and y directions 
                var xRatio = Math.abs((this.goalPoint.position[0] - currentX)/(this.goalPoint.position[0] - this.startingPoint.position[0]));
				var yRatio = Math.abs((this.goalPoint.position[1] - currentY)/(this.goalPoint.position[1] - this.startingPoint.position[1]));

                //check if the farmer has reached the x position of the goal point and setup up the move delta
				if(this.startingPoint.position[0] > this.goalPoint.position[0])
				{
					if(currentX <= this.goalPoint.position[0])
						this._deltaX = 0;
					else
						this._deltaX = -delta;						
				}
                else if(currentX >= this.goalPoint.position[0])
					this._deltaX = 0;	
                
                //check if the farmer has reached the y position of the goal point and setup up the move delta
				if(this.startingPoint.position[1] > this.goalPoint.position[1])	
				{
					if(currentY <= this.goalPoint.position[1])
						this._deltaY = 0;
					else
						this._deltaY = -delta;
				}
                else if(currentY >= this.goalPoint.position[1])
					this._deltaY = 0;
				
                //use the ratio that is higher on both the x and y delta
				if(xRatio > yRatio)
					this._deltaY *= yRatio;
				else
					this._deltaX *= xRatio;

				//Check if the famer reached his goal and set a new one if he has					 
				if(!this._deltaX || !this._deltaY)
				{
					this._farmerContainer[i].node.setPosition(this.goalPoint.position[0],this.goalPoint.position[1]);	
					this._farmerContainer[i].toucher.setPosition(this.goalPoint.position[0] - this._farmerContainer[i].type.size[0]/2 -8, this.goalPoint.position[1] - this._farmerContainer[i].type.size[1]/2 + 8);
					
					var current = this._farmerContainer[i].nextSpot;
					this._farmerContainer[i].nextSpot = this.getNextRandomSpotFor(this._farmerContainer[i].nextSpot, i);
					this._farmerContainer[i].previousSpot = current;

					this._farmerContainer[i].path.start = this.goalPoint;
					this._farmerContainer[i].path.goal	= this.getPositionAt(this._farmerContainer[i].nextSpot);
					
					//flip farmer if needed
					var xScale = -1;
					if(this._farmerContainer[i].path.goal.position[0] < this._farmerContainer[i].path.start.position[0])
                    {
						this._farmerContainer[i].node.setScale(-1, 1);
						xScale = 1;
					}else
						this._farmerContainer[i].node.setScale( 1, 1);
					
					//total distance to next spot
					var fPath = this._farmerContainer[i].path; 
					this._farmerContainer[i].path.distance = this.getDistance( fPath.start.position[1], fPath.goal.position[1], fPath.start.position[0], fPath.goal.position[0]);
		
				}
                //Continue moving this farmer along the path
				else
                {
					var fPath = this._farmerContainer[i].path;
					this._farmerContainer[i].path.current = this.getDistance( currentY, fPath.start.position[1], currentX, fPath.start.position[0])
					this._farmerContainer[i].path.distanceRemaining = this._farmerContainer[i].path.distance - this._farmerContainer[i].path.current;
					
					//check if the next or previous spots have a building on it, and fade if needed
					this.fadeFarmer(this._farmerContainer[i], this._farmerContainer[i].path.current, this.fadeDistance, this._farmerContainer[i].path.distance);
				
					var positionX = currentX + this._deltaX/this._farmerContainer[i].speed;
					var positionY = currentY + this._deltaY/this._farmerContainer[i].speed;
					
					this._farmerContainer[i].node.setPosition(positionX, positionY);
					this._farmerContainer[i].node.setDepth(SpritePriorities.buildings + positionY/1000);
                    
                    if(this._farmerContainer[i].previousSpot == 11 || this._farmerContainer[i].nextSpot == 11)
                        this._farmerContainer[i].node.setDepth(SpritePriorities.buildings - 1);                     
					
					this._farmerContainer[i].toucher.setPosition(positionX - this._farmerContainer[i].type.size[0]/2 -8, positionY - this._farmerContainer[i].type.size[1]/2 + 8);
				}
			}						 
		}
	},

    //--------------------------------------------------------------------
    // fade the farmer in or out
    //--------------------------------------------------------------------	
	fadeFarmer: function( /*farmer*/farmer, /*float*/distance, /*int*/fadeDistance, /*float*/totalDistance){
		if(distance <= fadeDistance && this.hotSpotPositions[farmer.previousSpot].priorty >= 3 && 
		   this.checkForSpot(this.spotsWithBuildings, farmer.previousSpot)){ 
			farmer.display.setAlpha(distance/fadeDistance);
		}else if((totalDistance - distance) <= fadeDistance && this.hotSpotPositions[farmer.nextSpot].priorty >= 3 && 
			 this.checkForSpot(this.spotsWithBuildings, farmer.nextSpot)){
			//fade out
			farmer.display.setAlpha((totalDistance - distance)/fadeDistance);
		}
	},
    
    //--------------------------------------------------------------------
    // Get a new angle for the farmer
    //--------------------------------------------------------------------    
	getNewAngle: function( /*int*/start, /*int*/goal, /*float*/xScale)
	{	
		var dy = (start.position[1] - goal.position[1]);
		var dx = (start.position[0] - goal.position[0]);
		var angle = Math.atan2(dx, dy);

		angle = angle*(180/Math.PI);
		angle = MoreMath.clamp(angle, -10, 10) 

		return angle;
	},
    
    //--------------------------------------------------------------------
    // get the distance needed to get to the next spot
    //--------------------------------------------------------------------	
	getDistance: function(/*float*/y1,/*float*/y2,/*float*/x1,/*float*/x2)
	{
		var aSquared = (y2 - y1) * (y2 - y1);
		var bSquared = (x2 - x1) * (x2 - x1);
		
		return Math.sqrt(aSquared + bSquared);
	},

    //--------------------------------------------------------------------
    // Play sound effects when a farmer is tapped 
    //--------------------------------------------------------------------	
	onTouchPlay: function(/*touch*/touch)
	{
		switch(touch.getAction())
		{
			case touch.Action.Start:
				if(this._farmerContainer[theFarmer.targetTouched(touch)].type.name  == "Riders")
					SoundManager.playSoundAndWait(SoundManager.SoundEffect.SpriteHorse);			
				else if(this._farmerContainer[theFarmer.targetTouched(touch)].type.name  == "WildDog")
					SoundManager.playSoundAndWait(SoundManager.SoundEffect.SpriteDog);			
				else
					SoundManager.playSoundAndWait(SoundManager.SoundEffect.SpriteTroops);	
		
			  return true;									  
			  break;
			case touch.Action.Move:
			  return true;
			  break;	  	
			case touch.Action.End:
			  return true;									  
			  break;	
		}
	},								 
});

