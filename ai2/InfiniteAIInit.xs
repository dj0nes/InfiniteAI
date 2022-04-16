void initGreek(void)
{
    //Modify our favor need.  A pseudo-hack.
    aiSetFavorNeedModifier(10.0);

    MyFortress = cUnitTypeFortress;

    //Greek scout types.
    gLandScout=cUnitTypeScout;
    gAirScout=cUnitTypePegasus;
    gWaterScout=cUnitTypeFishingShipGreek;

    xsEnableRule("maintainAirScouts"); // enable the airScout rules
    xsEnableRule("fixJammedDropsiteBuildPlans");
    xsEnableRule("relicUnitHandler");
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
    xsEnableRule("fixJammedDropsiteBuildPlans");
    xsEnableRule("trainMercs");

    MyFortress = cUnitTypeMigdolStronghold;

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
    // enable raven scouts on odin
    if (cMyCiv == cCivOdin)
    {
        xsEnableRule("airScout1");
        xsEnableRule("airScout2");
    }

    MyFortress = cUnitTypeHillFort;
    cBuilderType = cUnitTypeAbstractInfantry;

    //Set our trained dropsite PUID.
    aiSetTrainedDropsiteUnitTypeID(cUnitTypeOxCart);

    //Create a reserve plan for our main base for some Ulfsarks if we're not on VS, TM, or Nomad.

    //Create a simple plan to maintain X Ulfsarks.
    if(onBuildOrders < 0)
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
    xsEnableRule("makeAtlanteanHeroes");

    aiSetMinNumberNeedForGatheringAggressvies(3);
    aiSetMinNumberWantForGatheringAggressives(3);

    MyFortress = cUnitTypePalace;

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
    xsEnableRule("fixJammedDropsiteBuildPlans");

    MyFortress = cUnitTypeCastle;


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


void initBases(void)
{
    //Set our town location.
    int TC = findUnit(cUnitTypeAbstractSettlement);
    if (TC != -1)
        kbSetTownLocation(kbUnitGetPosition(TC));

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
}

void initCultureSpecifics(void)
{
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
}

void initGameData(void)
{
    // used to be initRethlAge1()
    gSomeData = aiPlanCreate("Game Data", cPlanData);
    if (gSomeData != -1)
    {
        aiPlanSetDesiredPriority(gSomeData, 100);
        aiPlanAddUserVariableInt(gSomeData, cResourceFood, "Food Forecast ", 1);
        aiPlanAddUserVariableInt(gSomeData, cResourceGold, "Gold Forecast ", 1);
        aiPlanAddUserVariableInt(gSomeData, cResourceWood, "Wood Forecast ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 4, "F% ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 5, "G% ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 6, "W% ", 1);
        aiPlanAddUserVariableInt(gSomeData, 7, "Villagers wanted: ", 1);
        aiPlanAddUserVariableInt(gSomeData, 8, "Caravans ", 1);
        aiPlanAddUserVariableInt(gSomeData, 9, "Caravans wanted: ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 10, "gGlutRatio ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 11, "gFoodGlutRatio ", 1);
        aiPlanAddUserVariableFloat(gSomeData, 12, "gGoldGlutRatio", 1);
        aiPlanAddUserVariableFloat(gSomeData, 13, "gWoodGlutRatio ", 1);
        aiPlanAddUserVariableInt(gSomeData, 14, "NumGoldSites", 1);
        aiPlanAddUserVariableInt(gSomeData, 15, "NumWoodSites ", 1);
        aiPlanAddUserVariableFloat(gSomeData, EcoPercentage, "EcoEscrow% ", 1);
        aiPlanAddUserVariableFloat(gSomeData, MilPercentage, "MilEscrow% ", 1);
        aiPlanAddUserVariableFloat(gSomeData, RootPercentage, "RootEscrow% ", 1);


        //Military
        aiPlanAddUserVariableString(gSomeData, 84, "=-------- Military --------", 1);
        aiPlanAddUserVariableInt(gSomeData, LandAttackTarget, "LandAttackTarget", 1);
        aiPlanAddUserVariableInt(gSomeData, SettlementAttackTarget, "SettleAttackTarget", 1);
        aiPlanAddUserVariableString(gSomeData, MainUnit, "Main unit ", 1);
        aiPlanAddUserVariableString(gSomeData, SecondaryUnit, "Secondary unit ", 1);
        aiPlanAddUserVariableString(gSomeData, ThirdUnit, "Tertiary unit ", 1);

        //Players
        aiPlanAddUserVariableString(gSomeData, PlayersData, "=-------- InfiniteAI Allies --------", 1);
        for (i = 1; < cNumberPlayers)
        {
            aiPlanAddUserVariableInt(gSomeData, PlayersData+i, "Player "+i, 1);
            aiPlanSetUserVariableInt(gSomeData, PlayersData+i, 0, 0);
        }
        aiPlanSetActive(gSomeData);
    }
}

void initPersonality(void)
{
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

    //Startup messages
    echo("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);
    echo("Greetings, my name is "+cMyName+".");
    echo("AI Filename='"+cFilename+"'.");
    echo("MapName="+cvRandomMapName+".");
    echo("Civ="+kbGetCivName(cMyCiv)+".");
    echo("DifficultyLevel="+aiGetWorldDifficultyName(aiGetWorldDifficulty())+".");
    echo("Personality="+aiGetPersonality()+".");
}


void initHousingLimits(void)
{
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
}


void initHardPopulationLimits(void)
{
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
}

void initWallBehavior(void)
{
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
}


void initRushBehavior(void)
{
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
}


void initLateAgeAttack(void)
{
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
}


void initLightningOrDeathmatchMode(void)
{
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
}


void updateGatherGoals(void)
{
    //Create our econ goal (which is really just to store stuff together).
    gGatherGoalPlanID = aiPlanCreate("GatherGoals", cPlanGatherGoal);
    if (gGatherGoalPlanID < 0)
        return;

    //Overall percentages.
    aiPlanSetDesiredPriority(gGatherGoalPlanID, 90);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0); // script in charge
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0);

    //Standard RB setup.
    aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, 5, true);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numFoodEasyPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, numFoodHuntPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, numFoodHuntAggressivePlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, numFarmPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, numFishPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, numWoodPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, numGoldPlans);
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans);

    
    aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, gatherPlanCostWeight, true);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold, gatherGoldCostWeight);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood, gatherWoodCostWeight);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood, gatherFoodCostWeight);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor, gatherFavorCostWeight);
    
    //Set up AI Cost weights.
    kbSetAICostWeight(cResourceFood, gatherFoodCostWeight);
    kbSetAICostWeight(cResourceWood, gatherWoodCostWeight);
    kbSetAICostWeight(cResourceGold, gatherGoldCostWeight);
    kbSetAICostWeight(cResourceFavor, gatherFavorCostWeight);
    
    //Set our farm limits.
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0, farmLimitPerPlan); //  Up from 4
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanMaxFarmLimit, 0, maxFarmLimit); //  Up from 24
    aiSetFarmLimit(farmLimitPerPlan);
    
    //Do our late econ init, inlined from postInitEcon()
    //Set the RGP weights.  Script in charge.
    aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
    aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);

    aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanGathererPct, 4, true);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, foodPct);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, woodPct);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, goldPct);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, favorPct);

    aiSetResourceGathererPercentage(cResourceFood, foodPct, false, cRGPScript); // Changed these to 100% food early then
    aiSetResourceGathererPercentage(cResourceWood, woodPct, false, cRGPScript); // the setEarlyEcon rule above will set the
    aiSetResourceGathererPercentage(cResourceGold, goldPct, false, cRGPScript); // former "initial" values once we have 7 (or 3 atlantean) gatherers.
    aiSetResourceGathererPercentage(cResourceFavor, favorPct, false, cRGPScript);
    aiNormalizeResourceGathererPercentages(cRGPScript);

    int mainBaseID = kbBaseGetMainID(cMyID);
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, numFoodEasyPlans, foodEasyPriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, numFoodHuntPlans, foodHuntPriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, numFoodHuntAggressivePlans, foodHuntAggressivePriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, numFishPlans, foodFishingPriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, numFavorPlans, favorPriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numWoodPlans, woodPriority, 1.0, mainBaseID);
    aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numGoldPlans, goldPriority, 1.0, mainBaseID);

    aiPlanSetActive(gGatherGoalPlanID);
    echo("updateGatherGoals ran");
}


void init(void)
{
    // First and foremost: find someone to hate
    if (cvPlayerToAttack < 1)
        updatePlayerToAttack();
    else
        aiSetMostHatedPlayerID(cvPlayerToAttack);

    // this is cheating, but it is super crucial for map detection and consistency
    // and should have little effect on the game as it goes on.
    kbLookAtAllUnitsOnMap();

    aiSetRandomMap(true); // I don't know why this needs to be true
    aiSetAutoGatherMilitaryUnits(false);
    aiSetAttackResponseDistance(60.0); // Set the default attack response distance.
    aiSetDefaultStance(cUnitStanceDefensive); // set our default stance to defensive
    aiCommsSetEventHandler("Comms");
    aiSetExploreDangerThreshold(300.0);

    // for testing only
    // if (cMyCiv == cCivLoki && aiGetPersonality() == PersonalityAttacker) {
    //     initScriptedLokiAttacker();
    //     return;
    // }

    // update econ stuff if needed
    if (cMyCulture == cCultureEgyptian)
    {
        woodPriority = 50;
        goldPriority = 55;
    }
    //Hunt on Erebus and River Styx.
    if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx") || aiGetGameMode() == cGameModeDeathmatch)
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
        aiSetMinNumberNeedForGatheringAggressvies(1);
    }

    //Map Handling, eg. fish, farms, vinlandsaga, nomad weirdness
    preInitMap(); // InfiniteAIMapSpec function to adapt behavior based on map
    initMapSpecific();
    initAutoDetectMap();

    initPersonality();
    initGameData();
    initEcon();
    initGodPowers();
    initBases();
    initCultureSpecifics();
    initHousingLimits();
    initHardPopulationLimits();
    initWallBehavior();
    initRushBehavior();
    initLateAgeAttack();
    updateGatherGoals();
    updateEMAllAges(); // update our EM since updateGatherGoals no longer does this
    initLightningOrDeathmatchMode();

    if ((kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusUnobtainable) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusActive))
        TitanAvailable = true;

    // Check with allies and enable donations
    MessageRel(cPlayerRelationAlly, Tellothers, 1);
    xsEnableRule("MonitorAllies");

    // AI handlers
    aiSetAgeEventHandler(cAge2, "age2Handler");
    aiSetAgeEventHandler(cAge3, "age3Handler");
    aiSetAgeEventHandler(cAge4, "age4Handler");
    aiSetAgeEventHandler(cAge5, "age5Handler");
    aiSetGodPowerEventHandler("gpHandler");
    aiSetResignEventHandler("resignHandler");
    aiSetWonderDeathEventHandler("wonderDeathHandler");

    if (cvMaxAge <= kbGetAge()) // Are we starting at or beyond our max age?
        aiSetPauseAllAgeUpgrades(true);
    
    //Setup the progression to follow these minor gods.
    kbTechTreeAddMinorGodPref(gAge2MinorGod);
    kbTechTreeAddMinorGodPref(gAge3MinorGod);
    kbTechTreeAddMinorGodPref(gAge4MinorGod);
    echo("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));

    // enable rules for first age and general gameplay
    xsEnableRule("updateBreakdowns");
    xsEnableRule("updateFoodBreakdown");
    xsEnableRule("buildInitialTemple");
    xsEnableRule("buildResearchGranary");
    xsEnableRule("getHusbandry");
    xsEnableRule("getHuntingDogs");
    xsEnableRuleGroup("age1EconUpgrades");
    xsEnableRule("tacticalBuildings");
    xsEnableRule("startLandScouting");
    xsEnableRule("age1Progress");
    xsEnableRule("buildHouse");
    xsEnableRule("dockMonitor");
    xsEnableRule("spotAgeUpgrades");
    xsEnableRule("goAndGatherRelics"); // always gather relics, ignore previous modifier based on difficulty
    xsEnableRule("repairBuildings"); // always repair buildings, sorry easy players
    xsEnableRule("defendPlanRule");
    xsEnableRule("mainBaseDefPlan1");
    xsEnableRule("findMySettlementsBeingBuilt");
    xsEnableRule("updatePlayerToAttack"); // update player to attack
    xsEnableRule("buildArmory"); // build an armory at some point
    xsEnableRuleGroup("reth"); // disabled these by default for scripted start testing
}
