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
