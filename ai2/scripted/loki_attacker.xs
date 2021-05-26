bool banGatherersInGoldPlan = true; // initially ban gatherers so they focus on food

rule addGoldPlan
inactive
        minInterval 15 // after first gatherer is created
group lokiRushAge1
{
    foodPct = 0.9;
    goldPct = 0.1;
    numGoldPlans = 1;
    updateGatherGoals();
    xsDisableSelf();
}

rule ageUpASAP
inactive
minInterval 5
group lokiRushAge1
{
    if ((kbResourceGet(cResourceFood) >= 400) && kbGetAge() == cAge1 && (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive) > 0))
    {
        aiTaskUnitResearch(findUnit(cUnitTypeAbstractSettlement), gAge2MinorGod);
        echo("tasking age 2 up with: " + gAge2MinorGod);
        xsDisableSelf();
    }
}


rule trainDwarf
inactive
minInterval 5
group lokiRushAge1
{
    if ((kbResourceGet(cResourceGold) >= 70))
    {
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), dwarfTypeID);
        echo("trainDwarf triggered");
        xsDisableSelf();
        return();
    }

    echo("trainDwarf missed");
}


rule trainHersir
inactive
minInterval 5
group lokiRushAge1
{
    if (kbResourceGet(cResourceFood) >= 80 && kbResourceGet(cResourceGold) >= 40)
    {
        aiTaskUnitTrain(findUnit(cUnitTypeTemple), cUnitTypeHeroNorse);
        echo("trainHersir triggered");
        xsDisableSelf();
        return();
    }

    echo("trainHersir missed");
}


rule checkDwarves
inactive
minInterval 5
group lokiRushAge1
{
    int dwarfTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 1);
    int goldPlanID = findPlanByString("AutoGPGoldEasy");

    int minDwarves = 1;
    int wantedDwarves = 3;
    int maxDwarves = 5;

    // static int dwarfMaintainPlan = -1;
    // if(dwarfMaintainPlan < 0 && goldPlanID > 0) {
    //     // dwarfMaintainPlan = createSimpleMaintainPlan(cUnitTypeDwarf, maxDwarves, true, kbBaseGetMainID(cMyID));
    //     int planID = aiPlanCreate("Economy" + kbGetProtoUnitName(cUnitTypeDwarf) + "Maintain" + maxDwarves, cPlanTrain);
    //     dwarfMaintainPlan = planID;
    //     aiPlanSetEconomy(planID, true);
    //     aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeDwarf);
    //     aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, maxDwarves);
    //     aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

    //     aiPlanSetDesiredPriority(dwarfMaintainPlan, 90);
    //     aiPlanSetVariableInt(dwarfMaintainPlan, cTrainPlanIntoPlanID, 0, goldPlanID); // unfortunately, trainIntoPlan doesn't work
    //     aiPlanSetActive(planID);

    //     aiPlanAddUnitType(goldPlanID, cUnitTypeDwarf, minDwarves, wantedDwarves, maxDwarves ); // this does the trick, pulling dwarves to the gold plan
    // }

    if(banGatherersInGoldPlan)
        aiPlanAddUnitType(goldPlanID, cUnitTypeAbstractVillager, -1, -1, -1 ); // this does force villiagers out, but is reset every few seconds

    int numDwarves = kbUnitCount(cMyID, dwarfTypeID, cUnitStateAlive);
    if(numDwarves < 1) return;

    int vQID = kbUnitQueryCreate("checkDwarvesQuery");
    if (vQID < 0) return;

    configQuery(vQID, dwarfTypeID, -1, cUnitStateAlive, cMyID);
    kbUnitQueryResetResults(vQID);
    int numberOfDwarvesInQuery = kbUnitQueryExecute(vQID);
    for (i=0; < numberOfDwarvesInQuery)
    {
        int dwarfID = kbUnitQueryGetResult(vQID, i);
        int dwarfCurrentPlanID = kbUnitGetPlanID(dwarfID);
        // breakpoint;
        if(dwarfCurrentPlanID != goldPlanID) {
            aiPlanAddUnit(goldPlanID, dwarfID);
            echo("added to gold plan " + goldPlanID + " dwarfUnitID: " + dwarfID);
        }
    }
}

rule age2Manager
inactive
minInterval 5
group lokiRushAge2
{
    static bool runStep1 = true;
    if(runStep1) {
        runStep1 = false;
        xsEnableRule("buildRushLonghouse");
    }
    return;
}



rule age1Manager
inactive
minInterval 5
group lokiRushAge1
{
    int numGatherers = kbUnitCount(cMyID, gathererTypeID, cUnitStateAlive);
    int numDwarves = kbUnitCount(cMyID, dwarfTypeID, cUnitStateAlive);

    static bool runStep1 = true;
    static bool runStep2 = true;
    static bool runStep3 = true;
    int numTemplesBuilding = getNumUnits(cUnitTypeTemple, cUnitStateBuilding, -1, cMyID);
    int numTemplesComplete = getNumUnits(cUnitTypeTemple, cUnitStateAlive, -1, cMyID);

    // step 0: task training of units with initial resources
    if(runStep1) {
        runStep1 = false;
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), gathererTypeID);
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), dwarfTypeID);
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), gathererTypeID);
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), gathererTypeID);
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), gathererTypeID);
        aiTaskUnitTrain(findUnit(cUnitTypeAbstractSettlement), gathererTypeID);

        xsEnableRule("checkDwarves");
        xsEnableRule("addGoldPlan"); // delayed add of gold plan so initial villiagers dont get distracted
        xsEnableRule("ageUpASAP");
        xsEnableRule("buildRushTemple");
        xsEnableRule("createHerdplan");
    }
    else if (runStep2 && numTemplesBuilding >= 1)
    {
        // we have a temple going up. Train an extra dwarf and allow gatherers on gold for better resource gathering
        runStep2 = false;

        xsEnableRule("trainDwarf");
        banGatherersInGoldPlan = false;

        // update econ balance
        foodPct = 0.7;
        goldPct = 0.3;
        numGoldPlans = 1;
        updateGatherGoals();
    }
    else if(runStep3 && kbGetTechStatus(gAge2MinorGod) == cTechStatusResearching)
    {
        runStep3 = false;

        foodPct = 0.6;
        woodPct = 0.1;
        goldPct = 0.3;
        numWoodPlans = 1;
        updateGatherGoals();

        xsEnableRule("trainHersir");
        xsEnableRule("trainDwarf");
    }
    else if(kbGetAge() == cAge1)
    {
        return;
    }
    else
    {
        xsEnableRule("age2Manager");
        xsDisableSelf();
    }

}

void initScriptedLokiAttacker(void)
{
    // for when we want a tightly-controlled start to the game
    echo("initScriptedLokiAttacker start at:" + xsGetTime());
    onBuildOrders = 1;

    gathererTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 0);
    dwarfTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 1);

    initBases();

    cvAge2GodChoice = cTechAge2Heimdall;
    cvAge3GodChoice = cTechAge3Bragi;
    cvAge4GodChoice = cTechAge4Hel;

    // int mainBaseID = kbBaseGetMainID(cMyID);
    // int maxVills = 5;
    // int gathererTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer,0);
    // int villiagerMaintainPlan = createSimpleMaintainPlan(gathererTypeID, maxVills, true, mainBaseID);
    // aiPlanSetDesiredPriority(villiagerMaintainPlan, 90);

    initNorse();
    updateGatherGoals();

    //Setup the progression to follow these minor gods.
    kbTechTreeAddMinorGodPref(gAge2MinorGod);
    kbTechTreeAddMinorGodPref(gAge3MinorGod);
    kbTechTreeAddMinorGodPref(gAge4MinorGod);
    echo("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));

    xsEnableRule("age1Manager");

    echo("initScriptedLokiAttacker done at: " + xsGetTime());
}
