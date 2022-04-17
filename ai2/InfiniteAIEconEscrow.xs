int prevEconPop = -1;
int prevMilPop = -1;
void updateEM(int econPop=-1, int milPop=-1, float econPercentage=0.5,
              float rootEscrow=0.2, float econFoodEscrow=0.5, float econWoodEscrow=0.5,
              float econGoldEscrow=0.5, float econFavorEscrow=0.5)
{
    if (cMyCulture == cCultureNorse) // Make room for at least 3 oxcarts
    {
        if (econPop < 25)
            econPop = econPop + 3;
    }

    //Econ Pop (if we're allowed to change it).
    if ((gHardEconomyPopCap > 0) && (econPop > gHardEconomyPopCap))
        econPop=gHardEconomyPopCap;
    if ( (econPop > cvMaxGathererPop)  && (cvMaxGathererPop >= 0) )
        econPop = cvMaxGathererPop;

    // Check if we're second age.  If so, consider capping the mil lower for boomers
    if (kbGetAge() == cAge2)
    {
        if ( (gRushGoalID == -1) || /* If we don't have a rush goal, or... */
             (aiPlanGetVariableInt(gRushGoalID, cGoalPlanExecuteCount, 0) >= aiPlanGetVariableInt(gRushGoalID, cGoalPlanRepeat, 0))
             ) // We have a rush goal, but we're done rushing
        {
            // Let's decrease our military pop
            float milPopDelta = (cvRushBoomSlider*4.0)/5.0; // Zero for balanced, -.80 for extreme boom
            if (milPopDelta > 0)
                milPopDelta = 0; // Don't increase for rushers
            // Adjust it for econ/mil scale.  If military, soften the decrease, if economic, preserve full.
            milPopDelta = milPopDelta / (2.0 + cvMilitaryEconSlider);
            milPop = milPop + (milPop * milPopDelta);
            echo("updateEM - military pop decreased to: " + milPop);
        }
        if (milPop < 40)
            milPop = 40;
    }

    if ((milPop < 0) && (cvMaxMilPop >= 0)) // milPop says no limit, but cvMaxMilPop has one
        milPop = cvMaxMilPop;
    if ((milPop > cvMaxMilPop) && (cvMaxMilPop >= 0)) // cvMaxMilPop has limit and milPop is over it
        milPop = cvMaxMilPop;

    aiSetEconomyPop(econPop);
    aiSetMilitaryPop(milPop);

    // Check to make sure attack goals have ranges below our milPop limit
    int upID = gRushUPID;
    if (kbGetAge() > cAge2)
        upID = gLateUPID;

    int milMin = kbUnitPickGetMinimumPop(upID);
    int milMax = kbUnitPickGetMaximumPop(upID);
    if (milMax > milPop) // We have a problem
    {
        kbUnitPickSetMaximumPop(upID,(milPop*4)/5);
        kbUnitPickSetMinimumPop(upID,(milPop*3)/5);
    }

    //Percentages.
    aiSetEconomyPercentage(1.0);
    aiSetMilitaryPercentage(1.0);

    //Get the amount of the non-root pie.
    float nonRootEscrow=1.0-rootEscrow;
    //Track whether or not we need to redistribute the resources.
    //Econ Food Escrow.
    float v=nonRootEscrow*econFoodEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceFood, v);
    //Econ Wood Escrow
    v=nonRootEscrow*econWoodEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceWood, v);
    //Econ Gold Escrow
    v=nonRootEscrow*econGoldEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceGold, v);
    //Econ Favor Escrow
    v=nonRootEscrow*econFavorEscrow;
    kbEscrowSetPercentage(cEconomyEscrowID, cResourceFavor, v);
    //Military Escrow.
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFood, nonRootEscrow*(1.0-econFoodEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceWood, nonRootEscrow*(1.0-econWoodEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceGold, nonRootEscrow*(1.0-econGoldEscrow));
    kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFavor, nonRootEscrow*(1.0-econFavorEscrow));
    if (gSomeData != -1)
    {
        aiPlanSetUserVariableFloat(gSomeData, EcoPercentage, 0, v * 100);
        aiPlanSetUserVariableFloat(gSomeData, MilPercentage, 0, nonRootEscrow*(1.0-econFoodEscrow) * 100);
        aiPlanSetUserVariableFloat(gSomeData, RootPercentage, 0, rootEscrow * 100);
    }
    int vilPop= aiGetEconomyPop(); // Total econ
    if (gFishing == true)
    {
        int fishCount = gNumBoatsToMaintain;
        if ( (aiGetGameMode() == cGameModeLightning) && (fishCount > 5) )
            fishCount = 5;
        vilPop = vilPop - fishCount; // Less fishing
        echo("updateEM - fishCount = " + fishCount);
        echo("updateEM - (vilPop - fishCount) = " + vilPop);
    }

    int numTradeUnits = kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
    if (numTradeUnits > 0 && infinitePopMode == false)
    {
        int tradeCount = numTradeUnits;
        if ((aiGetGameMode() == cGameModeLightning) && (tradeCount > 5))
            tradeCount = 5;
        vilPop = vilPop - tradeCount; // Vils = total-trade
        echo("updateEM - tradeCount = " + tradeCount);
        echo("updateEM - (vilPop - tradeCount) = " + vilPop);
    }

    if ((vilPop < 15) && (kbGetAge() > cAge1))
        vilPop = 15;

    if (cMyCulture == cCultureAtlantean)
        vilPop = vilPop / 3;

    // Brutal hack to make Lightning work.
    if (aiGetGameMode() == cGameModeLightning)
    { // Make sure we don't try to overtrain villagers
        int lightningLimit = 25; // Greek/Egyptian;
        if (cMyCulture == cCultureNorse)
            lightningLimit = 20;
        else if (cMyCulture == cCultureAtlantean)
            lightningLimit = 6;
        if (vilPop > lightningLimit)
            vilPop = lightningLimit;
    }

    //Update the number of vils to maintain.
    int gathererPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer,0);
    if ((kbCanAffordUnit(gathererPUID, cEconomyEscrowID) == true) && (kbUnitCount(cMyID, gathererPUID, cUnitStateAlive) < vilPop * 0.8) &&
        (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) > 0) && (kbGetPopCap() != kbGetPop()) && (AgingUp() == false))
    {
        static int LastCount = 0;
        int CurrentTrained = aiPlanGetNumberVariableValues(gCivPopPlanID, cTrainPlanTrainedUnitID);
        if ((CurrentTrained > LastCount) || (kbUnitCount(cMyID, gathererPUID, cUnitStateBuilding) > 0))
        {
            FailedToTrain = 0;
            LastCount = CurrentTrained;
        }
        else if (CurrentTrained == LastCount)
        {
            FailedToTrain = FailedToTrain+1;
        }
        if (FailedToTrain >= 4)
        {
            aiPlanDestroy(gCivPopPlanID);
            FailedToTrain = 0;
            LastCount = 0;
            createCivPopPlan();
        }
    }
    aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, vilPop);
    if (gSomeData != -1)
        aiPlanSetUserVariableInt(gSomeData, 7, 0, vilPop);

    if(econPop != prevEconPop) {
        echo("updateEM - econPop set to: " + econPop);
        prevEconPop = econPop;
    }
    if(milPop != prevMilPop) {
        echo("updateEM - milPop set to: " + milPop);
        prevMilPop = milPop;
    }
}


rule updateEMAllAges
        minInterval 12 //starts in cAge1
inactive
group reth
{
    int civPopTarget=-1;
    int milPopTarget=-1;
    static int ageStartTime3 = -1;
    static int ageStartTime4 = -1;
    float econPercent = 1.0; // Econ priority rating, range 0..1
    float econEscrow = 1.0; // Economy's share of non-root escrow, range 0..1
    updateGlutRatio();

    if ((RiverSLowBoar == true) && (kbGetAge() < cAge2) && (aiGetWorldDifficulty() < cDifficultyNightmare))
    {
        if (RetardedLowBoarSpawn = true)
            civPopTarget = 13;
        else
            civPopTarget = 18;
        milPopTarget = 60;
    }
    else if ((kbGetAge() < cAge2) && (aiGetWorldDifficulty() >= cDifficultyModerate))
    {
        civPopTarget = 12; // lower civPopTarget to encourage faster aging up
        milPopTarget = 60;
    }
    else if (aiGetWorldDifficulty() <= cDifficultyModerate)
    {
        if (aiGetWorldDifficulty() == cDifficultyEasy)
        {
            civPopTarget = 18;
            milPopTarget = 32;
        }
        else
        {
            civPopTarget = 34;
            if (aiGetGameMode() == cGameModeLightning)
                civPopTarget = 15;
            milPopTarget = 50;
        }
    }
    else
    {
        civPopTarget = 61;
        if (getSoftPopCap() > 115)
            civPopTarget = civPopTarget + 0.2 * (getSoftPopCap()-115); // Plus 20% over 115
        if (gGlutRatio > 1.0)
            civPopTarget = civPopTarget / gGlutRatio;
        if ((aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35))
            civPopTarget = 35;
        if (civPopTarget > 80)
            civPopTarget = 80;
        if (civPopTarget < 20)
            civPopTarget = 20;
        milPopTarget = getSoftPopCap() - civPopTarget;
        if ((kbGetAge() == cAge3) && (ageStartTime3 == -1))
            ageStartTime3 = xsGetTime();
        if ((kbGetAge() == cAge4) && (ageStartTime4 == -1))
            ageStartTime4 = xsGetTime();
    }

    if (kbGetAge() > cAge1)
    {
        if ((aiGetWorldDifficulty() >= cDifficultyHard) && (kbGetAge() >= cAge3))
        {
            kbUnitPickSetMinimumPop(gLateUPID, milPopTarget*.5);
            kbUnitPickSetMaximumPop(gLateUPID, milPopTarget*.75);
        }

        if (kbGetAge() == cAge2)
        {
            econPercent = 0.5;
            econEscrow = 0.5;
        }
        else if (kbGetAge() == cAge3)
        {
            econPercent = 0.3;
            econEscrow = 0.3;
        }
        else
        {
            econPercent = 0.15;
            econEscrow = 0.15;
        }

        if ((kbGetAge() >= cAge3) || (kbGetAge() >= cAge2) && (cMyCiv == cCivNuwa))
        {
            int BonusCaravan = 0;
            if (gGlutRatio < 1.0)
                BonusCaravan = BonusCaravan + 4;

            if ((aiGetWorldDifficulty() >= cDifficultyHard) && (aiGetGameMode() != cGameModeLightning))
            {
                int numWoodPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0);
                if (numWoodPlans < 1)
                    BonusCaravan = BonusCaravan + 4;
                int numGoldPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0);
                if (numGoldPlans < 1)
                    BonusCaravan = BonusCaravan + 4;
            }

            if (gGlutRatio >= 1.15)
            {
                float Increase = 0.0;
                if (gGlutRatio >= 1.15)
                    Increase = gGlutRatio -1.15;
                Increase = Increase * 20;
                gMaxTradeCarts = defWantedCaravans+BonusCaravan-Increase;
                if (gMaxTradeCarts <= 0)
                    gMaxTradeCarts = 0;
            }
            else
                gMaxTradeCarts = defWantedCaravans + BonusCaravan;
            if (gSomeData != -1)
                aiPlanSetUserVariableInt(gSomeData, 9, 0, gMaxTradeCarts);
        }
        float econAdjust = -.5 * cvMilitaryEconSlider;
        float econShortage = aiGetAvailableEconomyPop();
        float econTarget = aiGetEconomyPop();
        econShortage = econShortage / econTarget;
        econAdjust = econAdjust + econShortage;
        if (econAdjust > 1.0)
            econAdjust = 1.0;
        if (econAdjust < -1.0)
            econAdjust = -1.0;

        econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);
        econEscrow = econPercent;

        if ((xsGetTime() > 10*60*1000) && (kbGetAge() == cAge2) && (AgingUp() == false) ||
            (xsGetTime() > 22*60*1000) && (AgingUp() == false) && (xsGetTime() - ageStartTime3 > 6*60*1000) && (kbGetAge() == cAge3)
            || (kbGetAge() == cAge3) && (AgingUp() == false) && (xsGetTime() - ageStartTime3 > 3*60*1000) && (ShouldIAgeUp() == true)
            || (TitanAvailable == true) && (kbGetAge() == cAge4) && (AgingUp() == false) && (gTransportMap == false) && (xsGetTime() - ageStartTime4 > 3*60*1000))
        {
            if (econEscrow < 0.35)
                econEscrow = 0.35;
        }
        if (econEscrow < 0.15)
            econEscrow = 0.15;
    }
    //Update all the econ stuff
    if ((kbGetAge() >= cAge2) && ((aiGetWorldDifficulty() >= cDifficultyHard)) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 1))
    {
        int ModdedCivPop = 0;
        float Vills = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
        if (cMyCulture == cCultureAtlantean)
            Vills = Vills * 3;
        int numTradeUnits = kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
        int FishShips = kbUnitCount(cMyID, cUnitTypeUtilityShip, cUnitStateAlive);
        ModdedCivPop = Vills + FishShips + numTradeUnits;
        civPopTarget = ModdedCivPop;
        if (civPopTarget < 25)
            civPopTarget = 25;
        milPopTarget = getSoftPopCap() - civPopTarget;
    }

    if (gLogUpdateEMAllAges == true)
    {
        echo("updateEMAllAges.aiGetAvailableEconomyPop: " + aiGetAvailableEconomyPop());
        echo("updateEMAllAges.civPopTarget: " + civPopTarget);
        echo("updateEMAllAges.milPopTarget: " + milPopTarget);
        echo("updateEMAllAges.econPercent: " + econPercent);
        echo("updateEMAllAges.econEscrow: " + econEscrow);
    }
    
    updateEM(civPopTarget, milPopTarget, econPercent, 0.20, econEscrow, econEscrow, econEscrow, econEscrow);
}


rule checkEscrow    //Verify that escrow totals and real inventory are in sync
minInterval 6 //starts in cAge1
inactive
group reth
{
    static int failCount = 0;
    static bool FirstRun = false; // Special reset in first 5 minutes for wood imbalance while fishing
    // (Every fishing boat trained gets double-billed.)
    bool needReset = false;
    int res = -1;
    for (res = 0; < 3)
    {
        int escrowQty = -1;
        int actualQty = -1;
        int delta = -1;
        escrowQty = kbEscrowGetAmount(cEconomyEscrowID, res);
        escrowQty = escrowQty + kbEscrowGetAmount(cMilitaryEscrowID, res);
        escrowQty = escrowQty + kbEscrowGetAmount(cRootEscrowID, res);
        actualQty = kbResourceGet(res);
        delta = actualQty - escrowQty;
        if (delta < 0)
            delta = delta * -1;
        if ( (delta > 20) && (delta > actualQty/5) ) // Off by at least 20, and 20%
            needReset = true;
    }

    if (FirstRun == false)
    {
        kbEscrowAllocateCurrentResources();
        FirstRun = true;
        return;
    }
    if (needReset == true)
    {
        failCount = failCount+1;
        if (failCount > 0)
        {
            float OldMilFood = kbEscrowGetPercentage(cMilitaryEscrowID, cResourceFood);
            float OldMilWood = kbEscrowGetPercentage(cMilitaryEscrowID, cResourceWood);
            float OldMilGold = kbEscrowGetPercentage(cMilitaryEscrowID, cResourceGold);
            float OldMilFavor = kbEscrowGetPercentage(cMilitaryEscrowID, cResourceFavor);

            float OldEcoFood = kbEscrowGetPercentage(cEconomyEscrowID, cResourceFood);
            float OldEcoWood = kbEscrowGetPercentage(cEconomyEscrowID, cResourceWood);
            float OldEcoGold = kbEscrowGetPercentage(cEconomyEscrowID, cResourceGold);
            float OldEcoFavor = kbEscrowGetPercentage(cEconomyEscrowID, cResourceFavor);

            if (kbGetAge() >= cAge1)
            {
                for (i = 0; < cNumResourceTypes+1) // also favour
                {
                    float ActualResource =  kbResourceGet(i);
                    float EcoBankAccount = kbEscrowGetAmount(cEconomyEscrowID, i);
                    float MilBankAccount = kbEscrowGetAmount(cMilitaryEscrowID, i);
                    float RootBankAccount = kbEscrowGetAmount(cRootEscrowID, i);
                    float e =  EcoBankAccount/ ActualResource;
                    float m = MilBankAccount/ ActualResource;
                    float r = RootBankAccount/ ActualResource;
                    if (e > 1.00)
                        e = 1.00;
                    if (e < 0.0)
                        e = 0.0;
                    if (m > 1.00)
                        m = 1.00;
                    if (m < 0.0)
                        m = 0.0;
                    if (r > 1.00)
                        r = 1.00;
                    if (r < 0.0)
                        r = 0.0;
                    kbEscrowSetPercentage(cEconomyEscrowID, i, e);
                    kbEscrowSetPercentage(cMilitaryEscrowID, i, m);
                    kbEscrowSetPercentage(cRootEscrowID, i, r);
                }
            }
            //aiEcho("ERROR:  Escrow balances invalid.  Reallocating");
            kbEscrowAllocateCurrentResources();

            kbEscrowSetPercentage(cEconomyEscrowID, cResourceFood, OldEcoFood);
            kbEscrowSetPercentage(cEconomyEscrowID, cResourceWood, OldEcoWood);
            kbEscrowSetPercentage(cEconomyEscrowID, cResourceGold, OldEcoGold);
            kbEscrowSetPercentage(cEconomyEscrowID, cResourceFavor, OldEcoFavor);
            //Military Escrow.
            kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFood, OldMilFood);
            kbEscrowSetPercentage(cMilitaryEscrowID, cResourceWood, OldMilWood);
            kbEscrowSetPercentage(cMilitaryEscrowID, cResourceGold, OldMilGold);
            kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFavor, OldMilFavor);
            // Root
            for (k = 0; < cNumResourceTypes+1)
            {
                kbEscrowSetPercentage(cRootEscrowID, k, 0.20);
            }
        }
    }
    else
        failCount = 0;

    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    static int count = 0;
    static int countB = 0;
    int gathererPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer,0);
    int VilPop = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);
    int mainBaseUnitID = getMainBaseUnitIDForPlayer(cMyID);
    int ReserveAmount = 75;
    if (cMyCulture == cCultureAtlantean)
        ReserveAmount = 150;

    if ((kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching))
    {
        if ((kbResourceGet(cResourceFood) >= 400) && (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive) > 0))
            aiTaskUnitResearch(findUnit(cUnitTypeAbstractSettlement), gAge2MinorGod);
        if ((kbCanAffordUnit(gathererPUID, cEconomyEscrowID) == true) && (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAliveOrBuilding) < VilPop)
            && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) > 0) && (AgingUp() == false) && (kbResourceGet(cResourceFood) < 300)
            && (kbUnitCount(cMyID, gathererPUID, cUnitStateBuilding) == 1))
        {
            if ((cMyCulture != cCultureNorse) || (kbUnitCount(cMyID, cUnitTypeOxCart, cUnitStateAliveOrBuilding) > 0) && (kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAliveOrBuilding) > 0))
            {
                if (aiTaskUnitTrain(mainBaseUnitID, gathererPUID))
                    FailedToTrain = 0;
            }
        }
    }
    if ((kbGetAge() > cAge1) && (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAliveOrBuilding) < VilPop))
    {
        float RootAndEcoF = (kbEscrowGetAmount(cEconomyEscrowID, cResourceFood) + kbEscrowGetAmount(cRootEscrowID, cResourceFood));
        if (RootAndEcoF < ReserveAmount)
        {
            kbEscrowFlush(cMilitaryEscrowID, cResourceFood, true);
            if ((kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0) && (foodSupply < ReserveAmount))
            {
                if ((aiGetMarketBuyCost(cResourceFood) < goldSupply) && (count > 1))
                {
                    aiBuyResourceOnMarket(cResourceFood);
                    count = 0;
                }
                else
                    count = count + 1;
            }
        }
        else
        {
            count = 0;
        }
        float RootAndEcoW = (kbEscrowGetAmount(cEconomyEscrowID, cResourceWood) + kbEscrowGetAmount(cRootEscrowID, cResourceWood));
        ReserveAmount = 50;
        if ((RootAndEcoW <= ReserveAmount) && (cMyCulture == cCultureAtlantean)
            || (RootAndEcoW <= ReserveAmount) && (cMyCulture == cCultureNorse) && (kbUnitCount(cMyID, cUnitTypeOxCart, cUnitStateAliveOrBuilding) < 3) && (kbGetAge() < cAge3))
        {
            kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);
            if ((kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0) && (woodSupply < ReserveAmount))
            {
                if ((aiGetMarketBuyCost(cResourceWood) < goldSupply) && (countB > 1))
                {
                    aiBuyResourceOnMarket(cResourceWood);
                    countB = 0;
                }
                else
                    countB = countB + 1;
            }
        }
        else
        {
            countB = 0;
        }

    }

    if ((aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true) > 0) && (kbUnitCount(0, cUnitTypeAbstractSettlement) > 0) &&
        (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSettlementLevel1, true) > 0) && (foodSupply > 150))
    {
        if ((kbGetAge() == cAge2) && (xsGetTime() < 13*60*1000) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < gEarlySettlementTarget) || (kbGetAge() > cAge2) && (ShouldIAgeUp() == false))
        {
            float iCost = 0;
            if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) >= gEarlySettlementTarget)
                iCost = 150;
            if ((cMyCulture != cCultureEgyptian) && (woodSupply > 300+iCost) && (goldSupply > 300+iCost) || (cMyCulture == cCultureEgyptian) && (goldSupply > 400+iCost))
            {
                if (cMyCulture != cCultureEgyptian)
                {
                    kbEscrowFlush(cEconomyEscrowID, cResourceWood, true);
                    kbEscrowFlush(cMilitaryEscrowID, cResourceWood, true);
                }
                kbEscrowFlush(cEconomyEscrowID, cResourceGold, true);
                kbEscrowFlush(cMilitaryEscrowID, cResourceGold, true);
                echo("Flushing wood and gold escrow for gEarlySettlementTarget building");
            }
        }
    }

    if (kbGetAge() == cAge2)
    {
        if ((foodSupply >= 800) && (goldSupply >= 500) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            aiTaskUnitResearch(findUnit(cUnitTypeAbstractSettlement), gAge3MinorGod);
    }
    else if (kbGetAge() == cAge3)
    {
        if ((foodSupply >= 1000) && (goldSupply >= 1000) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) && (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0))
            aiTaskUnitResearch(findUnit(cUnitTypeAbstractSettlement), gAge4MinorGod);
    }
    else if (kbGetAge() > cAge3)
    {
        if ((cMyCulture == cCultureGreek) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching)
            && (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechForgeofOlympus, true) >= 0))
        {
            if ((goldSupply > 300) && (favorSupply > 30))
                aiTaskUnitResearch(findUnit(cUnitTypeArmory), cTechForgeofOlympus);
        }
        if ((foodSupply >= 800) && (goldSupply >= 800) && (woodSupply >= 800) && (favorSupply >= 50) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) &&
            (TitanAvailable == true) && (gTransportMap == false))
            aiTaskUnitResearch(mainBaseUnitID, cTechSecretsoftheTitans);
    }
}
