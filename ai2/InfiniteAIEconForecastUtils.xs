void addUnitForecast(int unitTypeID=-1, int qty=1)
{
    if (unitTypeID < 0)
        return;
    gGoldForecast = gGoldForecast + kbUnitCostPerResource(unitTypeID, cResourceGold)*qty;
    gWoodForecast = gWoodForecast + kbUnitCostPerResource(unitTypeID, cResourceWood)*qty;
    gFoodForecast = gFoodForecast + kbUnitCostPerResource(unitTypeID, cResourceFood)*qty;
}


void addTechForecast(int techID=-1)
{
    if (techID < 0)
        return;
    gGoldForecast = gGoldForecast + kbTechCostPerResource(techID, cResourceGold);
    gWoodForecast = gWoodForecast + kbTechCostPerResource(techID, cResourceWood);
    gFoodForecast = gFoodForecast + kbTechCostPerResource(techID, cResourceFood);
}


void updateGathererRatios(void) //Check the forecast variables, check inventory, set assignments
{
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    gFoodForecast = gFoodForecast * 1.2;

    float goldShortage = gGoldForecast - goldSupply;
    if (goldShortage < 0)
        goldShortage = 0;
    float woodShortage = gWoodForecast - woodSupply;
    if (woodShortage < 0)
        woodShortage = 0;
    float foodShortage = gFoodForecast - foodSupply;
    if (foodShortage < 0)
        foodShortage = 0;

    updateGlutRatio();
    float totalShortage = goldShortage + woodShortage + foodShortage;
    if (totalShortage < 1)
        totalShortage = 1;

    float worstShortageRatio = goldShortage/(gGoldForecast+1);
    if ( (woodShortage/(gWoodForecast+1)) > worstShortageRatio)
        worstShortageRatio = woodShortage/(gWoodForecast+1);
    if ( (foodShortage/(gFoodForecast+1)) > worstShortageRatio)
        worstShortageRatio = foodShortage/(gFoodForecast+1);


    float totalForecast = gGoldForecast + gWoodForecast + gFoodForecast;
    if (totalForecast < 1)
        totalForecast = 1; // Avoid div by 0.

    float numGatherers = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
    if (cMyCulture == cCultureAtlantean)
        numGatherers = numGatherers * 3; // Account for pop slots

    float numTradeCarts = kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
    float numFishBoats = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive);
    if (numFishBoats >= 1)
        numFishBoats = numFishBoats - 1; // Ignore scout

    float civPopTotal = numGatherers + numTradeCarts + numFishBoats;

    int doomedID = -1; // Who to kill...
    if (civPopTotal > (aiGetEconomyPop() + 5))
    {
        bool Caravan = false;
        if (numTradeCarts > gMaxTradeCarts) // Trade Unit
        {
            //find idle units first
            doomedID = findUnit(cUnitTypeAbstractTradeUnit, cUnitStateAlive, cActionIdle, cMyID);
            if (doomedID < 0)
                doomedID = findUnit(cUnitTypeAbstractTradeUnit);
        }
        else
        {
            //find idle units first
            doomedID = findUnit(cUnitTypeAbstractVillager, cUnitStateAlive, cActionIdle, cMyID);
            if (doomedID < 0)
                doomedID = findUnit(cUnitTypeAbstractVillager);
            if (doomedID != -1)
                Caravan = true;
        }
        aiTaskUnitDelete(doomedID);
        if (Caravan == true)
        {
            civPopTotal = civPopTotal - 1;
            numTradeCarts = numTradeCarts -1;
        }
        else
        {
            if (cMyCulture == cCultureAtlantean)
            {
                numGatherers = numGatherers - 3;
                civPopTotal = civPopTotal - 3;
            }
            else
            {
                numGatherers = numGatherers - 1;
                civPopTotal = civPopTotal - 1;
            }
        }
    }

    // Figure out what percent of our total civ pop we want working on each resource.  To do that,
    // figure out what the percentages would be to match our shortages, and the percents to match
    // our forecast, and come up with a weighted average of the two.  That way, if we don't have a wood shortage
    // at the moment, but we do expect to keep using wood, we'll keep some villagers on wood.

    // This much (forecastWeight) of the allocation is based on forecast, the rest on shortages.
    // If the biggest shortage is nearly equal to the forecast (nothing on hand), let
    // the shortage dominate.  If the shortage is relatively small, let the
    // forecast dominate
    float forecastWeight = 1.0 - worstShortageRatio;
    float goldForecastRatio = gGoldForecast / totalForecast;
    float woodForecastRatio = gWoodForecast / totalForecast;
    float foodForecastRatio = gFoodForecast / totalForecast;

    float goldShortageRatio = 0.0;
    if (totalShortage > 0)
        goldShortageRatio = goldShortage / totalShortage;
    float woodShortageRatio = 0.0;
    if (totalShortage > 0)
        woodShortageRatio = woodShortage / totalShortage;
    float foodShortageRatio = 0.0;
    if (totalShortage > 0)
        foodShortageRatio = foodShortage / totalShortage;

    float desiredGoldRatio = forecastWeight*goldForecastRatio + (1.0-forecastWeight)*goldShortageRatio;
    float desiredWoodRatio = forecastWeight*woodForecastRatio + (1.0-forecastWeight)*woodShortageRatio;
    float desiredFoodRatio = forecastWeight*foodForecastRatio + (1.0-forecastWeight)*foodShortageRatio;

    // We now have the desired ratios, which can be converted to total civilian units, but then need to be adjusted for trade
    // carts and fishing boats.
    float desiredGoldUnits = desiredGoldRatio * civPopTotal;
    float desiredWoodUnits = desiredWoodRatio * civPopTotal;
    float desiredFoodUnits = desiredFoodRatio * civPopTotal;

    float neededGoldGatherers = desiredGoldUnits - numTradeCarts;
    int mainBaseID = kbBaseGetMainID(cMyID);
    int numMainBaseGoldSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numGoldBaseSites = 0;
    if ((gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID)) // Count gold base if different
        numGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numGoldSites = numMainBaseGoldSites + numGoldBaseSites;

    float neededWoodGatherers = desiredWoodUnits;

    int numberMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceWood, cAIResourceSubTypeEasy);
    int numWoodBaseSites  = 0;
    if ((gWoodBaseID >= 0) && (gWoodBaseID != mainBaseID))
        numWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy);
    int numWoodSites = numberMainBaseSites + numWoodBaseSites;

    float neededFoodGatherers = desiredFoodUnits - numFishBoats;

    int minFoodGatherers = 1.5 + numGatherers*0.25;
    if (minFoodGatherers < 6)
        minFoodGatherers = 6;
    if ((numFishBoats < 4) && (kbGetAge() > cAge2) && (numWoodSites < 1) || (numGoldSites < 1))
        minFoodGatherers = minFoodGatherers*2;
    if (aiGetWorldDifficulty() == cDifficultyEasy)
        minFoodGatherers = minFoodGatherers / 2;
    if (neededFoodGatherers < minFoodGatherers)
        neededFoodGatherers = minFoodGatherers;

    if (neededGoldGatherers < 0)
        neededGoldGatherers = 0;
    if (neededFoodGatherers < 0)
        neededFoodGatherers = 0;
    if (neededWoodGatherers < 0)
        neededWoodGatherers = 0;

    float totalNeededGatherers = neededGoldGatherers + neededFoodGatherers + neededWoodGatherers;
    // Note, this total may be different than the total gatherers, if the trade carts are more than needed, or if
    // the fishing boats supply more food than we need, so this number may be lower...and should be used as the basis
    // for assigning villager percentages.

    float goldAssignment = neededGoldGatherers / totalNeededGatherers;
    float woodAssignment = neededWoodGatherers / totalNeededGatherers;
    float foodAssignment = neededFoodGatherers / totalNeededGatherers;
    float lastGoldAssignment = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold);
    float lastWoodAssignment = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood);
    float lastFoodAssignment = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);

    if (kbGetAge() > cAge1)
    {
        if (neededGoldGatherers > 0)
        {
            if (goldAssignment > lastGoldAssignment)
            {
                goldAssignment = lastGoldAssignment + 0.03;
                if (goldAssignment > 0.45)
                    goldAssignment = 0.45;
            }
            else if (goldAssignment < lastGoldAssignment)
            {
                goldAssignment = lastGoldAssignment - 0.03;
                if (goldAssignment < 0.05)
                    goldAssignment = 0.05;
            }
        }
        if (neededWoodGatherers > 0)
        {
            if (woodAssignment > lastWoodAssignment)
            {
                woodAssignment = lastWoodAssignment + 0.03;
                if (woodAssignment > 0.45)
                    woodAssignment = 0.45;
            }
            else if (woodAssignment < lastWoodAssignment)
            {
                woodAssignment = lastWoodAssignment - 0.03;
                if (woodAssignment < 0.05)
                    woodAssignment = 0.05;
            }
        }
        if (neededFoodGatherers > 0)
        {
            if (foodAssignment > lastFoodAssignment)
            {
                foodAssignment = lastFoodAssignment + 0.03;
            }
            else if (foodAssignment < lastFoodAssignment)
            {
                foodAssignment = lastFoodAssignment - 0.03;
                if (foodAssignment < 0.25)
                    foodAssignment = 0.25;
            }
        }
    }
    //Test
    //if we lost a lot of villagers, keep them close to our settlements (=farming)
    int minVillagers = 14;
    if (cMyCulture == cCultureAtlantean)
        minVillagers = 5;
    int numVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    if ((numVillagers <= minVillagers) && (kbGetAge() > cAge2) && (xsGetTime() > 16*60*1000))
    {
        goldAssignment = 0.05;
        woodAssignment = 0.05;
        foodAssignment = 0.90;
    }
    //Test end

    aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
    aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);
    aiSetResourceGathererPercentage(cResourceGold, goldAssignment, false, cRGPScript);
    aiSetResourceGathererPercentage(cResourceWood, woodAssignment, false, cRGPScript);
    aiSetResourceGathererPercentage(cResourceFood, foodAssignment, false, cRGPScript);
    if ((cMyCulture == cCultureGreek) && (kbGetAge() > cAge1))
        aiSetResourceGathererPercentage(cResourceFavor, 0.05, false, cRGPScript);

    aiNormalizeResourceGathererPercentages(cRGPScript);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, aiGetResourceGathererPercentage(cResourceGold, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, aiGetResourceGathererPercentage(cResourceWood, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, aiGetResourceGathererPercentage(cResourceFood, cRGPScript));
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, aiGetResourceGathererPercentage(cResourceFavor, cRGPScript));

    if (gSomeData != -1)
    {
        int numTradeUnits = kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
        aiPlanSetUserVariableInt(gSomeData, cResourceFood, 0, gFoodForecast);
        aiPlanSetUserVariableInt(gSomeData, cResourceGold, 0, gGoldForecast);
        aiPlanSetUserVariableInt(gSomeData, cResourceWood, 0, gWoodForecast);
        aiPlanSetUserVariableFloat(gSomeData, 4, 0, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood) * 100);
        aiPlanSetUserVariableFloat(gSomeData, 5, 0, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold) * 100);
        aiPlanSetUserVariableFloat(gSomeData, 6, 0, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood) * 100);
        aiPlanSetUserVariableInt(gSomeData, 8, 0, numTradeUnits);
    }
}


//==============================================================================
// setMilitaryUnitCostForecast
// Checks the current age, looks into the appropriate unit picker,
// calculates approximate resource needs for the next few (3?) minutes,
// adds this amount to the global vars.
//==============================================================================
void setMilitaryUnitCostForecast(void)
{
    int upID = -1; // ID of the unit picker to query
    float totalAmount = 0.0; // Total resources to be spent in near future
    if (kbGetAge() == cAge2)
    {
        upID = gRushUPID;
        totalAmount = 1200;
    }
    if (kbGetAge() == cAge3)
    {
        upID = gLateUPID;
        totalAmount = 3000;
    }
    if (kbGetAge() >= cAge4)
    {
        upID = gLateUPID;
        totalAmount = 5000;
    }

    float goldCost = 0.0;
    float woodCost = 0.0;
    float foodCost = 0.0;
    float totalCost = 0.0;

    int unitID = kbUnitPickGetResult( upID, 0); // Primary unit
    float weight = 1.0;
    int numUnits = kbUnitPickGetDesiredNumberUnitTypes(upID);

    if (numUnits == 2)
        weight = 0.67; // 2/3 and 1/3
    if (numUnits >= 3)
        weight = 0.50; // 1/2, 1/3, 1/6
    if (gSomeData != -1)
        aiPlanSetUserVariableString(gSomeData, MainUnit, 0, ""+kbGetProtoUnitName(unitID));

    goldCost = kbUnitCostPerResource(unitID, cResourceGold);
    woodCost = kbUnitCostPerResource(unitID, cResourceWood);
    foodCost = kbUnitCostPerResource(unitID, cResourceFood);
    totalCost = goldCost+woodCost+foodCost;

    gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
    gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
    gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);

    if (numUnits > 1)
    { // Do second unit
        unitID = kbUnitPickGetResult(upID, 1);
        weight = 0.30; // Second is 1/3 regardless
        if (gSomeData != -1)
            aiPlanSetUserVariableString(gSomeData, SecondaryUnit, 0, ""+kbGetProtoUnitName(unitID));
        goldCost = kbUnitCostPerResource(unitID, cResourceGold);
        woodCost = kbUnitCostPerResource(unitID, cResourceWood);
        foodCost = kbUnitCostPerResource(unitID, cResourceFood);
        totalCost = goldCost+woodCost+foodCost;

        gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
        gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
        gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
    }

    if (numUnits > 2)
    { // Do third unit
        unitID = kbUnitPickGetResult(upID, 2);
        weight = 0.20; // Third unit, if used, is 1/6
        if (gSomeData != -1)
            aiPlanSetUserVariableString(gSomeData, ThirdUnit, 0, ""+kbGetProtoUnitName(unitID));
        goldCost = kbUnitCostPerResource(unitID, cResourceGold);
        woodCost = kbUnitCostPerResource(unitID, cResourceWood);
        foodCost = kbUnitCostPerResource(unitID, cResourceFood);
        totalCost = goldCost+woodCost+foodCost;

        gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
        gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
        gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
    }
}

void AddGenForecastNeeds(void)
{

    // Villagers & Farms
    int temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);
    temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);
    if (cMyCulture == cCultureAtlantean)
    {
        if(temp > 5)
            temp = 5;
    }
    else
    {
        if(temp > 13)
            temp = 13;
    }
    addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

    if ((gFarming == true) || (kbGetAge() >= cAge2))
    {
        float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood); // Percent food gatherers
        foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive); // Actual count
        temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
        if (temp < 1)
            temp = 1;
        if (temp > 5)
            temp = 5;
        if (temp > 0)
            addUnitForecast(cUnitTypeFarm, temp);
    }

    if (gFishing == true)
    {
        if (kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding) < 1)
            addUnitForecast(cUnitTypeDock, 1);
        int Number = 50;
        if (kbGetAge() < cAge2)
            Number = 125;
        int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
        int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
        temp = gNumBoatsToMaintain - boatCount;
        if (temp <= 1)
            temp = 1;
        gWoodForecast = gWoodForecast + Number*temp;
    }
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding)  < 1)
        addUnitForecast(cUnitTypeTemple, 1);

    if ((kbGetAge() >= cAge2) || (kbGetTechStatus(gAge2MinorGod) == cTechStatusResearching))
    {
        if (gBuildWalls == true)
            gGoldForecast = gGoldForecast + 300;
        int Armory = cUnitTypeArmory;
        if (cMyCiv == cCivThor)
            Armory = cUnitTypeDwarfFoundry;
        // Settlements
        if (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0)
            addUnitForecast(cUnitTypeSettlementLevel1, 1);

        if ((kbUnitCount(cMyID, Armory, cUnitStateAliveOrBuilding) < 1) && (cMyCulture != cCultureEgyptian))
            addUnitForecast(Armory, 1);

        if ((kbGetAge() >= cAge3) || (cMyCiv == cCivNuwa) && (kbGetAge() == cAge2))
            addUnitForecast(cUnitTypeMarket, 1);

        // military buildings
        if (cMyCulture == cCultureEgyptian)
            gGoldForecast = gGoldForecast + 200;
        else
            gWoodForecast = gWoodForecast + 200;

        if (gNavalAttackGoalID != -1)
        {
            // Ships
            int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
            temp = gTargetNavySize+2 - myShips; // How many yet to train
            if (temp < 0)
                temp = 0;
            if (temp > 0)
            {
                gWoodForecast = gWoodForecast + 175*temp;
                gGoldForecast = gGoldForecast + 100*temp;
            }
        }
        if (kbGetAge() >= cAge3)
        {
            if (gTransportMap == true)
                gWoodForecast = gWoodForecast + 350;
            // Fortress, etc.
            addUnitForecast(MyFortress, 1);

            // Fortified TC
            if (kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching)
                addTechForecast(cTechFortifyTownCenter);
        }
    }
}


rule econForecastAge4           // Rule activates when age 4 research begins
        minInterval 12
inactive
{
    static int ageStartTime = -1;
    int temp = 0;

    if ( (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) ) // Upgrade failed, revert
    {
        xsDisableSelf();
        xsEnableRule("econForecastAge3");
        return;
    }
    else if ((kbGetAge() > cAge3) && (ageStartTime == -1))
        ageStartTime = xsGetTime();

    gGoldForecast = 600;
    gWoodForecast = 600;
    gFoodForecast = 600;

    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);

    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 5*60*1000))
    {
        if (foodSupply < 1400)
            gFoodForecast = gFoodForecast + (1400 - foodSupply);
        if (woodSupply < 1200)
            gWoodForecast = gWoodForecast + (1200 - woodSupply);
        if (goldSupply < 1400)
            gGoldForecast = gGoldForecast + (1400 - goldSupply);
    }
    else
    {
        if (goldSupply < 500)
            gGoldForecast = gGoldForecast + (500 - goldSupply);
        if (woodSupply < 500)
            gWoodForecast = gWoodForecast + (500 - woodSupply);
        if (foodSupply < 500)
            gFoodForecast = gFoodForecast + (500 - foodSupply);
    }

    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (xsGetTime() - ageStartTime > 4*60*1000))
        addTechForecast(cTechSecretsoftheTitans);

    AddGenForecastNeeds();
    setMilitaryUnitCostForecast(); // add units before scaling down
    updateGathererRatios();
}


rule econForecastAge3           // Rule activates when age3 research begins, turns off when age 4 research begins
minInterval 11
inactive
{
    static int ageStartTime = -1;
    if ((kbGetTechStatus(gAge4MinorGod) >=  cTechStatusResearching) || (kbGetAge() > cAge3))// On our way to age 4, hand off...
    {
        xsEnableRule("econForecastAge4");
        econForecastAge4();
        xsDisableSelf();
        return; // We're done
    }
    else if ((kbGetAge() == cAge2) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching)) // Upgrade failed, revert
    {
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        return;
    }
    else if ((kbGetAge() == cAge3) && (ageStartTime == -1))
        ageStartTime = xsGetTime();

    gFoodForecast = 500;
    gGoldForecast = 500;
    gWoodForecast = 500;

    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);

    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 4*60*1000))
    {
        if (goldSupply < 1500)
            gGoldForecast = gGoldForecast + (1500 - goldSupply);
        if (foodSupply < 1500)
            gFoodForecast = gFoodForecast + (1500 - foodSupply);
        if (woodSupply < 500)
            gWoodForecast = gWoodForecast + (500 - woodSupply);
    }
    else
    {
        if (goldSupply < 350)
            gGoldForecast = gGoldForecast + (350 - goldSupply);
        if (foodSupply < 350)
            gFoodForecast = gFoodForecast + (350 - foodSupply);
        if (woodSupply < 350)
            gWoodForecast = gWoodForecast + (350 - woodSupply);
    }

    AddGenForecastNeeds();
    setMilitaryUnitCostForecast(); // add units before scaling down
    updateGathererRatios();
}


rule econForecastAge2           // Rule activates when age 2 research begins, turns off when age 3 research begins
minInterval 10
inactive
{
    static int ageStartTime = -1;
    if ((kbGetTechStatus(gAge3MinorGod) >= cTechStatusResearching) || (kbGetAge() > cAge2)) // On our way to age 3, hand off...
    {
        xsEnableRule("econForecastAge3");
        econForecastAge3();
        xsDisableSelf();
        return; // We're done
    }
    else if ((kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching)) // Upgrade failed, revert
    {
        xsDisableSelf();
        xsEnableRule("econForecastAge1");
        return;
    }
    else if ((kbGetAge() == cAge2) && (ageStartTime == -1))
        ageStartTime = xsGetTime();

    // If we've made it here, we're in age 2 (or researching it)
    gFoodForecast = 400;
    gGoldForecast = 400;
    gWoodForecast = 400;

    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);

    if ((ageStartTime != -1) && (xsGetTime() - ageStartTime > 3*60*1000))
    {
        if (goldSupply < 800)
            gGoldForecast = gGoldForecast + (800 - goldSupply);
        if (foodSupply < 1200)
            gFoodForecast = gFoodForecast + (1200 - foodSupply);
        if (woodSupply < 400)
            gWoodForecast = gWoodForecast + (400 - woodSupply);
    }
    else
    {
        if (goldSupply < 250)
            gGoldForecast = gGoldForecast + (250 - goldSupply);
        if (foodSupply < 250)
            gFoodForecast = gFoodForecast + (250 - foodSupply);
        if (woodSupply < 250)
            gWoodForecast = gWoodForecast + (250 - woodSupply);
    }
    // plow etc
    if ((kbGetTechStatus(cTechPlow) < cTechStatusResearching) && (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding) > 0))
        addTechForecast(cTechPlow);
    if (kbGetTechStatus(cTechShaftMine) < cTechStatusResearching)
        addTechForecast(cTechShaftMine);
    if (kbGetTechStatus(cTechBowSaw) < cTechStatusResearching)
        addTechForecast(cTechBowSaw);

    AddGenForecastNeeds();
    if ((xsGetTime() - ageStartTime > 2*60*1000) && (kbGetAge() == cAge2))
        setMilitaryUnitCostForecast(); // add units before scaling down

    updateGathererRatios();
}


rule econForecastAge1           // Rule active for mid age 1 (cAge1), gets started in setEarlyEcon rule, ending when next age upgrade starts
minInterval 0
inactive
{
    xsSetRuleMinIntervalSelf(2);
    if (kbGetAge() > cAge1)
    {
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        return;
    }
    int mainBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAlive);
    if ((kbGetAge() == cAge1) && (kbResourceGet(cResourceFood) >= 400) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching))
        aiTaskUnitResearch(mainBaseUnitID, gAge2MinorGod);

    if (kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
    { // Next age upgrade is on the way
        xsDisableSelf();
        xsEnableRule("econForecastAge2");
        econForecastAge2(); // Since runImmediately doesn't seem to be working
        if (cMyCulture == cCultureEgyptian)
            gHouseAvailablePopRebuild=30;
        else
            gHouseAvailablePopRebuild=18;
        return;
    }

    // If we've made it here, we're in age 1 (cAge1), we've been in the age at least 2 minutes,
    // and we haven't started the age 2 upgrade.  Let's see what we need.
    gFoodForecast = 600.0;
    gGoldForecast = 100.0;
    if (cMyCulture != cCultureEgyptian)
        gWoodForecast = 200.0;
    else
        gWoodForecast = 100.0;

    if (xsGetTime() > 1*60*1000)
    {
        if (cMyCulture != cCultureEgyptian)
        {
            gGoldForecast = gGoldForecast + 200;
            gWoodForecast = gWoodForecast + 300;
        }
        else
        {
            gGoldForecast = gGoldForecast + 300;
            gWoodForecast = gWoodForecast + 100;
        }
    }

    AddGenForecastNeeds();
    updateGathererRatios();
}


void updateGlutRatio(void)
{
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);

    gGlutRatio = 100.0; // ludicrously high

    if ( (goldSupply/gGoldForecast) < gGlutRatio )
        gGlutRatio = goldSupply/gGoldForecast;
    if ( (woodSupply/gWoodForecast) < gGlutRatio )
        gGlutRatio = woodSupply/gWoodForecast;
    if ( (foodSupply/gFoodForecast) < gGlutRatio )
        gGlutRatio = foodSupply/gFoodForecast;
    gGlutRatio = gGlutRatio * 1.5; // Double it, i.e. start reducing civ pop when all resources are > 50% of forecast

    if (gGlutRatio <= 0.0)
        gGlutRatio = 0.0;

    gFoodGlutRatio = foodSupply/gFoodForecast;
    gFoodGlutRatio = gFoodGlutRatio * 1.5;
    gWoodGlutRatio = woodSupply/gWoodForecast;
    gWoodGlutRatio = gWoodGlutRatio * 1.5;
    gGoldGlutRatio = goldSupply/gGoldForecast;
    gGoldGlutRatio = gGoldGlutRatio * 1.5;

    if ((kbGetAge() < cAge4) || (TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (gTransportMap == false))
        gGlutRatio = 0.0;

    if (gSomeData != -1)
    {
        aiPlanSetUserVariableFloat(gSomeData, 10, 0, gGlutRatio);
        aiPlanSetUserVariableFloat(gSomeData, 11, 0, gFoodGlutRatio);
        aiPlanSetUserVariableFloat(gSomeData, 12, 0, gGoldGlutRatio);
        aiPlanSetUserVariableFloat(gSomeData, 13, 0, gWoodGlutRatio);
    }
}


//==============================================================================
rule updatePrices   // This rule constantly compares actual supply vs. forecast, updates AICost // values (internal resource prices), and buys/sells at the market as appropriate
        minInterval 6
active
{
    // check for valid forecasts, exit if not ready
    updateGlutRatio();
    if (((gGoldForecast + gWoodForecast + gFoodForecast) < 100))
        return;

    xsSetRuleMinIntervalSelf(6);
    static int lastRequestTime = 0;
    float scaleFactor = 5.0; // Higher values make prices more volatile
    float goldStatus = 0.0;
    float woodStatus = 0.0;
    float foodStatus = 0.0;
    float minForecast = 200.0 * (1 + kbGetAge()); // 200, 400, 600, 800 in ages 1-5, prevents small amount from looking large if forecast is very low
    if (gGoldForecast > minForecast)
        goldStatus = scaleFactor * kbResourceGet(cResourceGold)/gGoldForecast;
    else
        goldStatus = scaleFactor * kbResourceGet(cResourceGold)/minForecast;
    if (gFoodForecast > minForecast)
        foodStatus = scaleFactor * kbResourceGet(cResourceFood)/gFoodForecast;
    else
        foodStatus = scaleFactor * kbResourceGet(cResourceFood)/minForecast;
    if (gWoodForecast > minForecast)
        woodStatus = scaleFactor * kbResourceGet(cResourceWood)/gWoodForecast;
    else
        woodStatus = scaleFactor * kbResourceGet(cResourceWood)/minForecast;

    // Status now equals inventory/forecast
    // Calculate value rate of wood:gold and food:gold.  1.0 means they're of the same status, 2.0 means
    // that the resource is one forecast more scarce, 0.5 means one forecast more plentiful, i.e. lower value.
    float woodRate = (1.0 + goldStatus)/(1.0 + woodStatus);
    float foodRate = (1.0 + goldStatus)/(1.0 + foodStatus);

    // The rates are now the instantaneous price for each resource.  Set the long-term prices by averaging this in
    // at a 5% weight.
    float cost = 0.0;

    // wood
    cost = kbGetAICostWeight(cResourceWood);
    cost = (cost * 0.95) + (woodRate * .05);
    kbSetAICostWeight(cResourceWood, cost);

    // food
    cost = kbGetAICostWeight(cResourceFood);
    cost = (cost * 0.95) + (foodRate * .05);
    kbSetAICostWeight(cResourceFood, cost);

    // Gold
    kbSetAICostWeight(cResourceGold, 1.00); // gold always 1.0, others relative to gold

    // Favor
    float favorCost = 15.0 - (14.0*(kbResourceGet(cResourceFavor)/100.0)); // 15 when empty, 2.0 when full
    if (favorCost < 1.0)
        favorCost = 1.0;
    kbSetAICostWeight(cResourceFavor, favorCost);

    // Update the gather plan goal
    for (i = 0; < 3)
    {
        aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, i, kbGetAICostWeight(i));
    }

    if ((aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 11*60*1000))
        return;

    //Compare that to the market price.  Buy if
    // the market price is lower and we have at least
    // 1/3 forecast of gold.  Sell if market price is higher and
    // we have at least 1/3 forecast of the resource.
    if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0)
    {
        float reserve = 500.0;
        if (kbGetAge() > cAge3)
            reserve = 800.0;

        if ( (goldStatus > 0.33) && (kbResourceGet(cResourceGold) > reserve) ) // We have some reserve of gold, OK to buy
        {
            if (((aiGetMarketBuyCost(cResourceFood)/100.0) < kbGetAICostWeight(cResourceFood)) && (kbResourceGet(cResourceFood) < 600)) // Market cheaper than our rate?
            {
                aiBuyResourceOnMarket(cResourceFood);
            }
            if (((aiGetMarketBuyCost(cResourceWood)/100.0) < kbGetAICostWeight(cResourceWood)) && (kbResourceGet(cResourceWood) < 600)) // Market cheaper than our rate?
            {
                aiBuyResourceOnMarket(cResourceWood);
            }
        }

        if ((woodStatus > 0.33) && (kbResourceGet(cResourceWood) > reserve)) // We have some reserve of wood, OK to sell
        {
            if (((aiGetMarketSellCost(cResourceWood)/100.0) > kbGetAICostWeight(cResourceWood)) && (kbResourceGet(cResourceGold) < 600)) // Market rate higher??
            {
                aiSellResourceOnMarket(cResourceWood);
            }
        }

        if ((foodStatus > 0.33) && (kbResourceGet(cResourceFood) > reserve)) // We have some reserve of food, OK to sell
        {
            if (((aiGetMarketSellCost(cResourceFood)/100.0) > kbGetAICostWeight(cResourceFood)) && (kbResourceGet(cResourceGold) < 600)) // Market rate higher??
            {
                aiSellResourceOnMarket(cResourceFood);
            }
        }
        if (kbResourceGet(cResourceGold) > 1300) // We have a lot of gold, OK to buy
        {
            if (kbResourceGet(cResourceFood) < 1200)
            {
                if (kbResourceGet(cResourceGold) > 1800)
                {
                    aiBuyResourceOnMarket(cResourceFood);
                    xsSetRuleMinIntervalSelf(1);
                }
                else
                {
                    aiBuyResourceOnMarket(cResourceFood);
                }
            }
            if (kbResourceGet(cResourceWood) < 800)
            {
                if (kbResourceGet(cResourceGold) > 1800)
                {
                    aiBuyResourceOnMarket(cResourceWood);
                    xsSetRuleMinIntervalSelf(1);
                }
                else
                {
                    aiBuyResourceOnMarket(cResourceWood);
                }
            }
        }

        if (kbResourceGet(cResourceFood) > 1400) // We have a lot of food, OK to sell
        {
            if (kbResourceGet(cResourceGold) < 1200)
            {
                if (kbResourceGet(cResourceFood) > 1800)
                {
                    aiSellResourceOnMarket(cResourceFood);
                    xsSetRuleMinIntervalSelf(1);
                }
                else
                {
                    aiSellResourceOnMarket(cResourceFood);
                }
            }
        }

        // Special Treatment for resource equalizing
        if (gFoodGlutRatio > 1.50)
        {
            if (gGoldGlutRatio < 1.50)
            {
                aiSellResourceOnMarket(cResourceFood);
                xsSetRuleMinIntervalSelf(1);

            }
        }
        if (gWoodGlutRatio > 1.50)
        {
            if (gGoldGlutRatio < 1.50)
            {
                aiSellResourceOnMarket(cResourceWood);
                xsSetRuleMinIntervalSelf(1);

            }
        }
        if (gGoldGlutRatio > 1.50)
        {
            if (gFoodGlutRatio < 1.50)
            {
                aiBuyResourceOnMarket(cResourceFood);
                xsSetRuleMinIntervalSelf(1);
            }
            if (gWoodGlutRatio < 1.50)
            {
                aiBuyResourceOnMarket(cResourceWood);
                xsSetRuleMinIntervalSelf(1);
            }
        }
    }

    if ((InfiniteAIAllies == true) && (kbGetAge() > cAge1))
    {
        if (((xsGetTime() - lastRequestTime) > 300000) && ((xsGetTime() - gLastSentTime) > 120000))
        {
            float totalResources = kbResourceGet(cResourceFood) + kbResourceGet(cResourceWood) + kbResourceGet(cResourceGold);
            if (totalResources > 1000.0)
            {
                if ((kbResourceGet(cResourceFood) < (totalResources / 10.0) && (kbResourceGet(cResourceFood) < 3500)))
                {
                    MessageRel(cPlayerRelationAlly, RequestFood, cLowPriority);
                    lastRequestTime = xsGetTime();
                }
                if ((kbResourceGet(cResourceGold) < (totalResources / 10.0) && (kbResourceGet(cResourceGold) < 3500)))
                {
                    MessageRel(cPlayerRelationAlly, RequestGold, cLowPriority);
                    lastRequestTime = xsGetTime();
                }
                if ((kbResourceGet(cResourceWood) < (totalResources / 10.0) && (kbResourceGet(cResourceWood) < 3500)))
                {
                    MessageRel(cPlayerRelationAlly, RequestWood, cLowPriority);
                    lastRequestTime = xsGetTime();
                }
            }
        }
    }
}
