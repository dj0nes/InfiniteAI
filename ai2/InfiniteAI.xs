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
include "InfiniteAIAgeHandlers.xs";


//==============================================================================


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
