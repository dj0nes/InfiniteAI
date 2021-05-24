//==============================================================================
// InfiniteAI
// InfiniteAI.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
// and... slightly modified by Retherichus, to ensure online play without desyncs.
// as well with some other fixes.. though! all credit still goes to Loki_GdD!
//
// This is the main ai file. If you want to use InfiniteAI in your scenario,
// this would be the file you need to select. All other InfiniteAI*.xs files are
// just helper files. They are no stand-alone ai files.
//==============================================================================

//==============================================================================
include "InfiniteAIglobals.xs";
include "InfiniteUtils.xs";

//Basics Include.
include "InfiniteAIBasics.xs";

// Placeholder Reth
include "InfiniteAIExtra.xs";
//==============================================================================

//==============================================================================
//BuildRules Include.
include "InfiniteAIBuild.xs";

//==============================================================================
//Economy Include.
include "InfiniteAIEcon.xs";
include "InfiniteAIEconForecastUtils.xs";
include "InfiniteAIEconEscrow.xs";

//==============================================================================
//God Powers Include.
include "InfiniteAIGPs.xs";

//==============================================================================
//Map Specifics Include.
include "InfiniteAIMapSpec.xs";

//==============================================================================
//Military Include.
include "InfiniteAIMil.xs";

//==============================================================================
//Naval Include.
include "InfiniteAINaval.xs";

//==============================================================================
//Personality Include.
include "InfiniteAIPers.xs";

//==============================================================================
//Progress Include.
include "InfiniteAIProgr.xs";

//==============================================================================
//TechRules Include.
include "InfiniteAITechs.xs";

//==============================================================================
//trainRules Include.
include "InfiniteAITrain.xs";


include "InfiniteAIInit.xs";


//==============================================================================
void age2Handler(int age=1)
{
    gLastAgeHandled = cAge2;
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
    }

    xsEnableRule("monitorAttPlans");
    xsEnableRule("monitorDefPlans");
    xsEnableRule("baseAttackTracker");
    xsEnableRule("otherBasesDefPlans");
    xsEnableRule("getNextGathererUpgrade");

    //activate ObeliskClearingPlan if there is an Egyptian enemy,
    //enable the hesperides rule if there's an Oranos or Gaia player
    bool hesperidesPower = false;
    bool UWGate = false;
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if ((kbGetCivForPlayer(playerID) == cCivOuranos) || (kbGetCivForPlayer(playerID) == cCivGaia))
        {
            hesperidesPower = true;
            continue;
        }
        if ((playerID == cMyID) || (kbIsPlayerAlly(playerID) == true))
            continue;
        if ((kbGetCivForPlayer(playerID) == cCivZeus) || (kbGetCivForPlayer(playerID) == cCivHades))
        {
            UWGate = true;
            continue;
        }

    }

    if (hesperidesPower == true)
        xsEnableRule("hesperides");
    if (UWGate == true)
        xsEnableRule("IHateUnderworldPassages");

    //Econ.
    econAge2Handler(age);
    //Progress.
    progressAge2Handler(age);
    //GP.
    gpAge2Handler(age);
    //Naval
    navalAge2Handler(age);

    //Set the housing rebuild bound.
    if (cMyCulture == cCultureEgyptian)
        gHouseAvailablePopRebuild=30;
    else
        gHouseAvailablePopRebuild=18;

    //Switch the EM rule.
    updateEMAllAges(); // Make it run right now

    //If we're building towers, do that.

    if (cMyCulture != cCultureEgyptian)
        xsEnableRule("getWatchTower");
    xsEnableRule("getCrenellations");
    xsEnableRule("getSignalFires");
    xsEnableRule("buildMBTower");

    //Maintain a water transport, if this is a transport map.
    if ((gTransportMap == true) && (gMaintainWaterXPortPlanID < 0) || (cvRandomMapName == "king of the hill") && (KoTHWaterVersion == true))
    {
        gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 0, true, -1);
        aiPlanSetDesiredPriority(gMaintainWaterXPortPlanID, 95);
    }

    //Init our myth unit rule.
    xsEnableRule("trainMythUnit");

    //enable our raiding party rule
    xsEnableRule("createRaidingParty");

    //enable the attackEnemySettlement rule
    xsEnableRule("attackEnemySettlement");

    //enable the createLandAttack rule
    xsEnableRule("createLandAttack");

    //variables for our buildplans
    vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector origLocation = location;
    vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));

    float fx = xsVectorGetX(frontVector);
    float fz = xsVectorGetZ(frontVector);
    float fxOrig = fx;
    float fzOrig = fz;
    vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    float bxOrig = bx;
    float bzOrig = bz;

    //Greek.
    if (cMyCulture == cCultureGreek)
    {
        //Create our hero maintain plans.  These do first and second age heroes.
        if (cMyCiv == cCivZeus)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekJason, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekOdysseus, 1, false, kbBaseGetMainID(cMyID));
        }
        else if (cMyCiv == cCivPoseidon)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekTheseus, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekHippolyta, 1, false, kbBaseGetMainID(cMyID));
        }
        else if (cMyCiv == cCivHades)
        {
            gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAjax, 1, false, kbBaseGetMainID(cMyID));
            gHero2MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekChiron, 1, false, kbBaseGetMainID(cMyID));
        }
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);
        aiPlanSetDesiredPriority(gHero2MaintainPlan, 100);

        xsEnableRuleGroup("techsGreekMinorGodAge2");

        if (cMyCiv == cCivHades)
        {
            //Enable the Vaults of Erebus rule
            xsEnableRule("getVaultsOfErebus");
        }
        else if (cMyCiv == cCivPoseidon)
        {
            //Enable the Lord of horses rule
            xsEnableRule("getLordOfHorses");
        }
        else if (cMyCiv == cCivZeus)
        {
            //Enable the Olympic parentage rule
            xsEnableRule("getOlympicParentage");
        }
    }
    //Egyptian.
    else if (cMyCulture == cCultureEgyptian)
    {
        //Always want 3 priests
        gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypePriest, 3, false, kbBaseGetMainID(cMyID));

        //Move our pharaoh empower to a "Dropsite"
        if (gEmpowerPlanID != -1)
            aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeDropsite);

        //If we're Ra, create some more priests and empower with them.
        if (cMyCiv == cCivRa)
        {
            APlanID=aiPlanCreate("Mining Camp Empower", cPlanEmpower);
            if (APlanID >= 0)
            {
                aiPlanSetEconomy(APlanID, true);
                aiPlanAddUnitType(APlanID, cUnitTypePriest, 0, 1, 1);
                aiPlanSetVariableInt(APlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMiningCamp);
                aiPlanSetDesiredPriority(APlanID, 70);
                aiPlanSetActive(APlanID);
            }
            BPlanID=aiPlanCreate("Lumber Camp Empower", cPlanEmpower);
            if (BPlanID >= 0)
            {
                aiPlanSetEconomy(BPlanID, true);
                aiPlanAddUnitType(BPlanID, cUnitTypePriest, 0, 1, 1);
                aiPlanSetVariableInt(BPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeLumberCamp);
                aiPlanSetDesiredPriority(BPlanID, 70);
                aiPlanSetActive(BPlanID);
            }
        }
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);

        //Up the build limit for Outposts.
        aiSetMaxLOSProtoUnitLimit(8);
    }
    //Norse.
    else if (cMyCulture == cCultureNorse)
    {
        //We always want 3 Norse heroes.
        gHero1MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroNorse, 3, false, kbBaseGetMainID(cMyID));
        aiPlanSetDesiredPriority(gHero1MaintainPlan, 100);

        //Odin has ravens -> destroy unnecessary scout plans
        if (cMyCiv == cCivOdin)
        {
            aiPlanDestroy(gLandExplorePlanID);
            xsDisableRule("startLandScouting");
        }
    }

    if (cMyCulture == cCultureChinese)
        gGardenBuildLimit = 3;

    if (cMyCiv == cCivOuranos)
        xsEnableRule("getSafePassage");

    //Build walls if we should.
    if (gBuildWalls == true)
    {
        if (gBuildWallsAtMainBase == true)
        {
            xsEnableRule("mainBaseAreaWallTeam1");

            if ((cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureGreek) || (cMyCulture == cCultureChinese))
                xsEnableRule("destroyUnnecessaryDropsites");
        }
        xsEnableRule("otherBaseRingWallTeam1");

        //start up the wall upgrades.
        xsEnableRule("WallManager");
        if (cMyCulture == cCultureNorse)
            xsEnableRule("norseInfantryBuild");

        //enable the rule to fix unfinished walls
        xsEnableRule("fixUnfinishedWalls");

        //enable the rule to destroy unnecessary dropsites near our mainbase
        if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureChinese))
            xsEnableRule("destroyUnnecessaryDropsites");
    }
    //build buildings at other bases
    xsEnableRule("buildBuildingsAtOtherBase");

    //build towers at other bases
    xsEnableRule("buildTowerAtOtherBase");

    if (cMyCiv == cCivNuwa)
    {
        //We can trade now.
        xsEnableRule("tradeWithCaravans");
        tradeWithCaravans();
        xsEnableRule("maintainTradeUnits");
        xsEnableRule("sendIdleTradeUnitsToRandomBase");
    }
}

//==============================================================================
void age3Handler(int age=2)
{
    gLastAgeHandled = cAge3;
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
    }
    //Econ.
    econAge3Handler(age);
    //Progress.
    progressAge3Handler(age);
    //GP.
    gpAge3Handler(age);
    //Naval
    navalAge3Handler(age);

    //kill the rush goals
    if (gRushGoalID != -1)
        aiPlanDestroy(gRushGoalID);
    if (gIdleAttackGID != -1)
        aiPlanDestroy(gIdleAttackGID);

    // build as many fortresses as possible
    xsEnableRule("buildFortress");

    if ((aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch))
        xsEnableRule("watchForFirstWonderStart");

    if (cMyCulture != cCultureNorse)
        xsEnableRule("getGuardTower");
    xsEnableRule("getBoilingOil");

    //Switch the EM rule.
    updateEMAllAges();

    //Up the number of water transports to maintain.
    if (gMaintainWaterXPortPlanID >= 0)
        aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);

    //Create new greek hero maintain plans.
    if (cMyCulture == cCultureGreek)
    {
        xsEnableRuleGroup("techsGreekMinorGodAge3");
        if (cMyCiv == cCivZeus)
            gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekHeracles, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivPoseidon)
            gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAtalanta, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivHades)
            gHero3MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekAchilles, 1, false, kbBaseGetMainID(cMyID));

        aiPlanSetDesiredPriority(gHero3MaintainPlan, 100);
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        aiSetMaxLOSProtoUnitLimit(9);
    }
    else if (cMyCulture == cCultureNorse)
    {
        //research axe of muspell
        xsEnableRule("getAxeOfMuspell");
    }

    if (cMyCulture == cCultureChinese)
        gGardenBuildLimit = 10;

    // Build a fortress/palace/whatever...or 4 in DM
    int buildingType = MyFortress;
    int numBuilders = 1;
    switch(cMyCulture)
    {
    case cCultureGreek:
    {
        numBuilders = 4;
        break;
    }
    case cCultureEgyptian:
    {
        numBuilders = 5;
        break;
    }
    case cCultureNorse:
    {
        numBuilders = 3;
        break;
    }
    case cCultureAtlantean:
    {
        numBuilders = 1;
        break;
    }
    case cCultureChinese:
    {
        numBuilders = 4;
        break;
    }
    }

    int strongBuildPlanID=aiPlanCreate("Build Strong Building ", cPlanBuild);
    if (strongBuildPlanID >= 0)
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));

        float x = xsVectorGetX(frontVector);
        float z = xsVectorGetZ(frontVector);

        x = x * 15;
        z = z * 15;

        frontVector = xsVectorSetX(frontVector, x);
        frontVector = xsVectorSetZ(frontVector, z);
        frontVector = xsVectorSetY(frontVector, 0.0);
        vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
        location = location + frontVector;

        aiPlanSetInitialPosition(strongBuildPlanID, location);
        aiPlanSetVariableBool(strongBuildPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(strongBuildPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
        aiPlanSetVariableFloat(strongBuildPlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);

        aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
        aiPlanSetDesiredPriority(strongBuildPlanID, 100);
        aiPlanAddUnitType(strongBuildPlanID, cBuilderType, numBuilders, numBuilders, numBuilders);
        aiPlanSetEscrowID(strongBuildPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(strongBuildPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(strongBuildPlanID);
    }

    if (cMyCiv != cCivNuwa)
    {
        xsEnableRule("tradeWithCaravans");
        tradeWithCaravans();
        xsEnableRule("maintainTradeUnits");
        xsEnableRule("sendIdleTradeUnitsToRandomBase");
    }

    //get tax collectors and ambassadors
    xsEnableRule("getTaxCollectors");
    xsEnableRule("getAmbassadors"); //AI is indeed taxed too!
    //enable the getDraftHorses rule
    xsEnableRule("getDraftHorses");
    //enable the maintainSiegeUnits rule
    xsEnableRule("maintainSiegeUnits");
    //research masons
    xsEnableRule("getMasons");
    //research heroic fleet on transport maps
    if (gTransportMap == true)
        xsEnableRule("getHeroicFleet");
}

//==============================================================================
void age4Handler(int age=3)
{
    if (cvMaxAge == age)
    {
        aiSetPauseAllAgeUpgrades(true);
    }
    gLastAgeHandled = cAge4;
    //Econ.
    econAge4Handler(age);
    //Progress.
    progressAge4Handler(age);
    //GP.
    gpAge4Handler(age);

    if ( (aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch) )
        xsEnableRule("makeWonder"); // Make a wonder if you have spare resources

    //Switch the EM rule.
    updateEMAllAges();

    //Enable our omniscience rule.
    xsEnableRule("getOmniscience");

    // Get trade unit speed upgrade
    xsEnableRule("getCoinage");

    //Econ.

    //Create new greek hero maintain plans.
    if (cMyCulture == cCultureGreek)
    {
        xsEnableRule("getBeastSlayer");
        if (cMyCiv == cCivZeus)
            gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekBellerophon, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivPoseidon)
            gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekPolyphemus, 1, false, kbBaseGetMainID(cMyID));
        else if (cMyCiv == cCivHades)
            gHero4MaintainPlan = createSimpleMaintainPlan(cUnitTypeHeroGreekPerseus, 1, false, kbBaseGetMainID(cMyID));

        aiPlanSetDesiredPriority(gHero4MaintainPlan, 100);
    }
    else if (cMyCulture == cCultureAtlantean)
    {
        if (gAge4MinorGod == cTechAge4Helios)
        {
            xsEnableRule("buildMirrorTower");
        }
    }
    else if (cMyCulture == cCultureEgyptian)
        aiSetMaxLOSProtoUnitLimit(11);


    //If we're in deathmatch, no more hard pop cap.
    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        gHardEconomyPopCap=-1;
        kbEscrowAllocateCurrentResources();
    }

    // if we are on a land map or playing conquest make titan
    if ((gTransportMap == false) || (aiGetGameMode() == cGameModeConquest))
    {
        xsEnableRule("getSecretsOfTheTitan");
    }

    //enable the getEngineers rule
    xsEnableRule("getEngineers");
}

//==============================================================================
void age5Handler(int age=4)
{
    gLastAgeHandled = cAge5;

    // Set Escrow back to normal.
    kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 300.0);
    kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 300.0);
    kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 300.0);
    kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 30.0);
    //

    //enable the titanplacement rule
    xsEnableRule("rPlaceTitanGate");
    //enable the randomUpgrader rule
    xsEnableRule("randomUpgrader");

}

//==============================================================================
rule ShouldIResign
        minInterval 10 //starts in cAge1
active
{
    if (cvOkToResign == false)
    {
        xsDisableSelf(); // Must be re-enabled if cvOkToResign is set true.
        return;
    }

    //Don't resign too soon.
    if (xsGetTime() < 10*60*1000)
        return;

    //Don't resign if you're teamed with a human.
    static bool checkTeamedWithHuman=true;
    if (checkTeamedWithHuman == true)
    {
        for (i=1; < cNumberPlayers)
        {
            if (i == cMyID)
                continue;
            //Skip if not human.
            if (kbIsPlayerHuman(i) == false)
                continue;
            //If this is a mutually allied human, go away.
            if (kbIsPlayerMutualAlly(i) == true)
            {
                xsDisableSelf();
                return;
            }
        }
        //Don't check again.
        checkTeamedWithHuman=false;
    }

    if (IhaveAllies == true)
    {
        int NorseBuilders=kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);
        int TotalMilBuildings=kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsThatTrainMilitary,  cUnitStateAlive);
        if ((NorseBuilders > 0) && (cMyCulture == cCultureNorse) || (TotalMilBuildings > 0) && (kbGetPopCap() >= 5))
            return;
    }


    int numSettlements=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    //If on easy, don't only resign if you have no settlements.
    if (aiGetWorldDifficulty() == cDifficultyEasy)
    {
        if (numSettlements <= 0)
        {
            gResignType = cResignSettlements;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
        }
        return;
    }

    //Don't resign if we have over 30 active pop slots.
    if (kbGetPop() >= 30)
        return;

    //Don't quit if we have at least one settlement.
    if ((numSettlements > 1) || (numSettlements > 0) && (IhaveAllies == true))
        return;

    //Don't resign if we still have villagers and teamed up.
    int numAliveVils=kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    if ((numAliveVils > 0) && (IhaveAllies == true))
        return;


    int builderUnitID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
    int numBuilders=kbUnitCount(cMyID, cBuilderType, cUnitStateAliveOrBuilding);

    if ((numSettlements <= 0) && (numBuilders <= 10))
    {
        if (kbCanAffordUnit(cUnitTypeSettlementLevel1, cEconomyEscrowID) == false)
        {
            gResignType = cResignSettlements;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
        }
    }
    //If we don't have any builders, we're not Norse, and we cannot afford anymore, try to resign.
    if ((numBuilders <= 0) && (cMyCulture != cCultureNorse))
    {
        if (kbCanAffordUnit(builderUnitID, cEconomyEscrowID) == false)
        {
            gResignType=cResignGatherers;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
        }
    }


    //3. if all of my teammates have left the game.
    int activeEnemies=0;
    int activeTeammates=0;
    int deadTeammates=0;
    float currentEnemyMilPop=0.0;
    float currentMilPop=0.0;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
        {
            currentMilPop=currentMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
            continue;
        }

        if (kbIsPlayerAlly(i) == false)
        {
            //Increment the active number of enemies there currently are.
            if (kbIsPlayerResigned(i) == false)
            {
                activeEnemies=activeEnemies+1;
                currentEnemyMilPop=currentEnemyMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
            }
            continue;
        }

        //If I still have an active teammate, don't resign.
        if (kbIsPlayerResigned(i) == true)
            deadTeammates=deadTeammates+1;
        else
            activeTeammates=activeTeammates+1;
    }

    //3a. if at least one player from my team has left the game and I am the only player left on my team,
    //    and the other team(s) have 2 or more players in the game.
    if ((activeEnemies >= 2) && (activeTeammates <= 0) && (deadTeammates>0))
    {
        gResignType=cResignTeammates;
        aiAttemptResign(cAICommPromptResignQuestion);
        xsDisableSelf();
        return;
    }

    //4. my mil pop is low and the enemy's mil pop is high,
    //Don't do this eval until 4th age and at least 30 min. into the game.
    if ((xsGetTime() < 30*60*1000) || (kbGetAge() < cAge4))
        return;

    static float enemyMilPopTotal=0.0;
    static float myMilPopTotal=0.0;
    static float count=0.0;
    count=count+1.0;
    enemyMilPopTotal=enemyMilPopTotal+currentEnemyMilPop;
    myMilPopTotal=myMilPopTotal+currentMilPop;
    if (count >= 10.0)
    {
        if ((enemyMilPopTotal > (7.0*myMilPopTotal)) || (myMilPopTotal <= count))
        {

            gResignType=cResignMilitaryPop;
            aiAttemptResign(cAICommPromptResignQuestion);
            xsDisableSelf();
            return;
        }

        count=0.0;
        enemyMilPopTotal=0.0;
        myMilPopTotal=0.0;
    }
}

//==============================================================================
void resignHandler(int result =-1)
{
    if (result == 0)
    {
        return;
    }

    if (gResignType == cResignGatherers)
    {
        aiResign();
        return;
    }
    if (gResignType == cResignSettlements)
    {
        aiResign();
        return;
    }
    if (gResignType == cResignTeammates)
    {
        aiResign();
        return;
    }
    if (gResignType == cResignMilitaryPop)
    {
        aiResign();
        return;
    }
}

//==============================================================================
rule findFish   //We don't know if this is a water map...if you see fish, it is.
        minInterval 2 //starts in cAge1
active
{
    if ((cRandomMapName == "highland") || (cRandomMapName == "nomad") ||(NoFishing == true) || (cvMapSubType == VINLANDSAGAMAP))
    {
        xsDisableSelf();
        return;
    }


    if (kbUnitCount(0, cUnitTypeFish) > 0)
    {
        gWaterMap=true;
        //Tell the AI what kind of map we are on.
        aiSetWaterMap(gWaterMap);
        xsEnableRule("fishing");
    }
    xsDisableSelf();
}

//==============================================================================
rule watchForFirstWonderStart   //Look for any wonder being built.  If found, activate
//the high-speed rule that watches for completion
minInterval 73 //starts in cAge3    // Hopefully nobody will build one faster than this
inactive
{
    xsSetRuleMinIntervalSelf(73);
    int AnyWonder = findUnitByRel(cUnitTypeWonder, cUnitStateAliveOrBuilding, -1, cPlayerRelationAny);
    if (AnyWonder > 0)
    {
        xsDisableSelf();
        xsEnableRule("watchForFirstWonderDone");
    }
}

//==============================================================================
rule watchForFirstWonderDone    //See who makes the first wonder, note its ID, make a defend
//plan to kill it, kill defend plan when it's gone
inactive
minInterval 2 //starts in cAge3 activated in watchForFirstWonderStart
{
    static int wonderID = -1;
    static vector wonderLocation = cInvalidVector;
    int Owner = -1;
    int EnemyWonder = findUnitByRel(cUnitTypeWonder, cUnitStateAlive, -1, cPlayerRelationEnemy);
    int AllyWonder = findUnitByRel(cUnitTypeWonder, cUnitStateAlive, -1, cPlayerRelationAlly);

    static int wonderDefendPlanStartTime = -1;

    if (wonderID < 0) // No wonder has been built, look for them
    {
        int myWonder = findUnit(cUnitTypeWonder, cUnitStateAlive);
        if (myWonder > 0) // I win, quit.
            return;

        if (EnemyWonder > 0)
        {
            // Create highest-priority defend plan to go kill it
            Owner = kbUnitGetOwner(EnemyWonder);
            wonderID = EnemyWonder;
            wonderLocation = kbUnitGetPosition(wonderID);

            // Making an attack plan instead, they do a better job of transporting and ignoring some targets en route.
            gEnemyWonderDefendPlan=createDefOrAttackPlan("Enemy wonder attack plan", false, -1, 200, cInvalidVector, kbBaseGetMainID(cMyID), 80, false);
            if (gEnemyWonderDefendPlan < 0)
                return;
            aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanPlayerID, 0, Owner);

            // Specify other continent so that armies will transport
            aiPlanSetNumberVariableValues( gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups,  1, true);
            aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(kbUnitGetPosition(wonderID)));
            aiPlanSetVariableVector(gEnemyWonderDefendPlan, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

            aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeLogicalTypeLandMilitary, 200, 200, 200);
            aiPlanSetInitialPosition(gEnemyWonderDefendPlan, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

            aiPlanSetVariableBool(gEnemyWonderDefendPlan, cAttackPlanAutoUseGPs, 0, true);
            aiPlanSetVariableBool(gEnemyWonderDefendPlan, cAttackPlanMoveAttack, 0, true);
            aiPlanSetVariableInt(gEnemyWonderDefendPlan, cAttackPlanSpecificTargetID, 0, wonderID);

            wonderDefendPlanStartTime = xsGetTime();
            aiPlanSetActive(gEnemyWonderDefendPlan);
        }
        else
        {
            if (AllyWonder > 0)
            {
                // Create highest-priority defend plan to go protect it
                Owner = kbUnitGetOwner(AllyWonder);
                wonderID = AllyWonder;
                wonderLocation = kbUnitGetPosition(AllyWonder);
                if ( kbAreaGroupGetIDByPosition(wonderLocation) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) )
                { // It's on my continent, go help
                    gEnemyWonderDefendPlan = createDefOrAttackPlan("Ally Wonder Defend Plan", true, 60, 40, wonderLocation, -1, 96, false);
                    if (gEnemyWonderDefendPlan >= 0)
                    {
                        aiPlanAddUnitType(gEnemyWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200); // All mil units
                        wonderDefendPlanStartTime = xsGetTime();
                        aiPlanSetActive(gEnemyWonderDefendPlan);
                        xsEnableRule("BunkerUpThatWonder");
                    }
                }
            }
        }
    }
    else // A wonder was built...if it's down, kill the uber-plan
    {
        if (aiPlanGetState(gEnemyWonderDefendPlan) == cPlanStateAttack)
            aiPlanSetNoMoreUnits(gEnemyWonderDefendPlan, false); // Make sure the enemy wonder 'defend' plan stays open

        if (kbUnitGetCurrentHitpoints(wonderID) <= 0)
        {
            aiPlanDestroy(gEnemyWonderDefendPlan);
            gEnemyWonderDefendPlan = -1;
            wonderID = -1;
            xsSetRuleMinInterval("watchForFirstWonderStart", 2);
            xsEnableRule("watchForFirstWonderStart");
            xsDisableSelf();
        }
    }
}

//==============================================================================
rule watchForWonder  // See if my wonder has been placed.  If so, go build it.
        minInterval 5 //starts in cAge4, activated in make wonder
inactive
{
    if (kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) < 1)
    {
        int WonderPlan = findPlanByString("Wonder Build", cPlanBuild);
        if (WonderPlan == -1)
        {
            xsEnableRule("makeWonder"); // plan died? reboot.
            xsDisableSelf();
        }
        return;
    }

    int wonderID = findUnit(cUnitTypeWonder, cUnitStateAlive);
    if (wonderID < 0)
        return;
    xsEnableRule("watchWonderLost"); // Kill the defend plan if the wonder is destroyed.
    vector wonderLocation = kbUnitGetPosition(wonderID);

    // Make the defend plan
    gWonderDefendPlan = createDefOrAttackPlan("Wonder Defend Plan", true, 60, 40, wonderLocation, -1, 95, false);
    if (gWonderDefendPlan >= 0)
    {
        aiPlanAddUnitType(gWonderDefendPlan, cUnitTypeMilitary, 20, 200, 200); // most mil units
        aiPlanSetActive(gWonderDefendPlan);
    }
    xsDisableSelf();
}

//==============================================================================
rule watchWonderLost    // Kill the uber-defend plan if wonder falls
minInterval 7 //starts in cAge4, activated in watchForWonder
inactive
{
    if (kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0 )
        return;

    aiPlanDestroy(gWonderDefendPlan);
    xsEnableRule("makeWonder"); // Try again if we get a chance
    xsDisableSelf();
}

//==============================================================================
rule goAndGatherRelics
inactive
minInterval 101 //starts in cAge1
{
    static int gatherRelicStartTime = -1;

    int EgyTempleUp = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    if (EgyTempleUp < 1 && cMyCulture == cCultureEgyptian)
        return;

    int numRelicGatherers = kbUnitCount(cMyID, gGatherRelicType, cUnitStateAlive);
    if ((numRelicGatherers < 1) && (xsGetTime() < 5*60*1000))
        return;

    int activeGatherRelicPlans = aiPlanGetNumber(cPlanGatherRelic, -1, true);
    if (activeGatherRelicPlans > 0)
    {
        if (xsGetTime() > gatherRelicStartTime + 10*60*1000)
        {
            aiPlanDestroy(gRelicGatherPlanID);
            gRelicGatherPlanID = -1;
            gatherRelicStartTime = -1;
            xsSetRuleMinIntervalSelf(101);
            return;
        }
        else
            return;
    }

    if (cMyCulture == cCultureEgyptian)
    {
        if (kbGetTechStatus(cTechHandsofthePharaoh) == cTechStatusActive)
            gGatherRelicType = cUnitTypePriest;
    }
    gRelicGatherPlanID = aiPlanCreate("Relic Gather", cPlanGatherRelic);

    if (gRelicGatherPlanID >= 0)
    {
        aiPlanAddUnitType(gRelicGatherPlanID, gGatherRelicType, 1, 1, 1);
        aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanTargetTypeID, 0, cUnitTypeRelic);
        aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanDropsiteTypeID, 0, cUnitTypeTemple);
        aiPlanSetBaseID(gRelicGatherPlanID, kbBaseGetMainID(cMyID));
        aiPlanSetDesiredPriority(gRelicGatherPlanID, 100);
        aiPlanSetActive(gRelicGatherPlanID);
        xsSetRuleMinIntervalSelf(307);
        gatherRelicStartTime = xsGetTime();
    }
}

//==============================================================================
rule relicUnitHandler
        minInterval 127 //starts in cAge1
inactive
{
    int numPegasus = kbUnitCount(cMyID, cUnitTypePegasus, cUnitStateAlive);

    if (numPegasus > 0)
    {
        int exploreID = aiPlanCreate("RelicPegasus_Exp", cPlanExplore);
        if (exploreID >= 0)
        {
            aiPlanAddUnitType(exploreID, cUnitTypePegasus, 1, 1, 1);
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetDesiredPriority(exploreID, 98);
            aiPlanSetEscrowID(exploreID, cEconomyEscrowID);
            aiPlanSetActive(exploreID);
        }
        xsDisableSelf();
    }
}

//==============================================================================
rule spotAgeUpgrades    //detect age upgrades given as starting conditions or via triggers
minInterval 18 //starts in cAge1
inactive
{
    if ( gLastAgeHandled < kbGetAge() ) // If my current age is higher than the last upgrade I remember...do the handler
    {
        if (gLastAgeHandled == cAge1)
        {
            age2Handler();
            return;
        }
        else if (gLastAgeHandled == cAge2)
        {
            age3Handler();
            return;
        }
        else if (gLastAgeHandled == cAge3)
        {
            age4Handler();
            return;
        }
        else if (gLastAgeHandled == cAge4)
        {
            age5Handler();
            xsDisableSelf();
        }
    }
}
//==============================================================================
void main(void)
{
    echo("AI start at time "+xsGetTime());

    //Set our random seed.  "-1" is a random init.
    aiRandSetSeed(-1);

    //Calculate some areas.
    kbAreaCalculate();

    preInitMap();
    persDecidePersonality(); // Set the control variables before anything else

    //Wait, then go.
    xsEnableRule("initAfterDelay");
}

rule initAfterDelay            // init ai setup after this number of seconds, used to check pooulation
inactive
        minInterval 1
{
    echo("initAfterDelay at time " + xsGetTime());
    initInfinitePopModeCheck(); // can use infinitePopMode variable after this
    init();
    xsDisableSelf();
}

//==============================================================================
// god power handler
//==============================================================================
void gpHandler(int powerProtoID=-1)
{
    if (powerProtoID == -1)
        return;
    if (powerProtoID == cPowerSpy)
        return;

    //Most hated player chats.
    if ((powerProtoID == cPowerPlagueofSerpents) ||
        (powerProtoID == cPowerEarthquake)        ||
        (powerProtoID == cPowerCurse)             ||
        (powerProtoID == cPowerFlamingWeapons)    ||
        (powerProtoID == cPowerForestFire)        ||
        (powerProtoID == cPowerFrost)             ||
        (powerProtoID == cPowerLightningStorm)    ||
        (powerProtoID == cPowerLocustSwarm)       ||
        (powerProtoID == cPowerMeteor)            ||
        (powerProtoID == cPowerAncestors)         ||
        (powerProtoID == cPowerFimbulwinter)      ||
        (powerProtoID == cPowerTornado)           ||
        (powerProtoID == cPowerBolt))
    {
        aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptOffensiveGodPower, -1);
        return;
    }

    //Any player chats.
    int type=cAICommPromptGenericGodPower;
    if ((powerProtoID == cPowerProsperity) ||
        (powerProtoID == cPowerPlenty)      ||
        (powerProtoID == cPowerLure)        ||
        (powerProtoID == cPowerDwarvenMine) ||
        (powerProtoID == cPowerGreatHunt)   ||
        (powerProtoID == cPowerRain))
    {
        type=cAICommPromptEconomicGodPower;
    }
    // If the power is TitanGate, then we need to launch the repair plan to build it..
    if (powerProtoID == cPowerTitanGate)
    {
        // Don't look for it now, just set up the rule that looks for it
        // and then launches a repair plan to build it.
        xsEnableRule("repairTitanGate");
        return;
    }
    //Tell all the enemy players
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        if (kbIsPlayerAlly(i) == true)
            continue;
        aiCommsSendStatement(i, type, -1);
    }
}
