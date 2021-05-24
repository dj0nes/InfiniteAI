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

//==============================================================================
rule updatePlayerToAttack   //Updates the player we should be attacking.
        minInterval 27 //starts in cAge1
inactive
{
    static int lastTargetPlayerIDSaveTime = -1;
    static int lastTargetPlayerID = -1;
    static int randNum = 0;
    static bool increaseStartIndex = false;

    if (ChangeMHP == true)
    {
        if (xsGetTime() > MHPTime + 1*60*1000)
            ChangeMHP = false;
        return;
    }
    //Determine a random start index for our hate loop.
    static int startIndex = -1;
    if ((startIndex < 0) || (xsGetTime() > lastTargetPlayerIDSaveTime + (10 + randNum)*60*1000) && (aiRandInt(5) < 1))
        startIndex = getRandomPlayerByRel(cPlayerRelationEnemy);

    int comparePlayerID = -1;
    for (i = 0; < cNumberPlayers)
    {
        //If we're past the end of our players, go back to the start.
        int actualIndex = i + startIndex;
        if (actualIndex >= cNumberPlayers)
            actualIndex = actualIndex - cNumberPlayers;
        if (actualIndex <= 0)
            continue;
        if ((kbIsPlayerEnemy(actualIndex) == true) &&
            (kbIsPlayerResigned(actualIndex) == false) &&
            (kbHasPlayerLost(actualIndex) == false))
        {
            comparePlayerID = actualIndex;
            break;
        }
    }

    //Pass the comparePlayerID into the AI to see what he thinks.  He'll take care
    //of modifying the player in the event of wonders, etc.
    int actualPlayerID = -1;

    if (cvPlayerToAttack == -1)
        actualPlayerID = aiCalculateMostHatedPlayerID(comparePlayerID);
    else
        actualPlayerID = cvPlayerToAttack;

    if (actualPlayerID != lastTargetPlayerID)
    {
        lastTargetPlayerID = actualPlayerID;
        lastTargetPlayerIDSaveTime = xsGetTime();
        randNum = aiRandInt(5);
    }

    if (actualPlayerID != -1)
        aiSetMostHatedPlayerID(actualPlayerID);

    if (InfiniteAIAllies == true)
    {
        if (aiGetCaptainPlayerID(cMyID) != cMyID)
            return;
        MessageRel(cPlayerRelationAlly, AttackTarget, aiGetMostHatedPlayerID());
    }
}


//==============================================================================
void initGreek(void)
{
    //Modify our favor need.  A pseudo-hack.
    aiSetFavorNeedModifier(10.0);

    //Greek scout types.
    gLandScout=cUnitTypeScout;
    gAirScout=cUnitTypePegasus;
    gWaterScout=cUnitTypeFishingShipGreek;

    //Greeks gather with heroes.
    gGatherRelicType=cUnitTypeHero;

    //Create the Greek scout plan.

    int exploreID=aiPlanCreate("Explore_SpecialGreek", cPlanExplore);
    if (exploreID >= 0)
    {
        aiPlanAddUnitType(exploreID, cUnitTypeScout, 1, 1, 1);
        aiPlanSetDesiredPriority(exploreID, 30);
        aiPlanSetActive(exploreID);
    }

    //Poseidon.
    if (cMyCiv == cCivPoseidon)
        gWaterScout=cUnitTypeHippocampus;


    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

    // Control variable overrides
    if (cvAge2GodChoice != -1)
        gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
        gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
        gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
void initEgyptian(void)
{
    //Create a simple TC empower plan
    gEmpowerPlanID=aiPlanCreate("Pharaoh Empower", cPlanEmpower);
    if (gEmpowerPlanID >= 0)
    {
        aiPlanSetEconomy(gEmpowerPlanID, true);
        if (cvMapSubType == VINLANDSAGAMAP)
            aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 0, 0, 1);
        else
            aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 1, 1, 1);
        aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeGranary);
        aiPlanSetDesiredPriority(gEmpowerPlanID, 85);
        aiPlanSetActive(gEmpowerPlanID);
    }
    //Egyptian scout types.
    gLandScout=cUnitTypePriest;
    gAirScout=-1;
    gWaterScout=cUnitTypeFishingShipEgyptian;
    //Egyptians gather with their Pharaoh
    gGatherRelicType=cUnitTypePharaoh;

    //Create a simple plan to maintain Priests for land exploration.
    createSimpleMaintainPlan(cUnitTypePriest, gMaintainNumberLandScouts, true, kbBaseGetMainID(cMyID));

    //Turn off auto favor gather.
    aiSetAutoFavorGather(false);

    //Set the build limit for Outposts.
    aiSetMaxLOSProtoUnitLimit(4);

    //Set.
    if (cMyCiv == cCivSet)
    {
        //Create air explore plans for the hyena.
        int explorePID=aiPlanCreate("Explore_SpecialSetHyena", cPlanExplore);
        if (explorePID >= 0)
        {
            aiPlanAddUnitType(explorePID, cUnitTypeHyenaofSet, 0, 1, 1);
            aiPlanSetDesiredPriority(explorePID, 90);
            aiPlanSetActive(explorePID);
        }
    }

    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

    // Control variable overrides
    if (cvAge2GodChoice != -1)
        gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
        gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
        gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
void initNorse(void)
{

    //Set our trained dropsite PUID.
    aiSetTrainedDropsiteUnitTypeID(cUnitTypeOxCart);

    //Create a reserve plan for our main base for some Ulfsarks if we're not on VS, TM, or Nomad.

    //Create a simple plan to maintain X Ulfsarks.
    xsEnableRule("ulfsarkMaintain");
    // On easy or moderate, get two extra oxcarts ASAP before we're at econ pop cap
    if ( aiGetWorldDifficulty() <= cDifficultyModerate )
    {
        int easyOxPlan=aiPlanCreate("Easy/Moderate Oxcarts", cPlanTrain);
        if (easyOxPlan >= 0)
        {
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanUnitType, 0, cUnitTypeOxCart);
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanNumberToTrain, 0, 2);
            aiPlanSetVariableInt(easyOxPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);
            aiPlanSetDesiredPriority(easyOxPlan, 100);
            aiPlanSetActive(easyOxPlan);
        }
    }

    //Turn off auto favor gather.
    aiSetAutoFavorGather(false);

    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        int dmUlfPlan=aiPlanCreate("dm ulfsarks", cPlanTrain);
        if (dmUlfPlan >= 0)
        {
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
            //Train off of economy escrow.
            aiPlanSetEscrowID(dmUlfPlan, cEconomyEscrowID);
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanNumberToTrain, 0, 5);
            aiPlanSetVariableInt(dmUlfPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);
            aiPlanSetDesiredPriority(dmUlfPlan, 99);
            aiPlanSetActive(dmUlfPlan);
        }
    }
    //Norse scout types.
    gLandScout=cUnitTypeAbstractScout;
    gAirScout=-1;
    gWaterScout=cUnitTypeFishingShipNorse;
    //Norse gather with their heros.
    gGatherRelicType=cUnitTypeHeroNorse;
    if (cMyCiv == cCivOdin)
        gAirScout = cUnitTypeRaven;


    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

    // Control variable overrides
    if (cvAge2GodChoice != -1)
        gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
        gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
        gAge4MinorGod = cvAge4GodChoice;

    //Enable our no-infantry check.
    xsEnableRule("norseInfantryCheck");
}

//==============================================================================
void initAtlantean(void)
{
    // Atlantean
    gLandScout=cUnitTypeOracleScout;
    gWaterScout=cUnitTypeFishingShipAtlantean;
    gAirScout=-1;
    gGatherRelicType = cUnitTypeHero; //use any hero

    //Create the atlantean scout plans.
    int exploreID=-1;
    int i = 0;

    for (i = 0; < 2)
    {
        exploreID = aiPlanCreate("Explore_SpecialAtlantean"+i, cPlanExplore);
        if (exploreID >= 0)
        {
            aiPlanAddUnitType(exploreID, cUnitTypeOracleScout, 0, 1, 1);
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(exploreID, cExplorePlanOracleExplore, 0, true);
            aiPlanSetDesiredPriority(exploreID, 80); // Allow oracleHero relic plan to steal one
            aiPlanSetActive(exploreID);
        }

        if (i == 1)
            gLandExplorePlanID=exploreID;
    }

    // Make sure we always have at least 1 oracles
    int oracleMaintainPlanID = createSimpleMaintainPlan(cUnitTypeOracleScout, 1, false, kbBaseGetMainID(cMyID));

    // Special emergency manor build for Lightning
    if (aiGetGameMode() == cGameModeLightning)
    {
        // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeManor, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
    }

    // Special emergency manor build for DeathMatch
    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeManor, 5, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
    }

    aiSetAutoFavorGather(false);

    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

    // Control variable overrides
    if (cvAge2GodChoice != -1)
        gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
        gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
        gAge4MinorGod = cvAge4GodChoice;

    // If I'm Kronos.. turn on unbuild..
    if (cMyCiv == cCivKronos)
        unbuildHandler();
}


//==============================================================================
void initChinese(void)
{
    // Chinese

    gLandScout=cUnitTypeScoutChinese;
    gWaterScout=cUnitTypeFishingShipChinese;
    gAirScout=-1;
    // Use any hero for gathering relics
    gGatherRelicType = cUnitTypeHeroChineseImmortal; //use Immortal hero
    gGardenBuildLimit = 2;

    createSimpleMaintainPlan(cUnitTypeHeroChineseGeneral, 2, false, kbBaseGetMainID(cMyID));
    cMonkMaintain = createSimpleMaintainPlan(cUnitTypeHeroChineseMonk, aiRandInt(2)+2, false, kbBaseGetMainID(cMyID));
    eChineseHero = createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 1, true, kbBaseGetMainID(cMyID)); // Eco
    mChineseImmortal = createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 0, false, kbBaseGetMainID(cMyID)); // Mil

    //Create the Chinese scout plans.
    int exploreID=-1;
    for (i = 0; < 2)
    {
        exploreID = aiPlanCreate("Explore_Special_Chinese"+i, cPlanExplore);
        if (exploreID >= 0)
        {
            aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 0, 1, 1);
            aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetActive(exploreID);
        }
        if (i == 1)
            gLandExplorePlanID=exploreID;
    }

    // Make sure we always have at least 1 Scout Cavalry
    int ChineseScoutMaintainPlanID = createSimpleMaintainPlan(cUnitTypeScoutChinese, 1, false, kbBaseGetMainID(cMyID));

    // Special emergency house build for Lightning
    if (aiGetGameMode() == cGameModeLightning)
    {
        // Build a house, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
        createSimpleBuildPlan(cUnitTypeHouse, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
    }

    aiSetAutoFavorGather(false);

    // Default to random minor god choices, override below if needed
    gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
    //Random Age3 God.
    gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
    //Random Age4 God.
    gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

    // Control variable overrides
    if (cvAge2GodChoice != -1)
        gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
        gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
        gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
int initUnitPicker(string name="BUG", int numberTypes=1, int minUnits=10,
                   int maxUnits=20, int minPop=-1, int maxPop=-1, int numberBuildings=1)
{
    //Create it.
    int upID=kbUnitPickCreate(name);
    if (upID < 0)
        return(-1);

    //Default init.
    kbUnitPickResetAll(upID);
    //1 Part Preference, 2 Parts CE, 2 Parts Cost.
    kbUnitPickSetPreferenceWeight(upID, 2.0);
    kbUnitPickSetCombatEfficiencyWeight(upID, 4.0);
    kbUnitPickSetCostWeight(upID, 7.0);
    //Desired number units types, buildings.
    kbUnitPickSetDesiredNumberUnitTypes(upID, numberTypes, numberBuildings, true);
    //Min/Max units and Min/Max pop.
    kbUnitPickSetMinimumNumberUnits(upID, minUnits);
    kbUnitPickSetMaximumNumberUnits(upID, maxUnits);
    kbUnitPickSetMinimumPop(upID, minPop);
    kbUnitPickSetMaximumPop(upID, maxPop);
    //Default to land units.
    kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);
    kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);

    //Setup the military unit preferences.
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.3);
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.8);
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.3);

    switch (cMyCulture)
    {
    case cCultureGreek:
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.6);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.1);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypePhysician, 0.0);
        if (cMyCiv == cCivHades)
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeCrossbowman, 0.6);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypePhysician, 0.0);
        break;
    }
    case cCultureEgyptian:
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeSiegeTower, 0.1);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.6);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.8);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeKhopesh, 0.0);
        if (cMyCiv == cCivSet)
        {
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeRhinocerosofSet, 0.1);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeCrocodileofSet, 0.1);
        }
        break;
    }
    case cCultureNorse:
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.1);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.0);
        break;
    }
    case cCultureAtlantean:
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeOracleScout, 0.0);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeMaceman, 0.6);
        break;
    }
    case cCultureChinese:
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeScoutChinese, 0.6);
        if (cMyCiv == cCivShennong)
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeFireLanceShennong, 1.0);
        else
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeFireLance, 1.0);
        break;
    }
    }
    kbUnitPickSetPreferenceFactor(upID, cUnitTypeDryad, 0.0); // This should *only* be produced through the hesperides rule
    //Done.
    return(upID);
}

//==============================================================================
void init(void)
{
    xsEnableRule("updateBreakdowns");
    xsEnableRule("updateFoodBreakdown");
    //We're in a random map.
    aiSetRandomMap(true);

    //Adjust control variable sliders by random amount
    cvRushBoomSlider = (cvRushBoomSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvRushBoomSlider > 1.0)
        cvRushBoomSlider = 1.0;
    if (cvRushBoomSlider < -1.0)
        cvRushBoomSlider = -1.0;
    cvMilitaryEconSlider = (cvMilitaryEconSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvMilitaryEconSlider > 1.0)
        cvMilitaryEconSlider = 1.0;
    if (cvMilitaryEconSlider < -1.0)
        cvMilitaryEconSlider = -1.0;
    cvOffenseDefenseSlider = (cvOffenseDefenseSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
    if (cvOffenseDefenseSlider > 1.0)
        cvOffenseDefenseSlider = 1.0;
    if (cvOffenseDefenseSlider < -1.0)
        cvOffenseDefenseSlider = -1.0;
    echo("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);



    //Startup messages.
    echo("Greetings, my name is "+cMyName+".");
    echo("AI Filename='"+cFilename+"'.");
    echo("MapName="+cvRandomMapName+".");
    echo("Civ="+kbGetCivName(cMyCiv)+".");
    echo("DifficultyLevel="+aiGetWorldDifficultyName(aiGetWorldDifficulty())+".");
    echo("Personality="+aiGetPersonality()+".");

    //Find someone to hate.
    if (cvPlayerToAttack < 1)
        updatePlayerToAttack();
    else
        aiSetMostHatedPlayerID(cvPlayerToAttack);


    //Bind our age handlers.
    aiSetAgeEventHandler(cAge2, "age2Handler");
    aiSetAgeEventHandler(cAge3, "age3Handler");
    aiSetAgeEventHandler(cAge4, "age4Handler");
    aiSetAgeEventHandler(cAge5, "age5Handler");

    if (cvMaxAge <= kbGetAge()) // Are we starting at or beyond our max age?
    {
        aiSetPauseAllAgeUpgrades(true);
    }
    //My stuff
    initRethlAge1();

    //Setup god power handler
    aiSetGodPowerEventHandler("gpHandler");

    //Setup the resign handler
    aiSetResignEventHandler("resignHandler");

    //Set our town location.
    int TC = findUnit(cUnitTypeAbstractSettlement);
    if (TC != -1)
        kbSetTownLocation(kbUnitGetPosition(TC));

    //Economy.
    initEcon();

    //God Powers
    initGodPowers();

    //Create bases for all of our settlements.  Ignore any that already have
    //bases set.  If we have an invalid main base, the first base we create
    //will be our main base.
    static int settlementQueryID=-1;
    if (settlementQueryID < 0)
        settlementQueryID=kbUnitQueryCreate("MySettlements");
    if (settlementQueryID > -1)
    {
        kbUnitQuerySetPlayerID(settlementQueryID, cMyID);
        kbUnitQuerySetUnitType(settlementQueryID, cUnitTypeAbstractSettlement);
        kbUnitQuerySetState(settlementQueryID, cUnitStateAlive);
        kbUnitQueryResetResults(settlementQueryID);
        int numberSettlements=kbUnitQueryExecute(settlementQueryID);
        for (i=0; < numberSettlements)
        {
            int settlementID=kbUnitQueryGetResult(settlementQueryID, i);
            //Skip this settlement if it already has a base.
            if (kbUnitGetBaseID(settlementID) >= 0)
                continue;
            vector settlementPosition=kbUnitGetPosition(settlementID);
            //Create a new base.
            int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), settlementPosition, 85.0);
            if (newBaseID > -1)
            {
                //Figure out the front vector.
                vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
                kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
                //Military gather point.
                vector militaryGatherPoint=settlementPosition+baseFront*18.0;
                kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
                //Set the other flags.
                kbBaseSetMilitary(cMyID, newBaseID, true);
                kbBaseSetEconomy(cMyID, newBaseID, true);
                //Set the resource distance limit.
                kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
                //Add the settlement to the base.
                kbBaseAddUnit(cMyID, newBaseID, settlementID);
                kbBaseSetSettlement(cMyID, newBaseID, true);
                //Set the main-ness of the base.
                kbBaseSetMain(cMyID, newBaseID, true);
            }
        }
    }


    //Culture setup.
    switch (cMyCulture)
    {
    case cCultureGreek:
    {
        initGreek();
        break;
    }
    case cCultureEgyptian:
    {
        initEgyptian();
        break;
    }
    case cCultureNorse:
    {
        initNorse();
        break;
    }
    case cCultureAtlantean:
    {
        initAtlantean();
        break;
    }
    case cCultureChinese:
    {
        initChinese();
        break;
    }
    }
    //Map Specific
    initMapSpecific();

    //Setup the progression to follow these minor gods.
    kbTechTreeAddMinorGodPref(gAge2MinorGod);
    kbTechTreeAddMinorGodPref(gAge3MinorGod);
    kbTechTreeAddMinorGodPref(gAge4MinorGod);
    echo("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));

    //Set the Explore Danger Threshold.
    aiSetExploreDangerThreshold(300.0);
    //Auto gather our military units.
    aiSetAutoGatherMilitaryUnits(false);

    //Get our house build limit.
    if (cMyCulture == cCultureAtlantean)
        gHouseBuildLimit = kbGetBuildLimit(cMyID, cUnitTypeManor);
    else
        gHouseBuildLimit=kbGetBuildLimit(cMyID, cUnitTypeHouse);

    //Set the housing rebuild bound to 4 for the first age.
    if (cMyCulture == cCultureEgyptian)
        gHouseAvailablePopRebuild=8;
    else if (cMyCulture == cCultureAtlantean)
        gHouseAvailablePopRebuild=6;
    else if (cMyCulture == cCultureNorse)
        gHouseAvailablePopRebuild=8;
    else
        gHouseAvailablePopRebuild=5;

    //Set the hard pop caps.
    if (aiGetGameMode() == cGameModeLightning)
    {
        gHardEconomyPopCap=35;
        //If we're Norse, get our 5 dwarves.
        if (cMyCulture == cCultureNorse)
            createSimpleMaintainPlan(cUnitTypeDwarf, 5, true, -1);
    }
    else if (aiGetGameMode() == cGameModeDeathmatch)
        gHardEconomyPopCap=25; // Essentially shut off vill production until age 4.
    else
    {
        if (aiGetWorldDifficulty() == cDifficultyEasy)
            gHardEconomyPopCap=20;
        else if (aiGetWorldDifficulty() == cDifficultyModerate)
            gHardEconomyPopCap=40;
        else
            gHardEconomyPopCap=-1;
    }

    //Set the default attack response distance.
    aiSetAttackResponseDistance(60.0);

    // always wall up, unless the map strictly said no.

    if (bWallUp == true)
    {
        gBuildWalls = true;
        gBuildWallsAtMainBase = true;
    }

    if (mapPreventsWalls() == true)
    {
        gBuildWallsAtMainBase = false;
    }

    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        if (gWallsInDM == true)
        {
            gBuildWalls = true;
            gBuildWallsAtMainBase = true;
        }
    }

    if (cvOkToBuildWalls == false)
    {
        gBuildWalls = false;
        gBuildWallsAtMainBase = false;
    }

    //set our default stance to defensive.
    aiSetDefaultStance(cUnitStanceDefensive);

    //Decide whether or not we're doing a rush/raid.
    // Rushers will use a smaller econ to age up faster, send more waves and larger waves.
    // Boomers will use a larger econ, hit age 2 later, make smaller armies, and send zero or few waves, hitting age 3 much sooner.

    int rushCount = 0;
    if (cvRushBoomSlider > -0.5)
        rushCount = 1; // Rushcount acts as a bool for the moment.  Rush unless strong boomer.

    int rushSize=70; // Total pop to use in rush armies.
    rushSize = rushSize + (cvRushBoomSlider*(rushSize*0.6)); // Increase/decrease the size up to 60% for rushing
    if (cvOffenseDefenseSlider > 0)
        rushSize = rushSize + (cvOffenseDefenseSlider*(rushSize*0.6)); // Increase the size up to 60% for offense

    if (aiGetWorldDifficulty() == cDifficultyModerate) // Take it easy on moderate
        rushSize = rushSize/2;

    if (aiGetWorldDifficulty() == cDifficultyEasy) // Never rush on easy
    {
        rushCount = 0;
        rushSize = 10;
    }

    if (aiGetGameMode() == cGameModeDeathmatch) // Never rush in DM
        rushCount = 0;

    if ((cvRandomMapName == "king of the hill") && (rushCount < 2))
        rushCount = 1; // Always rush in KotH, even on easy.

    if ((aiGetWorldDifficulty() > cDifficultyModerate) && (rushCount < 2))
        rushCount = 2;

    if ((gBuildWallsAtMainBase == true) && (rushCount > 0))
    {
        // Knock up to 40 pop slots off plan
        if (rushSize > 80)
            rushSize = rushSize - 40;
        else
            rushSize = rushSize/2;
    }
    int numTypes = 2;

    // Finally, adjust rushSize to the per-wave number we need
    if (rushCount > 0)
    {
        rushCount = (rushSize+20)/40; // +20 to round to closest value
        rushSize = rushSize / rushCount;
    }

    if (rushSize > 50)
        rushSize = 50;

    if (rushSize < 20)
        rushSize = 20; // Give unitpicker something to do...

    if ((cMyCulture == cCultureNorse) || (cMyCulture == cCultureEgyptian))
        gRushUPID=initUnitPicker("Rush", numTypes, -1, -1, rushSize, rushSize*1.25, 3); // Rush with rushSize pop slots of 3 types and 3 buildings.
    else
        gRushUPID=initUnitPicker("Rush", numTypes, -1, -1, rushSize, rushSize*1.25, 2); // Rush with rushSize pop slots of 3 types and 2 buildings.
    kbUnitPickSetGoalCombatEfficiencyType(gRushUPID, cUnitTypeLogicalTypeLandMilitary);
    // Set a smaller number for first wave.
    int newRushSize = 0;
    newRushSize = rushSize;
    if (rushCount >= 3)
        newRushSize = rushSize/3;
    else if (rushCount == 2)
        newRushSize = rushSize/2;
    if (newRushSize != rushSize)
    {
        if (newRushSize < 20)
            newRushSize = 20;
        kbUnitPickSetMinimumPop(gRushUPID, newRushSize);
    }
    //new stuff for new land attack rule
    gRushSize = rushSize / 3;
    //set the gRushCount in order to enable the tech rules if we only have an idle attack goal in cAge2
    if (gRushCount > 0)
    {
        gRushCount = rushCount + 2; //since our attack plans don't make several attempts, we increase the rush count
    }
    else
    {
        gRushCount = rushCount;
    }

    //set the gFirstRushSize
    if (rushCount >= 1) //gRushCount is now 2, so we need a smaller size for the first rush
    {
        gFirstRushSize = rushSize / 5;
    }
    else
    {
        gFirstRushSize = newRushSize / 3;
    }

    if (gRushCount > 2)
    {
        mRusher = true;
        BeenmRusher = true;
    }

    //Create our UP.
    if (gRushUPID >= 0)
    {
        //Create the rush goal if we're rushing.
        if (rushCount > 0) // Deleted conditions that suppress rushing if we're walling or towering...OK to do some of each.
        {
            //Create the attack.
            gRushGoalID = createSimpleAttackGoal("Rush Land Attack", -1, gRushUPID, rushCount+1, 1, 1, kbBaseGetMainID(cMyID), false);
            // todo: tweak
            if (gRushGoalID > 0)
            {
                echo("init: Rush Land Attack goal created: " + gRushGoalID);
                //Go for hitpoint upgrade first.
                aiPlanSetVariableInt(gRushGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
            }
        }
        else
        {
            //Create an idle attack goal that will maintain our military until the next age.
            gIdleAttackGID = createSimpleAttackGoal("Idle Force", -1, gRushUPID, -1, 1, 1, kbBaseGetMainID(cMyID), false);
            if (gIdleAttackGID >= 0)
            {
                echo("init: Idle Force goal created, no rush land attack, id: " + gIdleAttackGID);

                aiPlanSetVariableBool(gIdleAttackGID, cGoalPlanIdleAttack, 0, true);
                aiPlanSetVariableInt(gIdleAttackGID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
                //Reset the rushUPID down to 3 unit type and 1 building.
                kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, numTypes, 1, true);
            }
        }
    }


    //Create our late age attack goal.
    if (aiGetWorldDifficulty() == cDifficultyEasy)
        gLateUPID=initUnitPicker("Late", 1, -1, -1, 8, 16, gNumberBuildings - 1);
    else if (aiGetWorldDifficulty() == cDifficultyModerate)
    {
        int minPop=20+aiRandInt(14);
        int maxPop=minPop+16;
        if ( aiGetGameMode() != cGameModeDeathmatch )
            gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, gNumberBuildings); // Attack with at least 20-33 pop slots, no more than 36-49.
        else // DM, double number of buildings
            gLateUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, gNumberBuildings+2); // Attack with at least 20-33 pop slots, no more than 36-49.
    }
    else
    {
        minPop=40+aiRandInt(20);
        maxPop=70;
        if (aiGetWorldDifficulty() > cDifficultyHard)
            maxPop = 90;

        if (aiGetGameMode() != cGameModeDeathmatch)
            gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings); // Min: 40-59, max 70 pop slots
        else // Double buildings in DM
            gLateUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings+2); // Min: 40-59, max 70 pop slots
    }

    int lateAttackAge = 2;

    if (gLateUPID >= 0)
    {
        if (aiGetGameMode() == cGameModeDeathmatch)
            lateAttackAge = 3;

        gLandAttackGoalID = createSimpleAttackGoal("Main Land Attack", -1, gLateUPID, -1, lateAttackAge, -1, kbBaseGetMainID(cMyID), true);
        if (gLandAttackGoalID >= 0)
        {
            echo("init: Main Land Attack goal (Late Age Attack) created: " + gLandAttackGoalID);

            //If this is easy, this is an idle attack.
            if (aiGetWorldDifficulty() == cDifficultyEasy)
                aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);

            aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
        }
    }

    //Create our econ goal (which is really just to store stuff together).
    gGatherGoalPlanID=aiPlanCreate("GatherGoals", cPlanGatherGoal);
    if (gGatherGoalPlanID >= 0)
    {
        //Overall percentages.
        aiPlanSetDesiredPriority(gGatherGoalPlanID, 90);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 1.0);
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanGathererPct, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);

        //Standard RB setup.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, 5, true);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 0);
        if (aiGetGameMode() == cGameModeDeathmatch)
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
        else
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 1);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 0);
        //Hunt on Erebus and River Styx.
        if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
        {
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
            aiSetMinNumberNeedForGatheringAggressvies(1);
        }
        //Cost weights.
        aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, 4, true);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood, 1.0);
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor, 1.0);
        //Set our farm limits.
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0, 20); //  Up from 4
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanMaxFarmLimit, 0, 40); //  Up from 24
        aiSetFarmLimit(aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0));
        aiPlanSetActive(gGatherGoalPlanID);
        //Do our late econ init.
        postInitEcon();
        //Lastly, update our EM.
        updateEMAllAges();
    }

    if ((aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning)) // Add an emergency temple, and 10 houses)
    {
        if (cMyCulture == cCultureAtlantean)
        {
            createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
            if (aiGetGameMode() == cGameModeDeathmatch)
                createSimpleBuildPlan(cUnitTypeManor, 2, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
        }
        else
        {
            createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 5);
            if (aiGetGameMode() == cGameModeDeathmatch)
                createSimpleBuildPlan(cUnitTypeHouse, 4, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
        }
    }
    xsEnableRule("buildInitialTemple");
    xsEnableRule("buildResearchGranary");

    // research husbandry
    xsEnableRule("getHusbandry");

    // research hunting dogs
    xsEnableRule("getHuntingDogs");

    // age1 econ upgrades
    xsEnableRuleGroup("age1EconUpgrades");

    //enable the airScout rules if necessary
    if ((cMyCulture == cCultureGreek) || (cMyCiv == cCivOdin))
    {
        if (cMyCulture == cCultureGreek)
        {
            xsEnableRule("maintainAirScouts");
        }
        xsEnableRule("airScout1");
        xsEnableRule("airScout2");
    }

    //enable the fixJammedDropsiteBuildPlans rule
    if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureChinese))
        xsEnableRule("fixJammedDropsiteBuildPlans");

    //enable the tacticalBuildings rule
    xsEnableRule("tacticalBuildings");

    if (cMyCulture == cCultureAtlantean)
    {
        //enable our makeAtlanteanHeroes rule
        xsEnableRule("makeAtlanteanHeroes");
    }

    if (cMyCulture == cCultureEgyptian)
        xsEnableRule("trainMercs");


    if (cMyCulture != cCultureGreek)
    {
        //enable the relicUnitHandler rule
        xsEnableRule("relicUnitHandler");
    }

    //enable the startLandScouting rule
    xsEnableRule("startLandScouting");

    //enable the age1Progress rule
    xsEnableRule("age1Progress");

    //enable the buildHouse rule
    xsEnableRule("buildHouse");

    //enable the dockMonitor rule
    xsEnableRule("dockMonitor");

    //enable the spotAgeUpgrades rule
    xsEnableRule("spotAgeUpgrades");

    //Relics:  Always on Hard or Nightmare, 50% of the time on Moderate, Never on Easy.
    bool gatherRelics = true;
    if ((aiGetWorldDifficulty() == cDifficultyEasy) || ((aiGetWorldDifficulty() == cDifficultyModerate) && (aiRandInt(2) == 0)))
        gatherRelics = false;
    //If we're going to gather relics, do it.
    if (cvOkToGatherRelics == false)
        gatherRelics = false;
    if (gatherRelics == true)
        xsEnableRule("goAndGatherRelics");

    //Enable building repair.
    if (aiGetWorldDifficulty() != cDifficultyEasy)
        xsEnableRule("repairBuildings");

    xsEnableRule("defendPlanRule");
    xsEnableRule("mainBaseDefPlan1");
    xsEnableRule("findMySettlementsBeingBuilt");

    //update player to attack
    xsEnableRule("updatePlayerToAttack");

    //Force an armory to go down
    xsEnableRule("buildArmory");
}

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
