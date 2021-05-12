//==============================================================================
// InfiniteAI
// InfiniteAIGPs.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// This is the basic logic behind the casting of the various god powers
// Although some are rule driven, much of the complex searches and casting logic
// is handled by the C++ code.
//==============================================================================
// *****************************************************************************
//
// An explanation of some of the plan types, etc. in this file:
//
// aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModel...
//   CombatDistance - This is the standard one.  The plan will get attached to an 
//   attack plan, and the attack plan performs a query, and when the number and 
//   type of enemy units you specify are within the specified distance of the 
//   attack plan's location, the god power will go off. 
//
//   CombatDistancePosition - *doesn't* get attached to an attack plan.  
//   You specify a position, and when the number and type of enemy units are within 
//   distance of that position, the power goes off.  This, for instance, could see 
//   if there are many enemy units around your town center. 
//
//   CombatDistanceSelf - this one's kind of particular.  It gets attached to an 
//   attack plan.  The query you specify in the setup determines the number and 
//   type of *friendly* units neccessary to satisfy the evaluation.  Addtionally, 
//   there must be at least 5 (currently hardcoded) enemy units within the distance 
//   value of the attack plan for it to be successful.  Then the power will go off.  
//   This is typicaly used for powers that improve friendly units, like bronze, 
//   flaming weapons, and eclipse.  
//
// *****************************************************************************
//==============================================================================

//==============================================================================
bool setupGodPowerPlan(int planID = -1, int powerProtoID = -1)
{
    if (planID == -1)
	return (false);
    if (powerProtoID == -1)
	return (false);
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    aiPlanSetBaseID(planID, mainBaseID);
	
    //-- setup prosperity
    //-- This sets up the plan to cast itself when there are 12 people working on gold //
    if (powerProtoID == cPowerProsperity)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
        aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceGold);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);
	}
	
    //-- setup plenty
    //-- we want this to cast in our town when we have 20 or more workers in the world
    if (powerProtoID == cPowerPlenty)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
        //-- override the default building placement distance so that plenty has some room to cast
        //-- it is pretty big..
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 140.0);
        return (true);
	}
	
    //-- setup the serpents power
    if (powerProtoID == cPowerPlagueofSerpents)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the lure power
    //-- cast this in your town as soon as we have more than 3 huntable resources found, and towards that huntable stuff if we know about it
    if (powerProtoID == cPowerLure)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        int queryID=kbUnitQueryCreate("Huntable Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerID(queryID, 0);
        kbUnitQuerySetUnitType(queryID, cUnitTypeHuntable);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);
        //-- now set up the targeting and the influences for targeting
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
		
        //-- this one gets special influences (maybe)
        //-- set up from a simple query
        //-- we also prevent the default "back of town" placement
        aiPlanSetVariableInt(planID, cGodPowerPlanBPLocationPreference, 0, cBuildingPlacementPreferenceNone);
		
        vector v = kbUnitGetPosition(findClosestUnitTypeByLoc(cPlayerRelationAny, cUnitTypeHuntable, cUnitStateAlive, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), 85));
        aiPlanSetVariableVector(planID, cGodPowerPlanBPInfluence, 0, v);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceValue, 0, 300.0);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceDistance, 0, 100.0);
        return (true);  
	}
	
    //-- setup the pestilence power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 50 meters, and at least 5 buildings must be found
    //-- this works on buildings
    if (powerProtoID == cPowerPestilence)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitaryBuilding);
        return (true);  
	}
	
    //-- setup the bronze power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 10 meters
    if (powerProtoID == cPowerBronze) 
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        return (true);  
	}
	
    //-- setup the earthquake power
    if (powerProtoID == cPowerEarthquake)
    {
        gHeavyGPTechID = cTechEarthquake;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
		
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);  
	}
	
	//==============================================================================
	// Citadel power
	//==============================================================================	
    //-- setup the Citadel power
    //-- disabled auto casting, cast when under attack
    if (powerProtoID == cPowerCitadel)
    {
        fCitadelPlanID = planID;
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
        xsEnableRule("rCitadel");
        return (true);  
	}	
	//==============================================================================
	
	//==============================================================================
	// Shifting Sands Power
	//==============================================================================
	if (powerProtoID == cPowerShiftingSands)
	{
		gShiftingSandPlanID = planID;
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
		xsEnableRule("rShiftingSand");
		return (true);
	}
	//==============================================================================
	
    //-- setup the dwarven mine
    if (powerProtoID == cPowerDwarvenMine)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
        //-- set up the global
        gDwarvenMinePlanID = planID;
        //-- enable the monitoring rule
        xsEnableRule("rDwarvenMinePower");
        return (true);  
	}
	
    //-- setup the curse power
    if (powerProtoID == cPowerCurse)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the Eclipse power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 50 meters, and at least 5 archers must be found
    //-- this works on buildings
    if (powerProtoID == cPowerEclipse)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 3);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMythUnit);
        return (true);  
	}
	
    //-- setup the flaming weapons
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 10 meters
    if (powerProtoID == cPowerFlamingWeapons) 
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeValidFlamingWeaponsTarget);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        return (true);  
	}
	
    //-- setup the Forest Fire power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 40 meters
    if (powerProtoID == cPowerForestFire)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,cGodPowerPlanDistance, 0, 40.0);
        aiPlanSetVariableInt(planID,  cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractSettlement);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        return (true); 
	}
	
    //-- setup the frost power
    if (powerProtoID == cPowerFrost)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the healing spring power
    //-- cast this within 75 meters of the military gather 
    if (powerProtoID == cPowerHealingSpring)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 75.0);
        return (true);  
	}
	
    //-- setup the lightening storm power
    if (powerProtoID == cPowerLightningStorm)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the locust swarm power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 50 meters, and at least 3 farms must be found
    //-- this works on buildings
    if (powerProtoID == cPowerLocustSwarm)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractFarm);
        return (true);  
	}
	
    //-- setup the Meteor power
    if (powerProtoID == cPowerMeteor)
    {
        gHeavyGPTechID = cTechMeteor;
        gHeavyGPPlanID = planID;
		if (cMyCiv != cCivSet)
        xsEnableRule("castHeavyGP");
        else xsEnableRule("SetSpecialGP");
        
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);  
	}
	
    //-- setup the Nidhogg power
    //-- cast this in your town immediately
    if (powerProtoID == cPowerNidhogg)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
        return (true);  
	}
	
    //-- setup the Restoration power
    if (powerProtoID == cPowerRestoration)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the Sentinel power
    //-- disabled auto casting, cast when under attack
    if (powerProtoID == cPowerSentinel)
    {
        gSentinelPlanID = planID;
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
        xsEnableRule("rSentinel");
        return (true);  
	}
	
    //-- setup the Ancestors power
    if (powerProtoID == cPowerAncestors)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the Fimbulwinter power
    //-- cast this in your town immediately
    if (powerProtoID == cPowerFimbulwinter)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
	}
	
    //-- setup the Tornado power
    if (powerProtoID == cPowerTornado)
    {
        gHeavyGPTechID = cTechTornado;
        gHeavyGPPlanID = planID;
		if (cMyCiv != cCivSet)
        xsEnableRule("castHeavyGP");
        else xsEnableRule("SetSpecialGP");
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);  
	}
	
    //-- setup Undermine
	//-- this power will cast when it has a valid attack plan within the specified range
	//-- the attack plan is setup in the initializeAttack function  
	//-- the valid distance is 50 meters, and at least 3 wall segments must be found
	//-- this works on buildings
	if (powerProtoID == cPowerUndermine)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 3);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractWall);
		return (true);  
	}
	
	//-- setup the great hunt
	//-- this power makes use of the KBResource evaluation condition
	//-- to find the best huntable kb resource with more than 200 total food.
	if (powerProtoID == cPowerGreatHunt)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelKBResource);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
		aiPlanSetVariableInt(planID,  cGodPowerPlanResourceType, 0, cResourceFood);
		aiPlanSetVariableInt(planID,  cGodPowerPlanResourceSubType, 0, cAIResourceSubTypeEasy);
        vector v2 = kbUnitGetPosition(findClosestUnitTypeByLoc(cPlayerRelationAny, cUnitTypeHuntable, cUnitStateAlive, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
        aiPlanSetVariableVector(planID, cGodPowerPlanBPInfluence, 0, v2);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceValue, 0, 300.0);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceDistance, 0, 150.0);		
		aiPlanSetVariableBool(planID,  cGodPowerPlanResourceFilterHuntable, 0, true);
		aiPlanSetVariableFloat(planID, cGodPowerPlanResourceFilterTotal, 0, 300.0);
		return (true);  
	}
	
    //-- setup the bolt power
    //-- cast this on the first unit with over 810 hit points
	
    if (powerProtoID == cPowerBolt)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Bolt Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerID(queryID, aiGetMostHatedPlayerID());
        kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 810.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
        return (true);  
	}
	
	//-- setup the spy power
    if (powerProtoID == cPowerSpy)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Spy Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerRelation(cPlayerRelationEnemy);
        kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
		
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
        return (true);  
	}
	
    //-- setup the Son of Osiris
    if (powerProtoID == cPowerSonofOsiris)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Osiris Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerID(queryID, cMyID);
        kbUnitQuerySetUnitType(queryID, cUnitTypePharaoh);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
		
		if (gGatherRelicType == cUnitTypePharaoh)
		aiPlanDestroy(gRelicGatherPlanID);
		
        return (true);  
	}
	
    //-- setup the vision power
    if (powerProtoID == cPowerVision)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        return (false);  
	}
	
    //-- setup the rain power to cast when we have at least 14 farms // Upped to 14 by Reth
    if (powerProtoID == cPowerRain)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Rain Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerID(queryID, cMyID);
        kbUnitQuerySetUnitType(queryID, cUnitTypeFarm);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 14);
		
        return (true);  
	}
	
    //-- setup Cease Fire
    //-- This sets up the plan to not cast itself
    //-- we also enable a rule that monitors the state of the player's main base
    //-- and waits until the base is under attack and has no defenders
    if (powerProtoID == cPowerCeaseFire)
    { 
        gCeaseFirePlanID = planID;
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        xsEnableRule("rCeaseFire");
        return (true);
	}
	
	
    //-- setup the Walking Woods power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 10 meters
    if (powerProtoID == cPowerWalkingWoods) 
    {
        //-- basic plan type and eval model
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		
        //-- setup the nearby unit type to cast on
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeTree);
		
        //-- finish setup
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        return (true); 
	}
	
	
    //-- setup the Ragnorok Power
    if (powerProtoID == cPowerRagnorok)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
		
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        gRagnorokPlanID = planID;
        xsEnableRule("rRagnorokPower");
        return (true);  
	}
	
    
    // Set up the Gaia Forest power
    if (powerProtoID == cPowerGaiaForest)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        //-- set up the global
        gGaiaForestPlanID = planID;
        //-- enable the monitoring rule
        xsEnableRule("rGaiaForestPower");
        return (true);
	}
	
    // Set up the Thunder Clap power
    if (powerProtoID == cPowerTremor)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
    // Set up the deconstruction power
    // Any building over 500 HP counts, cast it on building
    if (powerProtoID == cPowerDeconstruction)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Deconstruction Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
        kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeValidDeconstructionTarget);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);      
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
    // Set up the Carnivora power
    if (powerProtoID == cPowerCarnivora)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
    // Set up the Spiders power
    if (powerProtoID == cPowerSpiders)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
    // Set up the heroize power
    // Any time we have a group of 6 or more military units
    if (powerProtoID == cPowerHeroize)
    {
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 20.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
    // Set up the chaos power
    if (powerProtoID == cPowerChaos)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
	
    // Set up the Traitors power
    // Same as bolt, anything over 200 HP
    if (powerProtoID == cPowerTraitors)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
        //-- create the query used for evaluation
        queryID=kbUnitQueryCreate("Traitors Evaluation");
        if (queryID < 0)
		return (false);
		
        kbUnitQueryResetData(queryID);
        kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
        kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
        kbUnitQuerySetState(cUnitStateAlive);
		
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);  
	}
	
    // Set up the hesperides power
    // Near the military gather point, for good protection
    if (powerProtoID == cPowerHesperides)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 25.0);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        //-- set up the global
        gHesperidesPlanID = planID;
        //-- enable the monitoring rule
        xsEnableRule("rHesperidesPower");
        return (true);
	}
	
    // Set up the implode power
    if (powerProtoID == cPowerImplode)
    {
        gHeavyGPTechID = cTechImplode;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
        
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);
	}
	
    // Set up the tartarian gate power
    // Fire if >= 4 military buildings near my army...will kill my army, but may take out their center, too.
    if (powerProtoID == cPowerTartarianGate)
    {
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		gHeavyGPTech=cTechTartarianGate;
		gHeavyGPPlan=planID;
		xsEnableRule("rCastHeavyGP");
		return (true);
	}
	
    // Set up the vortex power
    if (powerProtoID == cPowerVortex)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
	}
	
	
	// Chinese GPS, copy paste from WarriorMario  ////////////
	
	// Set up the Barrage power
	// 20 enemy military units within 30m of attack plan
	if(powerProtoID == cPowerBarrage)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	// Set up the Call to Arms power
	// If we have a group of 10 or more military units. Lets hope there is a mythunit present
	if(powerProtoID == cPowerCallToArms)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		return (true);  
	}
	// Set up the Earth Dragon power
	// Near enemies?
	if(powerProtoID == cPowerEarthDragon)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
		return (true);
	}
	// Set up the Examination power
	if(powerProtoID == cPowerExamination)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
		//-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Examination Evaluation");
		if (queryID < 0)
		return (false);
		
		kbUnitQueryResetData(queryID);
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
		kbUnitQuerySetState(cUnitStateAlive);
		
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		
		gExaminationID = planID;
		xsEnableRule("rCastExamination");
		return (true);   
	}
	// Set up the Geyser power
	// Atleast 15 enemies lets hope we can get an army at once
	// And we can place it nearby our army as we cannot be damaged by it (range is 10m)
	if(powerProtoID == cPowerGeyser)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 10.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);  
	}
	// Set up the Inferno power
	// Atleast 25 enemies
	// Dangerous for us too (range is 50 and not in our base!)
	if(powerProtoID == cPowerInferno)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
		return (true);  
	}
	// Set up the Journey power
	// At least 70 units
	if(powerProtoID == cPowerJourney)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		
		//-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Journey Evaluation");
		if (queryID < 0)
		return (false);
		
		kbUnitQueryResetData(queryID);
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeUnitsNotBuildings);
		kbUnitQuerySetState(cUnitStateAlive);
		
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 70);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
		
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);   
	}
	// Set up the Recreation power
	// Or actually destroy the plan and use painful manual casting
	if(powerProtoID == cPowerRecreation)
	{
		aiPlanDestroy(planID);
		xsEnableRule("rRecreation");
		return (false);  
	}
	// Set up the Timber Harvest power
	// We want 12 villagers on wood
	if(powerProtoID == cPowerTimberHarvest)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
		aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceWood);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);
	}
	// Set up the Tsunami power
	// Or actually destroy the plan and use painful manual casting
	if(powerProtoID == cPowerTsunami)
	{
		xsEnableRule("Tsunami");
		return (false);  
	}
	
	// Set up the Uproot power
	if(powerProtoID == cPowerUproot)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingNotTitanGate);
		return (true);  
	}
	// Set up the Year of the Goat power
	// Or actually destroy the plan and use manual casting
	if(powerProtoID == cPowerYearOfTheGoat)
	{
		xsEnableRule("rYearOfTheGoat");
		return (false);  
	}
	
	return (false);
}
//==============================================================================
void initGodPowers(void)    //initialize the god power module
{
	if ((cMyCiv == cCivGaia) && (gTransportMap == false))
	xsSetRuleMinInterval("rAge1FindGP", 1);
    xsEnableRule("rAge1FindGP");
}

//==============================================================================
rule rAge1FindGP
minInterval 12 //starts in cAge1
inactive
{
    int id=aiGetGodPowerTechIDForSlot(0); 
    if ((id == -1) || (gpDelayMigration == true) && (kbGetAge() < cAge2))
	return;
	
    gAge1GodPowerID=aiGetGodPowerProtoIDForTechID(id);
	
    gAge1GodPowerPlanID=aiPlanCreate("Age1GodPower", cPlanGodPower);
    if (gAge1GodPowerPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
	}
	
    aiPlanSetVariableInt(gAge1GodPowerPlanID,  cGodPowerPlanPowerTechID, 0, id);
    aiPlanSetDesiredPriority(gAge1GodPowerPlanID, 100);
    aiPlanSetEscrowID(gAge1GodPowerPlanID, -1);
	
    //Setup the god power based on the type.
    if (setupGodPowerPlan(gAge1GodPowerPlanID, gAge1GodPowerID) == false)
    {
        aiPlanDestroy(gAge1GodPowerPlanID);
        gAge1GodPowerID=-1;
        xsDisableSelf();
        return;
	}
	
    if (cvOkToUseAge1GodPower == true)
	aiPlanSetActive(gAge1GodPowerPlanID);
	
    xsDisableSelf();
}

//==============================================================================
rule rAge2FindGP
minInterval 12 //starts in cAge2
inactive
{
    //Figure out the age2 god power and create the plan.
    int id=aiGetGodPowerTechIDForSlot(1); 
    if (id == -1)
	return;
	
    gAge2GodPowerID=aiGetGodPowerProtoIDForTechID(id);
	
    //Create the plan.
    gAge2GodPowerPlanID=aiPlanCreate("Age2GodPower", cPlanGodPower);
    if (gAge2GodPowerPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
	}
	
    aiPlanSetVariableInt(gAge2GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
    aiPlanSetDesiredPriority(gAge2GodPowerPlanID, 100);
    aiPlanSetEscrowID(gAge2GodPowerPlanID, -1);
	
    //Setup the god power based on the type.
    if (setupGodPowerPlan(gAge2GodPowerPlanID, gAge2GodPowerID) == false)
    {
        aiPlanDestroy(gAge2GodPowerPlanID);
        gAge2GodPowerID = -1;
        xsDisableSelf();
        return;
	}
	
    if (cvOkToUseAge2GodPower == true)
	aiPlanSetActive(gAge2GodPowerPlanID);
	
    xsDisableSelf();
}

//==============================================================================
rule rAge3FindGP
minInterval 12 //starts in cAge3
inactive
{
    //Figure out the age3 god power and create the plan.
    int id=aiGetGodPowerTechIDForSlot(2); 
    if (id == -1)
	return;
	
    gAge3GodPowerID=aiGetGodPowerProtoIDForTechID(id);
	
    //Create the plan
    gAge3GodPowerPlanID=aiPlanCreate("Age3GodPower", cPlanGodPower);
    if (gAge3GodPowerPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
	}
	
    aiPlanSetVariableInt(gAge3GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
    aiPlanSetDesiredPriority(gAge3GodPowerPlanID, 100);
    aiPlanSetEscrowID(gAge3GodPowerPlanID, -1);
	
    //Setup the god power based on the type.
    if (setupGodPowerPlan(gAge3GodPowerPlanID, gAge3GodPowerID) == false)
    {
        aiPlanDestroy(gAge3GodPowerPlanID);
        gAge3GodPowerID = -1;
        xsDisableSelf();
        return;
	}
	
    if (cvOkToUseAge3GodPower == true)
	aiPlanSetActive(gAge3GodPowerPlanID);
	
    xsDisableSelf();
}

//==============================================================================
rule rAge4FindGP
minInterval 12 //starts in cAge4
inactive
{
    //Figure out the age4 god power and create the plan.
    int id = aiGetGodPowerTechIDForSlot(3); 
    if (id == -1)
	return;
	
    gAge4GodPowerID=aiGetGodPowerProtoIDForTechID(id);
	
    //Create the plan.
    gAge4GodPowerPlanID=aiPlanCreate("Age4GodPower", cPlanGodPower);
    if (gAge4GodPowerPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
	}
	
    aiPlanSetVariableInt(gAge4GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
    aiPlanSetDesiredPriority(gAge4GodPowerPlanID, 100);
    aiPlanSetEscrowID(gAge4GodPowerPlanID, -1);
	
    //Setup the god power based on the type.
    if (setupGodPowerPlan(gAge4GodPowerPlanID, gAge4GodPowerID) == false)
    {
        aiPlanDestroy(gAge4GodPowerPlanID);
        gAge4GodPowerID=-1;
        xsDisableSelf();
        return;
	}
	
    if (cvOkToUseAge4GodPower == true)
	aiPlanSetActive(gAge4GodPowerPlanID);
	
    xsDisableSelf();
}

//==============================================================================
rule rCeaseFire
minInterval 35 //starts in cAge2
inactive
{
    static int defCon=0;
    bool nowUnderAttack=kbBaseGetUnderAttack(cMyID, kbBaseGetMainID(cMyID));
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    //Not in a state of alert.
    if (defCon == 0)
    {
        //Just get out if we are safe.
        if (nowUnderAttack == false)
		return;  
        //Up the alert level and come back later.
        defCon=defCon+1;
        return;
	}
	
    //If we are no longer under attack and below this point, then reset and get out.
    if (nowUnderAttack == false)
    {
        defCon=0;
        return;
	}
	int NumAllyMilUnits = getNumUnitsByRel(cUnitTypeMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, mainBaseLocation, 85.0);
    //If there are still allies in the area, then just stay at this alert level.
    if (NumAllyMilUnits > 0)
	return;
	
    //Defcon 2.  Cast the god power.	
    aiPlanSetVariableBool(gCeaseFirePlanID, cGodPowerPlanAutoCast, 0, true); 
    xsDisableSelf();
}

//==============================================================================
rule rUnbuild
minInterval 12 //starts in cAge1
inactive
{
	
    //Create the plan.
    gUnbuildPlanID = aiPlanCreate("Unbuild", cPlanGodPower);
    if (gUnbuildPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
	}
	
    aiPlanSetDesiredPriority(gUnbuildPlanID, 100);
    aiPlanSetEscrowID(gUnbuildPlanID, -1);
    //Setup the plan.. 
    // these are first pass.. fix these eventually.. 
    aiPlanSetVariableBool(gUnbuildPlanID, cGodPowerPlanAutoCast, 0, true); 
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnbuild);
    aiPlanSetVariableFloat(gUnbuildPlanID,  cGodPowerPlanDistance, 0, 40.0);
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingsNotWalls);
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanCount, 0, 5);
	
    aiPlanSetActive(gUnbuildPlanID);
    xsDisableSelf();
}

//==============================================================================
void gpAge2Handler(int age=1)
{
    xsEnableRule("rAge2FindGP");
}

//==============================================================================
void gpAge3Handler(int age=2)
{
    xsEnableRule("rAge3FindGP");  
}

//==============================================================================
void gpAge4Handler(int age=3)
{
    xsEnableRule("rAge4FindGP");
}

//==============================================================================
rule rDwarvenMinePower
minInterval 109 //starts in cAge1
inactive
{
    if (gDwarvenMinePlanID == -1)
    {
        xsDisableSelf();
        return;
	}
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numGoldMinesNearMBInR85 = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, mainBaseLocation, 85.0);
    //Are we in the third age yet? If not cast it only if there are no gold mines in range
    if ((kbGetAge() <= cAge3) && (numGoldMinesNearMBInR85 > 0))
	return;
	
    aiPlanSetVariableBool(gDwarvenMinePlanID, cGodPowerPlanAutoCast, 0, true);
	
    //Finished.
    gDwarvenMinePlanID = -1;
    xsDisableSelf();
}

//==============================================================================
void unbuildHandler(void)
{
    xsEnableRule("rUnbuild");
}

//==============================================================================
rule rPlaceTitanGate
minInterval 11 //starts in cAge5
inactive
{
    //Figure out the age 5 (yes, 5) god power and create the plan.
    int id = aiGetGodPowerTechIDForSlot(4); 
    if (id == -1)
	return;
	
    gAge5GodPowerID=aiGetGodPowerProtoIDForTechID(id);
	
    //Create the plan.
    gPlaceTitanGatePlanID = aiPlanCreate("PlaceTitanGate", cPlanGodPower);
    if (gPlaceTitanGatePlanID == -1)
    {
		// TODO: does this work at all?
        xsSetRuleMinIntervalSelf(127);
        return;
	}
	
    // Set the Base
    aiPlanSetBaseID(gPlaceTitanGatePlanID, kbBaseGetMainID(cMyID));
	
    aiPlanSetVariableInt(gPlaceTitanGatePlanID,  cGodPowerPlanPowerTechID, 0, id);
    aiPlanSetDesiredPriority(gPlaceTitanGatePlanID, 100);
    aiPlanSetEscrowID(gPlaceTitanGatePlanID, -1);
	
    //Setup the plan.. 
    aiPlanSetVariableBool(gPlaceTitanGatePlanID, cGodPowerPlanAutoCast, 0, true); 
    aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
    aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanCount, 0, 6);
    aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
    //-- override the default building placement distance so that the Titan Gate has some room to cast
    //-- it is pretty big..
    aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 110.0);
    aiPlanSetActive(gPlaceTitanGatePlanID);
    xsDisableSelf();
}

//==============================================================================
rule rSentinel
minInterval 15 //starts in cAge1
inactive
{
    int planID=gSentinelPlanID;
    bool Ally = true;
    if ((aiRandInt(2) < 1) || (IhaveAllies == false))
    Ally = false;
  
    int settlementFound= 0;
    if (Ally == true)
	settlementFound = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly);
	else
    settlementFound = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	
    if (settlementFound < 1)
	return;
	int baseID = -1;
	
    for (i=0; < settlementFound)
    {
        int unitID = -1; 
	    if (Ally == true)
		unitID = findUnitByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly);
	    else
		unitID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive);	
	    vector unitLoc = kbUnitGetPosition(unitID);	
	    int enemyMilUnits = getNumUnitsByRel(cUnitTypeMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 32.0, true);
        if ((enemyMilUnits > 4) && (unitID != -1))
        {
            baseID = kbUnitGetBaseID(unitID);
            break;
		}
	}
	
    if (baseID != -1)
    {
        if (aiCastGodPowerAtUnit(cTechSentinel, unitID) == true)
        {
            aiPlanSetBaseID(planID, baseID);
            aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
            aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
            aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
            xsDisableSelf();
		}
	}
}

//==============================================================================
rule rRagnorokPower
minInterval 13 //starts in cAge4
inactive
{
	
    if (gRagnorokPlanID == -1)
    {
        xsDisableSelf();
        return;
	}
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
	
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    int myMilUnitsInR75 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 75.0);
    int alliedMilUnitsInR75 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, mainBaseLocation, 75.0, true);
    int enemyMilUnitsInR75 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    int numEnemyTitansInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);
    int numAlliedTitansInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationAlly, mainBaseLocation, 75.0, true);
    
    static int count = 0;
    
    if ((currentPop > currentPopCap * 0.7) && (myMilUnitsInR75 + alliedMilUnitsInR75 + 3 >= enemyMilUnitsInR75)
	&& (numEnemyTitansInR75 - numAlliedTitansInR75 - numTitans <= 0))
    {
        if ((currentPop <= currentPopCap - 2) || (foodSupply < 2500) || (goldSupply < 2500) || ((woodSupply < 1400)))
        {
            count = 0;
            return;
		}
        else
        {
            // Check if most military upgrades are researched and we are at pop cap.
            if (cMyCiv == cCivThor)
            {
                if ((kbGetTechStatus(cTechChampionInfantry) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechChampionCavalry) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechMeteoricIronMail) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechDragonscaleShields) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechHammeroftheGods) < cTechStatusResearching))
                {
                    count = 0;
                    return;
				}
			}
            else
            {
                if ((kbGetTechStatus(cTechChampionInfantry) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechChampionCavalry) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechIronMail) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechIronShields) < cTechStatusResearching)
				|| (kbGetTechStatus(cTechIronWeapons) < cTechStatusResearching))
                {
                    count = 0;
                    return;
				}
			}
            count = 3;
		}
	}
    else
    {
        count = count + 1;
	}
    
    if ((numVillagers < 10) || (count <= 2))
    {
        return;
	}
    
    aiPlanSetVariableBool(gRagnorokPlanID, cGodPowerPlanAutoCast, 0, true);
    
    //Finished.
    gRagnorokPlanID = -1;
    xsDisableSelf();
}

//==============================================================================
rule castHeavyGP
minInterval 12  //starts in cAge4
inactive
{
    //check if we have a gEnemySettlementAttPlanID
    if (gEnemySettlementAttPlanID < 0)
    {
        return;
	}
    static int CastAttempt=0; 
    //get the targetPlayerID, the targetID, its unitType, its health and its position
    int targetPlayerID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanPlayerID, 0);
    int targetID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0);
    if (targetID < 0)
    targetID = getMainBaseUnitIDForPlayer(targetPlayerID);
    
    if ((kbUnitIsType(targetID, cUnitTypeAbstractSettlement) == false) ||(targetID < 0))
    {
        return;
	}
    
    float targetHealth = kbUnitGetHealth(targetID);
    if (targetHealth < 0.5)
    {
        return;
	}
    
    vector targetPosition = kbUnitGetPosition(targetID);
    
    if (kbLocationVisible(targetPosition) == false)
    {
        return;
	}
    
    //check if the settlement is still being built
    int numSettlementsBeingBuiltAtTargetPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, targetPlayerID, targetPosition, 5.0);
    if (numSettlementsBeingBuiltAtTargetPos > 0)
    {
        return;
	}
    
    //count the number of enemy buildings in range
    int numMilBuildingsInR50 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 50.0);
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distanceToMainBase = xsVectorLength(mainBaseLocation - targetPosition);
    
    if (distanceToMainBase > 110.0)
    {
        if (numMilBuildingsInR50 <= 2)
        {
            return;
		}
		
        //count the units in range
		int myMilUnitsInR40 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetPosition, 30.0);
		int enemyVilUnitsInR50 = getNumUnitsByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 50.0, true);
        int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 50.0, true);
		int Combined = enemyVilUnitsInR50 + enemyMilUnitsInR50;
		
        if  (Combined < 10)
        {
            return;
		}
        
        //TODO: Maybe also check if we have enough resources?
	}
	
    //cast gHeavyGPTechID
    if (aiCastGodPowerAtPosition(gHeavyGPTechID, targetPosition) == true)
    {
        aiPlanDestroy(gHeavyGPPlanID);
	    CastAttempt = CastAttempt+1;
	    if (CastAttempt > 3)		
        xsDisableSelf();
	}
    else
    {
	}
}

//==============================================================================
void findTownDefenseGP(int baseID = -1)
{
    if (gTownDefenseGodPowerPlanID != -1)
	return;
	
    gTownDefenseGodPowerPlanID = aiFindBestTownDefenseGodPowerPlan();
    if (gTownDefenseGodPowerPlanID == -1)
	return;
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    
    //remember the evaluation model and change it.
    gTownDefenseEvalModel = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0);
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
    //remember the targeting model and change it.
    gTownDefenseTargetingModel = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0);
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
    //remember the playerID.
    gTownDefensePlayerID = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0);
    //remember the location and change it.
    gTownDefenseLocation = aiPlanGetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0);
    aiPlanSetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, kbBaseGetLocation(cMyID, baseID));
    //change the distance.
    float distance = 40.0;
    if (baseID == mainBaseID)
	distance = 55.0;
    aiPlanSetVariableFloat(gTownDefenseGodPowerPlanID, cGodPowerPlanDistance, 0, distance);
}

//==============================================================================
void releaseTownDefenseGP()
{
    if (gTownDefenseGodPowerPlanID == -1)
	return;
	
    //Change the evaluation model back.
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, gTownDefenseEvalModel);
    //Reset the player.
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0, gTownDefensePlayerID);
    //Change the targeting model back
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0, gTownDefenseTargetingModel);
    //change the location back
    aiPlanSetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, gTownDefenseLocation);
    //change the distance back
    aiPlanSetVariableFloat(gTownDefenseGodPowerPlanID, cGodPowerPlanDistance, 0, 55.0);
    //Release the plan.
    gTownDefenseGodPowerPlanID = -1;
    gTownDefenseEvalModel = -1; 
    gTownDefensePlayerID = -1;
    gTownDefenseTargetingModel = -1;
    gTownDefenseLocation = cInvalidVector;
}

//==============================================================================
rule rGaiaForestPower
minInterval 35 //starts in cAge1
inactive
{
	static bool FirstRun = false;	
	if (kbGetAge() < cAge2) 
	return;

    xsSetRuleMinIntervalSelf(109);
    if (gGaiaForestPlanID == -1)
    {
        xsDisableSelf();
        return;
	}
    bool JustCastIt = false;
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int NumTreesMB = getNumUnits(cUnitTypeGaiaForesttree, cUnitStateAlive, -1, 0, mainBaseLocation, 50.0);
	if (NumTreesMB <= 20)
	JustCastIt = true;
    static int count = 0;
    bool autoCast = aiPlanGetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0);
    if (autoCast == true)
    {
        //reset to false
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, false);
	}
    
    
    if (JustCastIt == true)
    {
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, true);
        count = count + 1;
	}
    
    if (count >= 3)
    {
        //Finished.
        gGaiaForestPlanID = -1;
        xsDisableSelf();
	}
}

//==============================================================================
rule rHesperidesPower
minInterval 109 //starts in cAge3
inactive
{
	
    if (gHesperidesPlanID == -1)
    {
        xsDisableSelf();
        return;
	}
    
    static int count = 0;
    bool autoCast = aiPlanGetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0);
    if (autoCast == true)
    {
        //reset to false
        aiPlanSetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0, false);
	}
    
    //for now only cast if we don't have one already
    int numHesperides = kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive);
    if (numHesperides < 1)
    {
        aiPlanSetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0, true);
        count = count + 1;
	}
    
    if (count >= 2)
    {
        //Finished.
        gHesperidesPlanID = -1;
        xsDisableSelf();
	}
}

//==============================================================================
// rule rCitadel, modified Sentinel plan to be exact.
//==============================================================================
extern int BlockedCitadelID=-1;
rule rCitadel
minInterval 20 //starts in cAge1
inactive
{
    int planID=fCitadelPlanID;
    bool Ally = true;
    if ((aiRandInt(2) < 1) || (IhaveAllies == false))
    Ally = false;
  
    int settlementFound= 0;
    if (Ally == true)
	settlementFound = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly);
	else
    settlementFound = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	
    if (settlementFound < 1)
	return;
	int baseID = -1;
	
    for (i=0; < settlementFound)
    {
        int unitID = -1; 
	    if (Ally == true)
		unitID = findUnitByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly);
	    else
		unitID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive);	
	    vector unitLoc = kbUnitGetPosition(unitID);	
	    int enemyMilUnits = getNumUnitsByRel(cUnitTypeMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 32.0, true);
        if ((enemyMilUnits > 4) && (unitID != -1))
        {
            baseID = kbUnitGetBaseID(unitID);
            break;
		}
	}
	
    if (baseID != -1)
    {
        if (aiCastGodPowerAtUnit(cTechCitadel, unitID) == true)
        {
            aiPlanSetBaseID(planID, baseID);
            aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
            aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
            aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
            xsDisableSelf();
			BlockedCitadelID = baseID;
			xsEnableRule("BlockedGPCitadel");
		}
	}
}
rule BlockedGPCitadel
minInterval 2
inactive
{
	static vector CitadelLoc = cInvalidVector;
	if (BlockedCitadelID != -1)
	{
		CitadelLoc = kbUnitGetPosition(BlockedCitadelID);
		
		int NumAllies = getNumUnitsByRel(cUnitTypeCitadelCenter, cUnitStateAlive, -1, cPlayerRelationAlly, CitadelLoc, 20.0, true);
		int NumSelf = getNumUnits(cUnitTypeCitadelCenter, cUnitStateAlive, -1, cMyID, CitadelLoc, 20.0, true);
		int Combined = NumAllies + NumSelf;
		if (Combined < 1)
		xsEnableRule("rCitadel");
		BlockedCitadelID = -1;
		CitadelLoc = cInvalidVector;
	}
	xsDisableSelf();
}
//==============================================================================
// Shifting Sand Rule & Plan
//==============================================================================
rule rShiftingSand
minInterval 25
inactive
{
	static int queryID = -1;
	static int Attempt = 0;
	int planID = gShiftingSandPlanID;
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	
	//-- create the query used for evaluation
	if (queryID < 0)
	queryID=kbUnitQueryCreate("Shifting Sands Evaluation");
	
	if (queryID != -1)
	{
		kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
		kbUnitQuerySetSeeableOnly(queryID, true);
		kbUnitQuerySetAscendingSort(queryID, true);
		kbUnitQuerySetMaximumDistance(queryID, 12);
        kbUnitQuerySetState(cUnitStateAlive);
	}
	
	kbUnitQueryResetResults(queryID);
	int numberFound=kbUnitQueryExecute(queryID);
	
	if (numberFound < 3)
	return;
	
	aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
	aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cPlayerRelationEnemy);
	aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbUnitGetPosition(kbUnitQueryGetResult(queryID, 0)));
	aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 1, mainBaseLocation);
	aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelDualLocation);
	Attempt = Attempt + 1;
	if (Attempt >= 3)
	xsDisableSelf();
}

// Chinese rules, copy paste from WarriorMario //////////


//==============================================================================
// canAffordSpeedUpConstruction(int queryID, int index)
// Function to check whether we can afford a speed up
//==============================================================================
bool canAffordSpeedUpConstruction(int queryID = -1, int index = -1, int escrowID = -1)
{
	int gold  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceGold );
	int wood  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceWood );
	int food  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFood );
	int favor = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFavor);

	if(kbEscrowGetAmount(escrowID, cResourceGold)<gold)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceWood)<wood)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFood)<food)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFavor)<favor)
	{
		return(false);
	}
	return(true);
}

//==============================================================================
// rSpeedUpBuilding
// There are some times we want to speed up when possible:
// - economic buildings so we can get an edge over the other players as long as
// it doesn't mess up our age times.
// - military buildings in classical and higher
// Script is somewhat weird atm as the functions require queryID and indices
// We might want to add randomness as now every building is sped up ^^
//==============================================================================
rule rSpeedUpBuilding
minInterval 10
inactive
{
	// Set up a query
	static int queryID = -1;
	if(queryID ==-1)
	{
		queryID = kbUnitQueryCreate("Unit_ID_Query");
	}
	// Look for constructions
	kbUnitQuerySetPlayerID(queryID, cMyID);
	kbUnitQuerySetUnitType(queryID, cUnitTypeBuilding);
	kbUnitQuerySetState(queryID, cUnitStateBuilding);
	int numConstructions = kbUnitQueryExecute(queryID);
	for(i =0; < numConstructions)
	{
		int buildingID = kbUnitQueryGetResult(queryID,i);
		if(kbBuildingCanSpeedUpConstruction(queryID, i))
		{
			// Things we should speed up
			if(kbUnitIsType(buildingID,cUnitTypeBuilding))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cRootEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cRootEscrowID);
				}
			}
		}
	}
}

//==============================================================================
// rRecreation
// There are some times we want to cast recreation:
// - 1 dead villager in archaic -> rule interval is very low, every second counts
// - 2 dead villagers in classical
// - 3 dead villagers in heroic and later
// - No enemy army nearby otherwise they get killed, resurrected and killed again
//==============================================================================
rule rRecreation
minInterval 10
inactive
{
	int numRequired = 1;
	if (kbGetAge() == cAge2)
	numRequired = 2;
	else if (kbGetAge() > cAge2)
	numRequired = 3;
	int NumDead = kbUnitCount(cMyID, cUnitTypeVillagerChineseDeadReplacement, cUnitStateAlive);
	if (NumDead < 1)
	return;
	
	for (i=0; < NumDead)
	{
		int unitID = findUnitByIndex(cUnitTypeVillagerChineseDeadReplacement, i, cUnitStateAlive);	
		vector unitLoc = kbUnitGetPosition(unitID);
		int OtherDead = getNumUnits(cUnitTypeVillagerChineseDeadReplacement, cUnitStateAlive, -1, cMyID, unitLoc, 10.0);
		int NearbyEnemy = getNumUnitsByRel(cUnitTypeMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 20.0, true);
		if ((OtherDead >= numRequired) && (NearbyEnemy < 1))
		{
			if(aiCastGodPowerAtPosition(cTechRecreation,unitLoc))
			{
				xsDisableSelf();
				break;
			}
		}	
	}
}
//==============================================================================
rule rYearOfTheGoat
minInterval 12
inactive
{
	if ((cvRushBoomSlider > 0.5) || (kbGetAge() > cAge1))
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat, kbGetTownLocation()+ vector(2,2,2));
		xsDisableSelf();
	}
}

rule rCastExamination
minInterval 8
inactive
{
	int MilInTraining = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateBuilding);
	int Vills = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAliveOrBuilding);
	int vilPopTarget = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);
	
	if ((kbResourceGet(cResourceWood) > 150) && (kbResourceGet(cResourceFood) > 300) && (kbResourceGet(cResourceGold) > 200) && (MilInTraining >= 3) && (kbGetPop() <= kbGetPopCap() - 30) 
	|| (Vills < vilPopTarget * 0.6) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) >= 1) && (kbResourceGet(cResourceFood) > 150))
	{
		aiPlanSetVariableBool(gExaminationID, cGodPowerPlanAutoCast, 0, true);
		xsDisableSelf();
	}
}		

//==============================================================================
// RULE rCastHeavyGP -- TARTARIAN
//==============================================================================
rule rCastHeavyGP
minInterval 10
inactive
{
	static int CastAttempt = 0;
    int TartGate = kbUnitCount(cMyID, cUnitTypeTartarianGate, cUnitStateAlive);
	if ((TartGate > 0) || (CastAttempt > 5))
	{
		xsDisableSelf();
		return;
	}
	
	int NumSettle = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy);
	for (i=0; < NumSettle)
	{
		int unitID = findUnitByRelByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, cPlayerRelationEnemy);
		vector unitLoc = kbUnitGetPosition(unitID);
		int numFarms = getNumUnitsByRel(cUnitTypeFarm, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 50.0, true);
		if ((numFarms >= 4) && (unitID != -1))
		{
	        int Target = findUnitByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 50, true);
	        vector loc = kbUnitGetPosition(Target);
			if ((kbLocationVisible(loc) == true) && (Target != -1))
			{
				if(aiCastGodPowerAtPosition(gHeavyGPTech,loc) == true)
				{
					CastAttempt = CastAttempt+1;
					break;
				}
			}		
		}	
	}
}

//==============================================================================
// RULE SetSpecialGP // Goodbye Titan gate.
//==============================================================================
rule SetSpecialGP  
minInterval 14
inactive
{
    xsSetRuleMinIntervalSelf(10+aiRandInt(7));
	static int CastAttempt=0;
	static bool CastNow = false;
	static bool TargetSettlement = false;
    static bool TargetTitanGate = false;
	int eUnitID = -1;
	vector eLocation = cInvalidVector;
	int enemyPlayerID = aiGetMostHatedPlayerID();
    if (TitanAvailable == true)
	TargetTitanGate = true;
	else TargetSettlement = true;
	
	if (xsGetTime() > 100*45*1000) // Let it go..
	{
		TargetTitanGate = false;
		TargetSettlement = true;
	}
	
	if ((TargetTitanGate == true) && (TargetSettlement == false))
	{
		int TitanGate = findUnitByRel(cUnitTypeTitanGate, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy);
        if (TitanGate != -1)
		eUnitID = TitanGate;
	    if (eUnitID != -1)
		{
		    eUnitID = TitanGate;
		    eLocation = kbUnitGetPosition(eUnitID);
		}
	}
	
	if ((TargetSettlement == true) && (TargetTitanGate == false))
	{
		eUnitID = getMainBaseUnitIDForPlayer(aiGetMostHatedPlayerID());
		eLocation = kbUnitGetPosition(eUnitID);
		int NumEnemyFarms = getNumUnits(cUnitTypeFarm, cUnitStateAliveOrBuilding, 0, enemyPlayerID, eLocation, 35.0);
		if (NumEnemyFarms < 5)
		return;	
	}
	
	if ((eUnitID > 0) && (aiGetGodPowerTechIDForSlot(3) == cTechMeteor) || (eUnitID > 0) && (aiGetGodPowerTechIDForSlot(3) == cTechTornado))
    {
		if((aiGetGodPowerTechIDForSlot(0) == cTechVision) && (CastNow == false))
		{
			if(aiCastGodPowerAtPosition(cTechVision, kbUnitGetPosition(eUnitID)) == true)
			CastNow = true;
			xsSetRuleMinIntervalSelf(1);
			return;
		}
		if((kbLocationVisible(eLocation) == true) && (CastNow == true))
		{
			if(aiCastGodPowerAtPosition(aiGetGodPowerTechIDForSlot(3), kbUnitGetPosition(eUnitID)) == true)
			{   
				CastAttempt = CastAttempt+1;
				if (CastAttempt == 3)
				xsSetRuleMinIntervalSelf(60);
				else xsSetRuleMinIntervalSelf(1);
				if (CastAttempt >= 5)
				{
					xsEnableRule("castHeavyGP");
					xsDisableSelf();
				}
				return;
			}
		}
	}
}

rule Tsunami  
minInterval 16
inactive
{
	static int CastAttempt = 0;
    int HatedPlayer = aiGetMostHatedPlayerID();
	int SettlementID = getMainBaseUnitIDForPlayer(HatedPlayer);
	if (SettlementID == -1)
	return;
    vector TownLocation = kbUnitGetPosition(SettlementID); // uses main TC
	int Houses = findUnit(cUnitTypeLogicalTypeHouses, cUnitStateAlive, -1, HatedPlayer, TownLocation, 50, true);
	if (Houses != -1)
	{
		vector HouseLocation = kbUnitGetPosition(Houses);
		int HousesThere = getNumUnits(cUnitTypeLogicalTypeHouses, cUnitStateAlive, -1, HatedPlayer, HouseLocation, 20);
		if (HousesThere > 2)
		{
			vector offset = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) - HouseLocation;
			offset = xsVectorNormalize(offset);
			vector target = HouseLocation + (offset * 60.0);
			vector startPosition = target;
		    int Distance = xsVectorLength(target - HouseLocation);
			if ((Distance < 125) && (kbLocationVisible(target) == true) && (equal(target, cInvalidVector) == false))
			{
				vector finalPosition = TownLocation - (TownLocation-startPosition)*2;
				if(aiCastGodPowerAtPositionFacingPosition(cTechTsunami,startPosition,finalPosition))
                CastAttempt = CastAttempt + 1;
				
				if (CastAttempt > 3)
				xsDisableSelf();
			}
		}
		
	}
}
