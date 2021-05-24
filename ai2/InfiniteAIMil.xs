//==============================================================================
// InfiniteAI
// InfiniteAIMil.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// military stuff
//==============================================================================


//==============================================================================
rule monitorDefPlans
        minInterval 11 //starts in cAge2
inactive
{
    xsSetRuleMinIntervalSelf(11);
    static int HelpTimer = -1;
    if (HelpTimer == -1)
        HelpTimer = xsGetTime();
    static int ResourceTimer = -1;
    if (ResourceTimer == -1)
        ResourceTimer = xsGetTime();

    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true); // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        int mainBaseID = kbBaseGetMainID(cMyID);
        vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);

        int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);

        int numMilUnitsInOB1DefPlan = aiPlanGetNumberUnits(gOtherBase1DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB2DefPlan = aiPlanGetNumberUnits(gOtherBase2DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB3DefPlan = aiPlanGetNumberUnits(gOtherBase3DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB4DefPlan = aiPlanGetNumberUnits(gOtherBase4DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInBUADefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInSPDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);

        float woodSupply = kbResourceGet(cResourceWood);
        float foodSupply = kbResourceGet(cResourceFood);
        float goldSupply = kbResourceGet(cResourceGold);

        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            int numMilUnitsInDefPlan = aiPlanGetNumberUnits(defendPlanID, cUnitTypeLogicalTypeLandMilitary);

            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int mySettlementsAtDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);
            float distToMainBase = xsVectorLength(mainBaseLocation - defPlanDefPoint);

            int militaryUnitType = cUnitTypeMilitary;
            int enemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int enemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);

            int numAttEnemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int numAttEnemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);

            int numAttEnemySiegeInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);

            int numAttEnemyTitansInR50 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int requiredUnits = enemyMilUnitsInR80;

            int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, defPlanBaseID);

            if (((defendPlanID == gDefendPlanID) && (defPlanBaseID == mainBaseID)) || (defendPlanID == gMBDefPlan1ID))
            {
                if (defendPlanID == gMBDefPlan1ID)
                {
                    if ((numAttEnemyMilUnitsInR80 > 10) || (numEnemyTitansNearMBInR80 > 0))
                    {
                        if ((requiredUnits < 30) && (numEnemyTitansNearMBInR80 > 0))
                        {
                            //since there's an enemy Titan near our main base we need a lot of units
                            requiredUnits = 30; //fake number to force a lot of units into our defend plan
                        }
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, requiredUnits / 4, requiredUnits / 2 + 3, requiredUnits / 2 + 3);
                    }
                    else
                    {
                        if (kbGetAge() == cAge2)
                            aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 8, 8);
                        else
                            aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);
                    }


                    if ((secondsUnderAttack > 0) || (enemyMilUnitsInR80 > 8))
                        aiPlanSetDesiredPriority(defendPlanID, 54);
                    else
                    {
                        aiPlanSetDesiredPriority(defendPlanID, 38); //TODO: find the best value
                    }

                    //override if there is an enemy Titan near our main base
                    if (numEnemyTitansNearMBInR80 > 0)
                        aiPlanSetDesiredPriority(defendPlanID, 60);
                }

                if ((InfiniteAIAllies == true) && (secondsUnderAttack > 5) &&
                    (enemyMilUnitsInR80 > numMilUnitsInDefPlan))
                {
                    if (xsGetTime() - ResourceTimer > 1*20*1000)
                    {
                        //Ask for resources too!
                        if (foodSupply < 250)
                        {
                            MessageRel(cPlayerRelationAlly, RequestFood);
                            echo("AI Comms: Low on Food and under attack.. Requesting Food!");
                        }
                        if (woodSupply < 200)
                        {
                            MessageRel(cPlayerRelationAlly, RequestWood);
                            echo("AI Comms: Low on Wood and under attack.. Requesting Wood!");
                        }
                        if (goldSupply < 250)
                        {
                            MessageRel(cPlayerRelationAlly, RequestGold);
                            echo("AI Comms: Low on Gold and under attack.. Requesting Gold!");
                        }
                        ResourceTimer = xsGetTime();
                    }

                    if (xsGetTime() - HelpTimer > 1*60*1000)
                    {
                        vector TCLoc = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                        int TCID = findClosestUnitTypeByLoc(cPlayerRelationSelf, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, TCLoc, 30);
                        if (TCID != -1)
                        {
                            HelpTimer = xsGetTime();
                            MessageRel(cPlayerRelationAlly, INeedHelp, TCID);
                            echo("AI Comms: Requesting Help at TC ID: "+TCID);
                            vector TowerLocation=kbBaseGetLastKnownDamageLocation(cMyID, defPlanBaseID);
                            if ((equal(TowerLocation, cInvalidVector) == false) && (defPlanBaseID == mainBaseID))
                                MessageRel(cPlayerRelationAlly, RequestTower, VectorData, TowerLocation);
                        }
                    }
                }
                if ((cMyCulture == cCultureEgyptian) || (kbGetTechStatus(cTechAge2Okeanus) == cTechStatusActive) ||
                    (kbGetTechStatus(cTechAge2Freyja) == cTechStatusActive) || (cMyCulture == cCultureChinese) || (cMyCulture == cCultureGreek))
                {
                    int HealUnit = cUnitTypePriest;
                    if (cMyCulture == cCultureAtlantean)
                        HealUnit = cUnitTypeFlyingMedic;
                    else if (cMyCulture == cCultureNorse)
                        HealUnit = cUnitTypeValkyrie;
                    else if (cMyCulture == cCultureChinese)
                        HealUnit = cUnitTypeHeroChineseMonk;
                    else if (cMyCulture == cCultureGreek)
                        HealUnit = cUnitTypePhysician;
                    int Unit = findUnit(HealUnit, cUnitStateAlive, cActionIdle, cMyID, mainBaseLocation, 85);
                    if ((cMyCulture == cCultureEgyptian) && (Unit == -1))
                        Unit = findUnit(cUnitTypeAbstractPharaoh, cUnitStateAlive, cActionIdle, cMyID, mainBaseLocation, 85);
                    if (Unit != -1)
                    {
                        int Healables = getNumUnits(cUnitTypeLogicalTypeCanBeHealed, cUnitStateAlive, -1, cMyID, mainBaseLocation, 85);
                        for (b = 0; < Healables)
                        {
                            int unitID = findUnitByIndex(cUnitTypeLogicalTypeCanBeHealed, b, cUnitStateAlive, -1, cMyID, mainBaseLocation, 85);
                            if (unitID == Unit)
                                continue;
                            if ((unitID != -1) && (kbUnitGetHealth(unitID) < 1.0))
                            {
                                aiTaskUnitWork(Unit, unitID);
                                break;
                            }
                        }
                    }
                }
                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 60.0); //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                continue;
            }
            else if ((defendPlanID == gOtherBase1DefPlanID) || (defendPlanID == gOtherBase2DefPlanID)
                     || (defendPlanID == gOtherBase3DefPlanID) || (defendPlanID == gOtherBase4DefPlanID)
                     || ((defendPlanID == gDefendPlanID) && (defPlanBaseID != mainBaseID)))
            {
                if (defendPlanID == gDefendPlanID)
                {
                    if (aiPlanGetBaseID(gBaseUnderAttackDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInBUADefPlan;
                    if (aiPlanGetBaseID(gSettlementPosDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInSPDefPlan;
                    if (aiPlanGetBaseID(gOtherBase1DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB1DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase2DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB2DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase3DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB3DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase4DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB4DefPlan;
                }
                else
                {
                    if (aiPlanGetBaseID(gBaseUnderAttackDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInBUADefPlan;
                    if (aiPlanGetBaseID(gSettlementPosDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInSPDefPlan;
                    if (aiPlanGetBaseID(gDefendPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsIngDefendPlan;
                }
                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 48.0); //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);

                if (defendPlanID != gDefendPlanID)
                {
                    if ((secondsUnderAttack > 0) || (numMilUnitsInDefPlan < enemyMilUnitsInR50))
                    {
                        aiPlanSetDesiredPriority(defendPlanID, 56);
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 1, 1);
                    }
                    else
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);
                        if (distToMainBase < 70)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 25);
                        }
                        else if (distToMainBase < 90)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 27);
                        }
                        else if (distToMainBase < 110)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 29);
                        }
                        else if (distToMainBase < 130)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 31);
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 33);
                        }
                    }
                    continue;
                }
                continue;
            }
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 48.0); //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
                int priorityA = 48;
                if (distToMainBase > 90.0)
                    priorityA = 52;
                static int countA = 0;
                static int resourceCountA = 0; // add more
                if ((enemyMilUnitsInR50 < 4) && (numAttEnemySiegeInR50 < 1) && (numAttEnemyTitansInR50 < 1))
                {
                    if (countA <= 14)
                    {
                        if ((distToMainBase < 85.0) && (NumEnemyBuildings > 6))
                            aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 12, 19, 19);
                        else
                        {
                            if ((distToMainBase > 100.0) && (NumEnemyBuildings > 6))
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 11, 22, 24);
                            else
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 5, 8, 10);
                        }

                        if (countA >= 12)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.3);
                        }
                        else if (countA >= 9)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.5);
                        }
                        else if (countA >= 6)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.7);
                        }
                        else if (countA >= 3)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.9);
                        }
                        countA = countA + 1;
                        continue;
                    }
                    else
                    {
                        countA = 0;
                        xsSetRuleMinInterval("defendSettlementPosition", 1);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(defendPlanID);
                        continue;
                    }
                }
                else
                {
                    if (enemyMilUnitsInR50 > 18)
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 8);

                    if ((((woodSupply < 350) || (goldSupply < 350)) && (mySettlementsAtDefPoint < 1)) || ((woodSupply < 300) && (goldSupply < 300) && (foodSupply < 300)))
                    {
                        if (resourceCountA <= 1)
                            resourceCountA = resourceCountA + 1;
                        else
                        {
                            resourceCountA = 0;
                            xsSetRuleMinInterval("defendSettlementPosition", 1);
                            xsDisableRule("defendSettlementPosition");
                            aiPlanDestroy(defendPlanID);
                            continue;
                        }
                    }
                    else
                        resourceCountA = 0;
                    countA = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityA);
                    continue;
                }
            }
            else if (defendPlanID == gBaseUnderAttackDefPlanID)
            {
                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0); //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);

                int priorityB = 53;
                static int countB = 0;
                static int resourceCountB = 0;
                if ((enemyMilUnitsInR50 < 6) && (numAttEnemySiegeInR50 - numAttEnemySiegeInR50 < 1) && (numAttEnemyTitansInR50 < 1))
                {
                    if (countB <= 7)
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 4, 16, 18);

                        if (countB >= 6)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.3);
                        }
                        else if (countB >= 4)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.5);
                        }
                        else if (countB >= 2)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.7);
                        }
                        countB = countB + 1;
                        continue;
                    }
                    else
                    {
                        countB = 0;
                        xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                        xsDisableRule("defendBaseUnderAttack");
                        aiPlanDestroy(defendPlanID);
                        continue;
                    }
                }
                else
                {
                    if (enemyMilUnitsInR50 > 16)
                        aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR50 + 6, enemyMilUnitsInR50 + 6);

                    if ((((woodSupply < 300) || (goldSupply < 300)) && (mySettlementsAtDefPoint < 1)) || ((woodSupply < 300) && (goldSupply < 300) && (foodSupply < 300)))
                    {
                        if (resourceCountB <= 1)
                            resourceCountB = resourceCountB + 1;
                        else
                        {
                            resourceCountB = 0;
                            xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                            xsDisableRule("defendBaseUnderAttack");
                            aiPlanDestroy(defendPlanID);
                            gBaseUnderAttackID = -1;

                            xsSetRuleMinInterval("defendPlanRule", 2);
                            xsEnableRule("defendPlanRule");
                            continue;
                        }
                    }
                    else
                        resourceCountB = 0;
                    countB = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityB);
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule monitorAttPlans
minInterval 7 //starts in cAge2
inactive
{
    xsSetRuleMinIntervalSelf(7);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyMilUnitsNearMBInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 70.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyMilUnitsNearDefBInR50 = 0;
    int numAttEnemyMilUnitsNearDefBInR50 = 0;
    int numEnemyMilUnitsNearDefBInR40 = 0;
    int numEnemyTitansNearDefBInR55 = 0;
    int numAttEnemySiegeNearDefBInR50 = 0;
    int upID = gLateUPID;
    if (kbGetAge() < cAge3)
        upID = gRushUPID;
    kbUnitPickRun(upID);

    if ((kbGetAge() == cAge2) && (xsGetTime() > 12*60*1000))
        aiPlanSetVariableBool(gRushGoalID, cGoalPlanIdleAttack, 0, true);

    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numAttEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numEnemyMilUnitsNearDefBInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 40.0, true);
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numAttEnemySiegeNearDefBInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
        }
    }

    int mainBaseUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);

    // Find the attack plans
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true ); // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;

            int planState = aiPlanGetState(attackPlanID);
            float attPlanPriority = aiPlanGetDesiredPriority(attackPlanID);
            vector attPlanPosition = aiPlanGetLocation(attackPlanID);
            vector attPlanRetreatPosition = aiPlanGetInitialPosition(attackPlanID);
            float attPlanDistance = xsVectorLength(attPlanPosition - attPlanRetreatPosition);
            int numMilUnitsNearAttPlan = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, attPlanPosition, 50.0);
            int numAlliedMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, attPlanPosition, 50.0, true);
            int numEnemyMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 30.0, true);
            int numEnemyBuildingsThatShootNearAttPlanInR25 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 25.0, true);

            int numTitansInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractTitan);
            int numMilUnitsInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeLandMilitary);

            static int killSettlementAttPlanCount = -1;
            static int killRaidAttPlanCount = -1;
            static int killLandAttPlanCount = -1;

            int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
            if ((planState == cPlanStateTransport) && (gTransportMap == false) || (gTransportMap == true) && (planState == cPlanStateTransport) && (kbUnitCount(cMyID, transportPUID, cUnitStateAlive) < 1))
            {
                aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 0); // try to kill
                if ((aiPlanGetNumberUnits(attackPlanID) < 1) && (aiPlanGetDesiredPriority(attackPlanID) == 1) && (aiPlanGetIDByTypeAndVariableType(cPlanTransport) == -1))
                    aiPlanDestroy(attackPlanID);
                aiPlanSetDesiredPriority(attackPlanID, 1);
                xsSetRuleMinIntervalSelf(4);
                for (h = 0; < 2)
                {
                    int TransportPlanID = aiPlanGetIDByTypeAndVariableType(cPlanTransport);
                    if (TransportPlanID != -1)
                    {

                        aiPlanAddUnitType(TransportPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 0); // try to kill
                        aiPlanSetDesiredPriority(TransportPlanID, 1);
                        aiPlanDestroy(TransportPlanID);
                    }
                }
            }

            if (attackPlanID == gEnemySettlementAttPlanID)
            {
                static int countA = 0;
                float distanceA = 30.0;
                echo("gEnemySettlementAttPlanID:  "+attackPlanID+"");
                echo("NumInPlan:  "+numMilUnitsInPlan+"");
                if (killSettlementAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killSettlementAttPlanCount = -1;
                    }
                    else
                    {
                        if ((aiPlanGetNoMoreUnits(attackPlanID) == true) && (numMilUnitsInPlan < 3) || (numAttEnemyTitansNearMBInR85 > 0) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack)
                            || (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
                        {
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            if ((killSettlementAttPlanCount >= 4) || (attPlanDistance < 25.0))
                            {
                                aiPlanDestroy(attackPlanID);
                                gEnemySettlementAttPlanTargetUnitID = -1;
                                killSettlementAttPlanCount = -1;
                                continue;
                            }
                            killSettlementAttPlanCount = killSettlementAttPlanCount + 1;
                            if ((numMilUnitsInPlan < 3) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack)
                                || (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
                                killSettlementAttPlanCount = killSettlementAttPlanCount + 1; // kill the plan faster.
                            continue;
                        }
                        else
                        {
                            killSettlementAttPlanCount = -1;
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        }
                    }
                }


                if (numAttEnemyTitansNearMBInR85 > 0)
                {
                    countA = 0;
                    if (planState < cPlanStateAttack)
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                    }
                    else
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killSettlementAttPlanCount = 0;
                    }
                    continue;
                }

                if ((kbUnitGetCurrentHitpoints(gEnemySettlementAttPlanTargetUnitID) <= 0) && (gEnemySettlementAttPlanTargetUnitID != -1))
                {
                    if (countA == -1)
                    {
                        //aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                        aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, -1);
                        echo ("destroying gEnemySettlementAttPlanID as the target has been destroyed");
                        countA = 0;
                        continue;
                    }

                    if (gSettlementPosDefPlanID > 0)
                    {
                        xsSetRuleMinInterval("defendSettlementPosition", 1);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(gSettlementPosDefPlanID);
                    }
                    if (equal(gEnemySettlementAttPlanLastAttPoint, cInvalidVector) == false)
                    {
                        gSettlementPosDefPlanDefPoint = gEnemySettlementAttPlanLastAttPoint;
                        aiPlanSetVariableVector(attackPlanID, cAttackPlanGatherPoint, 0, gEnemySettlementAttPlanLastAttPoint);
                        xsEnableRule("defendSettlementPosition");
                    }
                    aiPlanSetDesiredPriority(attackPlanID, 52);
                    countA = -1;
                    continue;
                }

                if (planState < cPlanStateAttack)
                {
                    if ((numAttEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearMBInR70 > 14)
                        || (numAttEnemyMilUnitsNearDefBInR50 > 6) || (numEnemyMilUnitsNearDefBInR40 > 10)
                        || (numAttEnemySiegeNearDefBInR50 > 0) && (numEnemyMilUnitsNearDefBInR40 > 3))

                    {
                        countA = 0;
                        if ((numEnemyMilUnitsNearMBInR70 > 14) || (numEnemyMilUnitsNearDefBInR40 > 14) && (attPlanPriority <= 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            echo ("destroying gEnemySettlementAttPlanID as there are too many enemies");
                            continue;
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 17);
                        }
                    }
                    else
                    {
                        if (numTitansInPlan > 0)
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 55);
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 52);
                        }
                    }

                    // Check to see if the gather phase is taking too long and just launch the attack if so.
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                    {
                        if ((numEnemyMilUnitsNearMBInR70 > 10) || (numEnemyMilUnitsNearDefBInR40 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 500.0);
                            countA = 0;
                        }
                        else
                        {
                            if (countA < 0)
                                countA = 0;
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 500.0);
                            countA = countA + 1;
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countA = 0;
                    if (numTitansInPlan > 0)
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 90);
                    }
                    else
                    {
                        float distanceToTarget = xsVectorLength(mainBaseLocation - kbUnitGetPosition(gEnemySettlementAttPlanTargetUnitID));
                        if ((distanceToTarget > 110.0) && (numMilUnitsInPlan < 3))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            killSettlementAttPlanCount = 0;
                        }
                        else if ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan)
                                 && (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (aiPlanGetNoMoreUnits(attackPlanID) == true)
                                 && (numMilUnitsInPlan < 3))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            killSettlementAttPlanCount = 0;
                        }
                    }
                    continue;
                }
            }
            else if (attackPlanID == gRaidingPartyAttackID)
            {

                if (killRaidAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killRaidAttPlanCount = -1;
                    }
                    else
                    {
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killRaidAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            gRaidingPartyTargetUnitID = -1;
                            killRaidAttPlanCount = -1;
                            continue;
                        }
                        killRaidAttPlanCount = killRaidAttPlanCount + 1;
                        continue;
                    }
                }

                if (planState < cPlanStateAttack)
                {
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)
                    {
                        killRaidAttPlanCount = -1;
                        aiPlanDestroy(attackPlanID);
                        gRaidingPartyTargetUnitID = -1;
                        continue;
                    }
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                        aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 500.0);

                    if (mainBaseUnderAttack > 0)
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 15);
                    }
                    else
                    {
                        if (aiPlanGetDesiredPriority(attackPlanID) < 34)
                            aiPlanSetDesiredPriority(attackPlanID, 34);
                    }
                }
                else if (planState == cPlanStateAttack)
                {
                    if ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.5) && (numMilUnitsInPlan < 1) && (numEnemyBuildingsThatShootNearAttPlanInR25 > 0)
                        || (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) && (numMilUnitsInPlan < 1))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRaidAttPlanCount = 0;
                    }
                    continue;
                }
            }
            else if (attackPlanID == gEnemyWonderDefendPlan)
            {
                int numUnitsInPlan = aiPlanGetNumberUnits(gEnemyWonderDefendPlan, cUnitTypeUnit);
                //aiEcho("Number in plan: "+numUnitsInPlan);
                if (planState < cPlanStateAttack)
                {
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000))
                    {
                        if (aiPlanGetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0) != 400.0)
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 400.0);
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 200, 200, 200);
                    aiPlanSetDesiredPriority(attackPlanID, 99);
                    continue;
                }
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                static int countD = 0;
                float distanceD = 25.0;
                echo("gLandAttackPlanID:  "+attackPlanID+"");
                echo("NumInPlan:  "+numMilUnitsInPlan+"");
                if (killLandAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killLandAttPlanCount = -1;
                    }
                    else
                    {
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killLandAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            killLandAttPlanCount = -1;
                            echo("Killing gLandAttackPlanID, Count >=4");
                            continue;
                        }
                        killLandAttPlanCount = killLandAttPlanCount + 1;
                        if (numMilUnitsInPlan < 3)
                            killLandAttPlanCount = killLandAttPlanCount + 1; // kill the plan faster.
                        continue;
                    }
                }

                if ((numEnemyTitansNearMBInR85 > 0) || (numEnemyTitansNearDefBInR55 > 0) || ((numMHPlayerSettlements > 0) && (numTitansInPlan > 0)))
                {
                    countD = 0;
                    if (planState < cPlanStateAttack)
                    {
                        aiPlanDestroy(attackPlanID);
                    }
                    else
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                    }
                    continue;
                }

                if (planState < cPlanStateAttack)
                {
                    if ((numEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6))
                    {
                        countD = 0;
                        if (kbGetAge() == cAge2)
                        {
                            killLandAttPlanCount = -1;
                            aiPlanDestroy(attackPlanID);
                            gRushAttackCount = gRushAttackCount -1;
                        }
                        else
                        {
                            if (((numEnemyMilUnitsNearMBInR70 > 20) || (numEnemyMilUnitsNearDefBInR40 > 20)) && (attPlanPriority < 20))
                            {
                                aiPlanDestroy(attackPlanID);
                                echo ("destroying gLandAttackPlanID as there are too many enemies 1");
                                continue;
                            }
                            else
                            {
                                aiPlanSetDesiredPriority(attackPlanID, 17);
                            }
                        }
                    }
                    else
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 50);
                    }

                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                    {
                        if ((numEnemyMilUnitsNearMBInR85 > 14) || (numEnemyMilUnitsNearDefBInR50 > 14))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 500.0);
                            countD = 0;
                        }
                        else
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 500.0);
                            countD = countD + 1;
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countD = 0;
                    if ((kbGetAge() >= cAge2) && (numMilUnitsInPlan < 3))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                    }
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule defendPlanRule
minInterval 61 //starts in cAge1
inactive
{
    if ((kbGetAge() < cAge2) && (xsGetTime() < 5*60*1000))
        return;

    xsSetRuleMinIntervalSelf(27);
    static int defendCount = 0; // For plan numbering
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    static int defendPlanStartTime = -1;

    int numAttEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);

    int baseToUse = mainBaseID;
    if ((gBaseUnderAttackID != -1) && (equal(gBaseUnderAttackLocation, cInvalidVector) == false) && (numAttEnemyMilUnitsNearMBInR80 < 7))
    {
        baseToUse = gBaseUnderAttackID;
    }

    bool defendPlanActive = false;
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            if (defendPlanID == gDefendPlanID)
            {
                defendPlanActive = true;
                int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
                if (defPlanBaseID != baseToUse)
                {
                    vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                    int enemySettlementsAtDefPlanDefPoint = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 15.0);
                    int motherNatureSettlementsAtDefPlanDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, defPlanDefPoint, 15.0);

                    if ((numEnemyTitansNearMBInR80 > 0) || (enemySettlementsAtDefPlanDefPoint - motherNatureSettlementsAtDefPlanDefPoint > 0)
                        || ((numAttEnemyMilUnitsNearMBInR80 > 10) && (numAttEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 1.3)))
                    {

                        aiPlanSetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, baseToUse));
                        aiPlanSetBaseID(defendPlanID, baseToUse);
                        xsSetRuleMinIntervalSelf(2);
                        return;
                    }
                }
            }
        }
    }

    //If we already have a gDefendPlan, don't make another one.
    if (defendPlanActive == true)
        return;

    int defPlanID = createDefOrAttackPlan("Defend plan #"+defendCount, true, 50, 30, kbBaseGetLocation(cMyID, baseToUse), baseToUse, 20, false);
    if (defPlanID != -1)
    {
        defendCount = defendCount + 1;
        aiPlanAddUnitType(defPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);
        defendPlanStartTime = xsGetTime();
        aiPlanSetActive(defPlanID);
        gDefendPlanID = defPlanID;
    }
}

//==============================================================================
// RULE activateObeliskClearingPlan
//==============================================================================
rule activateObeliskClearingPlan // + vil hunting
inactive
minInterval 109 //starts in cAge2
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    static int obeliskPlanCount = 0;
    // We found targets, make a plan if we don't have one.
    if (gObeliskClearingPlanID < 0)
    {
        gObeliskClearingPlanID = createDefOrAttackPlan("Obelisk plan #"+obeliskPlanCount, true, 110, 25, kbBaseGetLocation(cMyID, mainBaseID), mainBaseID, 16, false);
        if (gObeliskClearingPlanID < 0)
            return;
        obeliskPlanCount = obeliskPlanCount + 1;
        aiPlanSetNumberVariableValues(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeLogicalTypeIdleCivilian);
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeOutpost);

        if (cMyCulture == cCultureChinese)
            aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeScoutChinese, 1, 1, 1);
        else
            aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
        aiPlanSetActive(gObeliskClearingPlanID);
    }
    if (gObeliskClearingPlanID != -1)
        aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
}

//==============================================================================
rule mainBaseDefPlan1   //Make a defend plan that protects the main base
        minInterval 8 //starts in cAge1
inactive
{
    if (kbGetAge() < cAge2)
        return;

    static bool alreadyInAge3 = false;
    Vector Temp = cInvalidVector;
    if ((kbGetAge() >= cAge3) && (alreadyInAge3 == false))
    {
        alreadyInAge3 = true;
        xsSetRuleMinIntervalSelf(20);
    }

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);

    //If we already have a mainBaseDefPlan1, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            if (HealDefPlan != -1)
                aiPlanSetVariableVector(HealDefPlan, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
            if (defendPlanID == gMBDefPlan1ID)
            {
                int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
                if (numEnemyMilUnitsNearMBInR85 < 4)
                {
                    int Agg = findPlanByString("AutoGPFoodHuntAggressive", cPlanGather);
                    int Easy = findPlanByString("AutoGPFoodEasy", cPlanGather);
                    if (Agg != -1)
                        Temp = aiPlanGetLocation(Agg);
                    else
                        Temp = aiPlanGetLocation(Easy);
                    if (equal(Temp, cInvalidVector) == false)
                    {
                        aiPlanSetVariableVector(gMBDefPlan1ID, cDefendPlanDefendPoint, 0, Temp);
                        aiPlanSetVariableFloat(gMBDefPlan1ID, cDefendPlanGatherDistance, 0, 10.0);
                        return;
                    }

                }
                aiPlanSetVariableVector(gMBDefPlan1ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
                aiPlanSetVariableFloat(gMBDefPlan1ID, cDefendPlanGatherDistance, 0, 30.0);
                return;
            }
        }
    }

    int mainBaseDefPlan1ID = createDefOrAttackPlan("mainBaseDefPlan1", true, 60, 30, kbBaseGetLocation(cMyID, mainBaseID), mainBaseID, 40, false);
    if (mainBaseDefPlan1ID != -1)
    {
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);


        if ((gAge2MinorGod == cTechAge2Okeanus) || (cMyCulture == cCultureGreek))
        {
            HealDefPlan = createDefOrAttackPlan("HealerOrIdleUnitDefPlan", true, 1, 25, kbBaseGetLocation(cMyID, mainBaseID), mainBaseID, 65, false);
            if (HealDefPlan != -1)
            {
                aiPlanSetNumberVariableValues(HealDefPlan, cDefendPlanAttackTypeID, 0, true);
                aiPlanSetVariableInt(HealDefPlan, cDefendPlanRefreshFrequency, 0, 60);
                aiPlanSetAllowUnderAttackResponse(HealDefPlan, false);
                aiPlanAddUnitType(HealDefPlan, cUnitTypePhysician, 1, 2, 2);
                aiPlanAddUnitType(HealDefPlan, cUnitTypeFlyingMedic, 1, 2, 2);
                aiPlanSetActive(HealDefPlan);
            }
        }
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeLandMilitary, 0, 8, 8);
        if ((gAge3MinorGod == cTechAge3Hathor) && (gTransportMap == true))
            aiPlanAddUnitType(HealDefPlan, cUnitTypeRoc, 1, 2, 2);
        aiPlanSetActive(mainBaseDefPlan1ID);
        gMBDefPlan1ID = mainBaseDefPlan1ID;
    }
}

//==============================================================================
rule otherBasesDefPlans //Make defend plans that protect the other bases
minInterval 43 //starts in cAge2
inactive
{
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements < 2)
        return;

    bool otherBase1DefPlan = false;
    bool otherBase2DefPlan = false;
    bool otherBase3DefPlan = false;
    bool otherBase4DefPlan = false;

    //If we already have defend plans for all our other bases, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;


            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);

            if (defendPlanID == gOtherBase1DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiPlanDestroy(defendPlanID);
                    gOtherBase1DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);

                    gOtherBase1UnitID = -1;
                    gOtherBase1ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase1UnitID
                        aiPlanDestroy(gOtherBase1RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase1RingWallTeam", 11);
                        xsDisableRule("otherBase1RingWallTeam");
                    }
                }
                else
                {
                    otherBase1DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase2DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiPlanDestroy(defendPlanID);
                    gOtherBase2DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);

                    gOtherBase2UnitID = -1;
                    gOtherBase2ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase2UnitID
                        aiPlanDestroy(gOtherBase2RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase2RingWallTeam", 11);
                        xsDisableRule("otherBase2RingWallTeam");
                    }
                }
                else
                {
                    otherBase2DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase3DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiPlanDestroy(defendPlanID);
                    gOtherBase3DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);

                    gOtherBase3UnitID = -1;
                    gOtherBase3ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase3UnitID
                        aiPlanDestroy(gOtherBase3RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase3RingWallTeam", 11);
                        xsDisableRule("otherBase3RingWallTeam");
                    }
                }
                else
                {
                    otherBase3DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase4DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiPlanDestroy(defendPlanID);
                    gOtherBase4DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);

                    gOtherBase4UnitID = -1;
                    gOtherBase4ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase4UnitID
                        aiPlanDestroy(gOtherBase4RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase4RingWallTeam", 11);
                        xsDisableRule("otherBase4RingWallTeam");
                    }
                }
                else
                {
                    otherBase4DefPlan = true;
                }
                continue;
            }
        }
    }

    bool otherBase1 = false;
    bool otherBase2 = false;
    bool otherBase3 = false;
    bool otherBase4 = false;

    int newBaseID = -1;
    int newBaseUnitID = -1;
    int mainBaseID = kbBaseGetMainID(cMyID);

    int OB1DefPlanBaseID = aiPlanGetBaseID(gOtherBase1DefPlanID);
    int OB2DefPlanBaseID = aiPlanGetBaseID(gOtherBase2DefPlanID);
    int OB3DefPlanBaseID = aiPlanGetBaseID(gOtherBase3DefPlanID);
    int OB4DefPlanBaseID = aiPlanGetBaseID(gOtherBase4DefPlanID);

    int index = -1;
    for (index = 0; < numSettlements)
    {
        int otherBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding);
        if (otherBaseUnitID < 0)
            continue;
        else
        {
            //check IDs of all bases.
            int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
            if (otherBaseID == -1)
                continue;

            if (otherBaseUnitID == gOtherBase1UnitID)
            {
                if ((otherBaseID != gOtherBase1ID) || (otherBaseID != OB1DefPlanBaseID))
                {
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);

                    //set gOtherBase1ID to otherBaseID and update the baseID of gOtherBase1DefPlanID
                    gOtherBase1ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase1DefPlanID, otherBaseID);

                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase1RingWallTeamPlanID to the new gOtherBase1ID
                        aiPlanSetBaseID(gOtherBase1RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase1 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase2UnitID)
            {
                if ((otherBaseID != gOtherBase2ID) || (otherBaseID != OB2DefPlanBaseID))
                {
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);

                    //set gOtherBase2ID to otherBaseID and update the baseID of gOtherBase2DefPlanID
                    gOtherBase2ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase2DefPlanID, otherBaseID);

                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase2RingWallTeamPlanID to the new gOtherBase2ID
                        aiPlanSetBaseID(gOtherBase2RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase2 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase3UnitID)
            {
                if ((otherBaseID != gOtherBase3ID) || (otherBaseID != OB3DefPlanBaseID))
                {
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);

                    //set gOtherBase3ID to otherBaseID and update the baseID of gOtherBase3DefPlanID
                    gOtherBase3ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase3DefPlanID, otherBaseID);

                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase3RingWallTeamPlanID to the new gOtherBase3ID
                        aiPlanSetBaseID(gOtherBase3RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase3 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase4UnitID)
            {
                if ((otherBaseID != gOtherBase4ID) || (otherBaseID != OB4DefPlanBaseID))
                {
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);

                    //set gOtherBase4ID to otherBaseID and update the baseID of gOtherBase4DefPlanID
                    gOtherBase4ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase4DefPlanID, otherBaseID);

                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase4RingWallTeamPlanID to the new gOtherBase4ID
                        aiPlanSetBaseID(gOtherBase4RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase4 = true;
                continue;
            }
            else if (otherBaseID != mainBaseID)
            {
                //we got a new base ID, save it, if no other base has been saved as new base ID yet
                if (newBaseID < 0 )
                {
                    newBaseID = otherBaseID;
                    newBaseUnitID = otherBaseUnitID;
                }
            }
        }
    }

    if (newBaseID < 0)
    {
        return;
    }
    else if (otherBase1 == false)
    {
        gOtherBase1ID = newBaseID;
        gOtherBase1UnitID = newBaseUnitID;


        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase1UnitID
            xsEnableRule("otherBase1RingWallTeam");
            otherBase1RingWallTeam();
        }
    }
    else if (otherBase2 == false)
    {
        gOtherBase2ID = newBaseID;
        gOtherBase2UnitID = newBaseUnitID;



        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase2UnitID
            xsEnableRule("otherBase2RingWallTeam");
            otherBase2RingWallTeam();
        }
    }
    else if (otherBase3 == false)
    {
        gOtherBase3ID = newBaseID;
        gOtherBase3UnitID = newBaseUnitID;


        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase3UnitID
            xsEnableRule("otherBase3RingWallTeam");
            otherBase3RingWallTeam();
        }
    }
    else if (otherBase4 == false)
    {
        gOtherBase4ID = newBaseID;
        gOtherBase4UnitID = newBaseUnitID;



        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase4UnitID
            xsEnableRule("otherBase4RingWallTeam");
            otherBase4RingWallTeam();
        }
    }
    else
    {
        return;
    }

    vector newBaseUnitPosition = kbUnitGetPosition(newBaseUnitID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);

    int number = -1; // For plan numbering
    if (otherBase1DefPlan == false)
        number = 1;
    else if (otherBase2DefPlan == false)
        number = 2;
    else if (otherBase3DefPlan == false)
        number = 3;
    else if (otherBase4DefPlan == false)
        number = 4;

    int otherBaseDefPlanID = createDefOrAttackPlan("otherBase"+number+"DefPlan", true, 40, 15, newBaseUnitPosition, newBaseID, 25, false);
    if (otherBaseDefPlanID != -1)
    {
        aiPlanSetActive(otherBaseDefPlanID);
        if (otherBase1DefPlan == false)
            gOtherBase1DefPlanID = otherBaseDefPlanID;
        else if (otherBase2DefPlan == false)
            gOtherBase2DefPlanID = otherBaseDefPlanID;
        else if (otherBase3DefPlan == false)
            gOtherBase3DefPlanID = otherBaseDefPlanID;
        else if (otherBase4DefPlan == false)
            gOtherBase4DefPlanID = otherBaseDefPlanID;
        //reset the minInterval since calling the wallplans seems to change the minInterval
        xsSetRuleMinIntervalSelf(43);
    }
}

//==============================================================================
rule attackEnemySettlement
minInterval 29 //starts in cAge2
inactive
{
    if (ShouldIAgeUp() == true)
        xsSetRuleMinIntervalSelf(120);
    else
        xsSetRuleMinIntervalSelf(29);
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);

    static bool ResetOk = false;
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);

    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR55 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }

    static int attackPlanStartTime = -1;
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);

    static int lastTargetUnitID = -1;
    static int lastTargetCount = 0;

    float closeToMB = 110.0;
    int baseToUse = mainBaseID;
    float radius = closeToMB;
    vector baseLocationToUse = mainBaseLocation;

    int numEnemySettlementsNearMB = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, mainBaseLocation, radius);
    int numMotherNatureSettlementsNearMB = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, mainBaseLocation, radius);

    if (numEnemySettlementsNearMB - numMotherNatureSettlementsNearMB < 1)
    {
        radius = 300.0;
        if (defPlanBaseID != -1)
        {
            baseToUse = defPlanBaseID;
            baseLocationToUse = defPlanBaseLocation;
        }
    }

    int index = 0;
    int enemySettlementID = -1;
    int closestSettlementID = -1;
    int closestSettlementPlayerID = -1;
    int secondClosestSettlementID = -1;
    int secondClosestSettlementPlayerID = -1;
    float savedDistanceToClosestSettlement = 1000.0;
    float savedDistanceToSecondClosestSettlement = 1001.0;

    int playerID = -1;
    int numEnemySettlementsInRange = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, baseLocationToUse, radius);
    for (index = 0; < numEnemySettlementsInRange)
    {
        enemySettlementID = findUnitByRelByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, baseLocationToUse, radius);
        int TcOwner = kbUnitGetOwner(enemySettlementID);
        if ((enemySettlementID == -1) || (TcOwner <= 0))
            continue;

        vector enemySettlementPos = kbUnitGetPosition(enemySettlementID);
        float distanceToDefBaseToUse = xsVectorLength(baseLocationToUse - enemySettlementPos);
        if (distanceToDefBaseToUse < savedDistanceToClosestSettlement)
        {
            savedDistanceToClosestSettlement = distanceToDefBaseToUse;
            closestSettlementID = enemySettlementID;
            closestSettlementPlayerID = TcOwner;
            playerID = TcOwner;
            continue;
        }
        else if (distanceToDefBaseToUse < savedDistanceToSecondClosestSettlement)
        {
            savedDistanceToSecondClosestSettlement = distanceToDefBaseToUse;
            secondClosestSettlementID = enemySettlementID;
            secondClosestSettlementPlayerID = TcOwner;
            playerID = TcOwner;
            continue;
        }
    }

    int targetSettlementID = -1;
    int targetPlayerID = -1;
    bool targetSettlementCloseToMB = false;
    int numSettlementsBeingBuiltCloseToMB = 0;

    if (closestSettlementID != -1)
    {
        targetSettlementID = closestSettlementID;
        targetPlayerID = closestSettlementPlayerID;
        if (radius <= closeToMB)
        {
            targetSettlementCloseToMB = true;
            vector closestSettlementPos = kbUnitGetPosition(closestSettlementID);
            numSettlementsBeingBuiltCloseToMB = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, playerID, closestSettlementPos, 15.0);
        }
    }

    if (targetSettlementCloseToMB == false)
    {
        //reset the number of myth units in gMBDefPlan1ID
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(gMBDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 0, 1);
    }
    int numMilUnitsInDefPlans = AvailableUnitsFromDefPlans();

    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();

    // Find the attack plans
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true ); // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;

            int planState = aiPlanGetState(attackPlanID);
            if (attackPlanID == gEnemySettlementAttPlanID)
            {
                int numTitansInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractTitan);
                int numMythInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
                int numSiegeInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractSiegeWeapon);
                int numUnitsInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeLandMilitary);

                if ((targetSettlementCloseToMB == true) && (planState <= cPlanStateGather))
                {
                    if ((aiPlanGetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0) != closestSettlementID) && (closestSettlementID != -1))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0, closestSettlementID);
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanPlayerID, 0, closestSettlementPlayerID);
                    }
                }

                if ((ResetOk == true) && (kbUnitGetCurrentHitpoints(gEnemySettlementAttPlanTargetUnitID) <= 0) && (gEnemySettlementAttPlanTargetUnitID != -1) || (ResetOk == true) && (gEnemySettlementAttPlanTargetUnitID == -1))
                {
                    attackPlanStartTime = xsGetTime();
                    aiPlanSetVariableVector(attackPlanID, cAttackPlanGatherPoint, 0, aiPlanGetLocation(attackPlanID));
                    aiPlanSetUnitStance(attackPlanID, cUnitStanceAggressive);
                    ResetOk = false;
                }

                if (planState == cPlanStateAttack)
                {
                    //set the minimum number of siege weapons to 1, so that other plans can't steal all of them
                    aiPlanAddUnitType(attackPlanID, cUnitTypeAbstractSiegeWeapon, 1, 3, 4);

                    if (numTitansInAttackPlan > 0)
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false); // Make sure the gEnemySettlementAttPlan stays open
                        echo ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, numUnitsInPlan+numMilUnitsInDefPlans, numUnitsInPlan+numMilUnitsInDefPlans, numUnitsInPlan+numMilUnitsInDefPlans);
                        xsSetRuleMinIntervalSelf(12);
                    }
                    else if ((kbGetAge() > cAge2) && (currentPop >= currentPopCap * 0.8) && ((numMythInAttackPlan > 0) || (numSiegeInAttackPlan > 0)) && (kbGetAge() > cAge3)
                             && (woodSupply > 300) && (goldSupply > 400) && (foodSupply > 400) && (numEnemyMilUnitsNearMBInR80 < 20))
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false); // Make sure the gEnemySettlementAttPlan stays open
                        aiPlanSetDesiredPriority(attackPlanID, 55);
                        echo ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, numUnitsInPlan+numMilUnitsInDefPlans, numUnitsInPlan+numMilUnitsInDefPlans, numUnitsInPlan+numMilUnitsInDefPlans);
                        xsSetRuleMinIntervalSelf(12);
                    }
                    else
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, true); // Make sure the gEnemySettlementAttPlan is closed
                        aiPlanSetDesiredPriority(attackPlanID, 52);
                        echo ("Setting gEnemySettlementAttPlanID NoMoreUnits to true");
                    }
                }
                else if (((planState == cPlanStateGather) || (planState == cPlanStateExplore) || (planState == cPlanStateNone))
                         && (xsGetTime() > attackPlanStartTime + 3.5*60*1000) && (attackPlanStartTime != -1)
                         || (planState < cPlanStateAttack) && (xsGetTime() > attackPlanStartTime + 3.5*60*1000) && (attackPlanStartTime != -1))
                {
                    if ((xsGetTime() > attackPlanStartTime + 5*60*1000) && (attackPlanStartTime != -1))
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                        echo ("destroying gEnemySettlementAttPlanID as it has been active for more than 5 Minutes");
                    }
                    continue;
                }
                return;
            }
        }
    }

    if ((numEnemyTitansNearDefBInR55 > 0) || (numEnemyTitansNearMBInR75 > 0))
    {
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }

    if ((numAttEnemyMilUnitsNearMBInR85 > 10) && (targetSettlementCloseToMB == false))
    {
        return;
    }

    if (ReadyToAttack() == false)
    {
        return;
    }
    bool settlementPosDefPlanActive = false;

    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true ); // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        for (j = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, j);
            if (defendPlanID == -1)
                continue;

            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                settlementPosDefPlanActive = true;
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
                int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
                int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
                int Combined = NumEnemyBuildings + enemyMilUnitsInR50;
                if (Combined <= 5)
                    settlementPosDefPlanActive = false;
            }
        }
    }
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);

    if (targetSettlementCloseToMB == false)
    {
        if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1) && (Combined > 5))
        {
            return;
        }
    }

    int enemyMainBaseUnitID = -1;
    float veryCloseRange = 65.0;
    bool ConvertToLand = false;

    if ((targetSettlementID != -1) && (targetPlayerID != -1))
    {
        enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);
        if ((targetSettlementID == enemyMainBaseUnitID) && (savedDistanceToClosestSettlement > veryCloseRange)
            && (secondClosestSettlementID != -1))
        {
            //check if the secondClosestSettlement's distance is only a little farther
            if (savedDistanceToSecondClosestSettlement - savedDistanceToClosestSettlement < 20.0 )
            {
                enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(secondClosestSettlementPlayerID);
                if (secondClosestSettlementID != enemyMainBaseUnitID)
                {
                    targetSettlementID = secondClosestSettlementID;
                    targetPlayerID = secondClosestSettlementPlayerID;
                }
            }
        }
    }

    if ((targetSettlementID < 0) || ((lastTargetCount > 4) && (targetSettlementCloseToMB == false)))
    {
        if ((targetSettlementID != secondClosestSettlementID) && (secondClosestSettlementID != -1) && (aiRandInt(5) < 4))
        {
            targetSettlementID = secondClosestSettlementID;
            targetPlayerID = secondClosestSettlementPlayerID;
        }
        else
        {

            targetSettlementID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, mostHatedPlayerID);
            if (targetSettlementID != -1)
            {
                targetPlayerID = mostHatedPlayerID;
            }
            else
            {
                ConvertToLand = true;
                gEnemySettlementAttPlanLastAttPoint = cInvalidVector;
                gEnemySettlementAttPlanTargetUnitID = -1;
            }
        }
    }

    if ((InfiniteAIAllies == true) && (aEnemyTCID != -1) && (aiGetCaptainPlayerID(cMyID) != cMyID) && (xsGetTime() < aLastTCIDTime + 10*60*1000))
    {
        int Owner = kbUnitGetOwner(aEnemyTCID);
        if ((Owner > 0) && (kbIsPlayerEnemy(Owner) == true))
        {
            targetSettlementID = aEnemyTCID;
            targetPlayerID = Owner;
        }
    }
    aEnemyTCID = -1;

    vector targetSettlementPos = kbUnitGetPosition(targetSettlementID);
    enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);

    int enemySettlementAttPlanID = createDefOrAttackPlan("enemy settlement attack plan", false, -1, 30, cInvalidVector, -1, -1, false);
    if (enemySettlementAttPlanID < 0)
        return;

    if (targetSettlementCloseToMB == true)
    {
        //set the number of myth units in gMBDefPlan1ID to 0
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(gMBDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 0, 0);
    }

    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanPlayerID, 0, targetPlayerID);

    // Specify other continent so that armies will transport
    if (gTransportMap == true)
    {
        aiPlanSetNumberVariableValues(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 2, true);
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mainBaseLocation));
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetSettlementPos));
    }

    if (numTitans > 0)
        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
    aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans*0.85, numMilUnitsInDefPlans, numMilUnitsInDefPlans);

    if (numTitans > 0)
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 55);
    else
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 52);

    if (ConvertToLand == false)
    {
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, targetSettlementID);
        gEnemySettlementAttPlanTargetUnitID = targetSettlementID;
        gEnemySettlementAttPlanLastAttPoint = targetSettlementPos;
    }
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);

    if ((cMyCiv == cCivKronos) && (gGlutRatio >= 0.25))
        aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);

    int GPFindPlan = aiFindBestAttackGodPowerPlan();
    if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
        aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);
    aiPlanSetActive(enemySettlementAttPlanID);

    if (gSomeData != -1)
        aiPlanSetUserVariableInt(gSomeData, SettlementAttackTarget, 0, targetPlayerID);

    if ((lastTargetUnitID == targetSettlementID) && (targetSettlementID != -1))
        lastTargetCount = lastTargetCount + 1;
    else
    {
        lastTargetUnitID = targetSettlementID;
        lastTargetCount = 0;
    }
    if ((InfiniteAIAllies == true) && (targetSettlementID >= 0) && (aiGetCaptainPlayerID(cMyID) == cMyID) && (gTransportMap == false))
        MessageRel(cPlayerRelationAlly, cAttackTC, targetSettlementID);

    gEnemySettlementAttPlanID = enemySettlementAttPlanID;
    attackPlanStartTime = xsGetTime();
    if (gTransportMap == false)
        ResetOk = true;
    bool Announce = false;
    static int lastAnnounced = 0;

    if ((aiRandInt(3) == 0) && (IhaveAllies == true) && (aiGetCaptainPlayerID(cMyID) == cMyID) && (targetSettlementID >= 0) && (xsGetTime() > lastAnnounced + 3*60*1000))
    {
        Announce = true;
        lastAnnounced = xsGetTime();
    }

    if (Announce == true)
    {
        int RandMessage = 1+aiRandInt(4);
        if (RandMessage == 3)
            RandMessage = 2;
        for (i=1; < cNumberPlayers)
        {
            if (i == cMyID)
                continue;
            if ((kbIsPlayerAlly(i) == true) && (kbIsPlayerHuman(i) == true) && (kbHasPlayerLost(i) == false))
                aiCommsSendStatementWithVector(i, cAICommPromptAIAttackHere, RandMessage, targetSettlementPos);
        }
    }
}

//==============================================================================
rule defendSettlementPosition
minInterval 1 //starts in cAge2, activated in monitorAttack rule or findMySettlementsBeingBuilt rule
inactive
{
    xsSetRuleMinIntervalSelf(23);
    static int defendPlanStartTime = -1;

    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gSettlementPosDefPlanDefPoint);

    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 50.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
    int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int myBuildingsThatShootAtDefPlanPosition = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gSettlementPosDefPlanDefPoint, 15.0, true);
    int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 50.0, true);
    int NumBThatShoots = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 35.0, true);
    int enemySettlementAtDefPlanPositionID = findUnitByRelByIndex(cUnitTypeAbstractSettlement, 0, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 15.0);

    //If we already have a settlementPosDefPlan, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            if (defendPlanID == gSettlementPosDefPlanID)
            {

                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int numAttEnemyMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);

                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                    || ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                    || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 3)))
                {
                    aiPlanDestroy(defendPlanID);
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }

                if ((xsGetTime() > defendPlanStartTime + 4*60*1000) || (alliedBaseAtDefPlanPosition > 0)
                    || ((myBaseAtDefPlanPosition > 0) && ((numAttEnemyMilUnitsInR40 < 10) && (myBuildingsThatShootAtDefPlanPosition > 0))
                        || (equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), defPlanDefPoint) == true)))
                {
                    aiPlanDestroy(defendPlanID);
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                }
                return;
            }
        }
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }

    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
    {
        return;
    }

    static int count = 0;
    if (numMilUnits < 10)
    {
        xsSetRuleMinIntervalSelf(11);
        if (count > 2)
        {
            xsSetRuleMinIntervalSelf(1);
            count = 0;
            xsDisableSelf();
        }
        else
            count = count + 1;
        return;
    }

    int BaseToUse = kbUnitGetBaseID(findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, cActionAny, cMyID, gSettlementPosDefPlanDefPoint, 30));
    if (BaseToUse == -1)
        BaseToUse = mainBaseID;
    int settlementPosDefPlanID = createDefOrAttackPlan("settlementPosDefPlan", true, 40, 20, gSettlementPosDefPlanDefPoint, BaseToUse, 52, false);
    if (settlementPosDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        if (distToMainBase < 100.0)
        {
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);

            if (NumEnemyBuildings > 6)
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 7, 15, 18);
            else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 3, 5, 6);

        }
        else
        {
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);

            if ((NumEnemyBuildings > 6) || (NumBThatShoots >= 1))
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
            else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
            if (NumEnemyBuildings > 6)
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 15, 18, 25); // add more
            else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 5, 8, 10);
        }
        aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);

        //override
        if (enemyMilUnitsInR50 > 18)
            aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 8);
        aiPlanSetActive(settlementPosDefPlanID);
        gSettlementPosDefPlanID = settlementPosDefPlanID;
        xsSetRuleMinIntervalSelf(23);
    }
}


//==============================================================================
rule createRaidingParty
minInterval 29 //starts in cAge2
inactive
{
    xsSetRuleMinIntervalSelf(29);
    static int attackPlanStartTime = -1;
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;

    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR35 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            baseLocationToUse = defPlanBaseLocation;
            numEnemyTitansNearDefBInR35 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 35.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }

    //If we already have a raiding party attack plan don't make another one.
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            if (attackPlanID == gRaidingPartyAttackID)
            {
                if ((kbUnitGetCurrentHitpoints(gRaidingPartyTargetUnitID) <= 0) && (gRaidingPartyTargetUnitID != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                }
                else if ((aiPlanGetState(attackPlanID) < cPlanStateAttack) && (xsGetTime() > attackPlanStartTime + 3*60*1000) && (attackPlanStartTime != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                }
                return;
            }
        }
    }
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();

    if ((numEnemyMilUnitsNearMBInR80 > 8) || (currentPop <= currentPopCap - 14) ||
        (currentPop < 100) || (aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier) < 4)
        || (gEnemyWonderDefendPlan > 0) || (numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR85 > 0)
        || (numEnemyTitansNearDefBInR35 > 0) || (numAttEnemyTitansNearDefBInR55 > 0))
    {
        echo("createRaidingParty: skipping raiding party creation");
        return;
    }

    static int lastTargetUnitID = -1;
    static int lastTargetCount = 0;
    int militaryUnit1ID = -1;
    int targetUnitID = -1;
    bool targetIsMarket = false;
    bool targetIsDropsite = false;
    bool success = false;
    float closeRangeRadius = 100.0;
    int enemyEconUnit = cUnitTypeDropsite;
    int AtlVillager = getNumUnitsByRel(cUnitTypeVillagerAtlantean, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
    if (AtlVillager > 0)
        enemyEconUnit = cUnitTypeVillagerAtlantean;

    int numEnemyDropsitesInCloseRange = getNumUnitsByRel(enemyEconUnit, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
    for (i = 0; < numEnemyDropsitesInCloseRange)
    {
        int dropsiteUnitIDinCloseRange = findUnitByRel(enemyEconUnit, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
        if ((kbUnitIsType(dropsiteUnitIDinCloseRange, cUnitTypeAbstractSettlement) == true)
            || (kbHasPlayerLost(kbUnitGetOwner(dropsiteUnitIDinCloseRange)) == true))
        {
            dropsiteUnitIDinCloseRange = -1;
            continue;
        }
        targetIsDropsite = true;
        targetUnitID = dropsiteUnitIDinCloseRange;
        success = true;
        break;
    }

    if (success == false)
    {
        int enemyPlayerID = aiGetMostHatedPlayerID();
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAlive);
        if (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)
            enemyEconUnit = cUnitTypeVillagerAtlantean;
        else
            enemyEconUnit = cUnitTypeDropsite;
        int numEnemyDropsites = kbUnitCount(enemyPlayerID, enemyEconUnit, cUnitStateAlive);

        if ((numEnemyMarkets > 0) && (mapRestrictsMarketAttack() == false))
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAlive, -1, enemyPlayerID);
                vector enemyMarketLocation = kbUnitGetPosition(enemyMarketUnitID);
                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyShootersAtMarketLocation = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                if ((numEnemyBuildingsAtMarketLocation < 8) && (numEnemyShootersAtMarketLocation < 3) && (SameAG(kbUnitGetPosition(enemyMarketUnitID), mainBaseLocation) == true))
                {
                    targetUnitID = enemyMarketUnitID;
                    targetIsMarket = true;
                    success = true;
                    break;
                }
            }
        }
        if ((success == false) && (numEnemyDropsites > 0))
        {
            int enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(enemyPlayerID);
            vector enemyMainBaseUnitLocation = kbUnitGetPosition(enemyMainBaseUnitID);
            float distanceToSavedEnemyDropsiteUnitID = 0.0;
            int max = 9;
            if (numEnemyDropsites > max)
                numEnemyDropsites = max;
            for (k = 0; < numEnemyDropsites)
            {
                int dropsiteUnitID = -1;
                int possibleEnemyDropsiteUnitID = findUnitByIndex(enemyEconUnit, k, cUnitStateAlive, -1, enemyPlayerID);
                vector possibleEnemyDropsiteUnitLocation = kbUnitGetPosition(possibleEnemyDropsiteUnitID);
                float distanceToEnemyMainBase = xsVectorLength(enemyMainBaseUnitLocation - possibleEnemyDropsiteUnitLocation);
                if ((distanceToEnemyMainBase > 85.0) && (distanceToEnemyMainBase > distanceToSavedEnemyDropsiteUnitID))
                {
                    dropsiteUnitID = possibleEnemyDropsiteUnitID;
                    int numEnemyMilitaryBuildingsAtDropsiteLocation = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    int numEnemyShooters = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    if ((numEnemyMilitaryBuildingsAtDropsiteLocation < 3) && (numEnemyShooters < 1) && (SameAG(kbUnitGetPosition(dropsiteUnitID), mainBaseLocation) == true))
                    {
                        if ((lastTargetCount > 1) && (dropsiteUnitID == lastTargetUnitID))
                        {
                            continue;
                        }
                        targetUnitID = dropsiteUnitID;
                        targetIsDropsite = true;
                        success = true;
                        distanceToSavedEnemyDropsiteUnitID = distanceToEnemyMainBase;
                    }
                }
            }
        }
    }
    if (success == false)
    {
        if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
        {
            militaryUnit1ID = findUnit(cUnitTypeHumanSoldier, cUnitStateAlive, cActionIdle);
            if (militaryUnit1ID > 0)
            {
                aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
            }
        }
        if ((equal(gRaidingPartyLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
        {
            int militaryUnit2ID = findUnit(cUnitTypeHumanSoldier, cUnitStateAlive, cActionIdle);
            if (militaryUnit2ID > 0)
            {
                aiTaskUnitMove(militaryUnit2ID, gRaidingPartyLastMarketLocation);
            }
        }
        return;
    }


    if ((lastTargetCount > 1) && (dropsiteUnitIDinCloseRange != -1))
    {
        if (equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false)
        {
            militaryUnit1ID = findUnit(cUnitTypeHumanSoldier,cUnitStateAlive, cActionIdle);
            if (militaryUnit1ID > 0)
            {
                aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
            }
        }
    }

    if (targetUnitID < 0)// transport and can't reach?
    {
        return;
    }
    int Owner = kbUnitGetOwner(targetUnitID);
    int raidingPartyAttackID = createDefOrAttackPlan("Raiding Party", false, -1, 20, cInvalidVector, -1, -1, false);
    if (raidingPartyAttackID < 0)
        return;

    echo("Raiding Party attack plan created: " + raidingPartyAttackID);
    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanPlayerID, 0, Owner);
    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanSpecificTargetID, 0, targetUnitID);
    aiPlanSetVariableBool(raidingPartyAttackID, cAttackPlanAutoUseGPs, 0, false);
    aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHumanSoldier, 4, 5, 6);

    if (targetIsMarket == true)
    {
        if (aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon) > 0)
            aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAbstractSiegeWeapon, 1, 1, 1);
    }

    aiPlanSetDesiredPriority(raidingPartyAttackID, 44); //lower than most attack plans
    aiPlanSetActive(raidingPartyAttackID);
    gRaidingPartyTargetUnitID = targetUnitID;
    gRaidingPartyAttackID = raidingPartyAttackID;
    if (targetIsMarket == true)
        gRaidingPartyLastMarketLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);
    else
        gRaidingPartyLastTargetLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);

    attackPlanStartTime = xsGetTime();
    if (lastTargetUnitID == gRaidingPartyTargetUnitID)
        lastTargetCount = lastTargetCount + 1;
    else
    {
        lastTargetUnitID = gRaidingPartyTargetUnitID;
        lastTargetCount = 0;
    }
}

//==============================================================================
rule createLandAttack
minInterval 53 //starts in cAge2
inactive
{
    if (ShouldIAgeUp() == true)
        xsSetRuleMinIntervalSelf(106);
    else
        xsSetRuleMinIntervalSelf(53);

    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    static int attackPlanStartTime = -1;
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);

    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }

    //If we already have a landAttackPlan don't make another one.
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;

            if (attackPlanID == gLandAttackPlanID)
            {
                if ((aiPlanGetState(attackPlanID) < cPlanStateAttack)
                    && (((xsGetTime() > attackPlanStartTime + 3*60*1000) && (attackPlanStartTime != -1))
                        || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 1) || (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
                    || (gTransportMap == true) && (aiPlanGetState(attackPlanID) == cPlanStateGather) && (xsGetTime() > attackPlanStartTime + 2*60*1000))
                {
                    aiPlanDestroy(attackPlanID);
                    echo("destroying gLandAttackPlanID as it has been active for more than 4 Minutes");
                    continue;
                }
                return;
            }
        }
    }

    int enemyPlayerID = aiGetMostHatedPlayerID();
    int numTargetPlayerSettlements = kbUnitCount(enemyPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    int numMilUnitsInDefPlans = AvailableUnitsFromDefPlans();

    if (kbGetAge() < cAge3)
    {
        if (gRushCount < 1)
        {
            return;
        }
    }

    if ((numTitans > 0) && (numTargetPlayerSettlements > 0))
    {
        return;
    }
    else if (numEnemyTitansNearMBInR85 > 0)
    {
        return;
    }
    else if (numEnemyTitansNearDefBInR55 > 0)
    {
        return;
    }
    else if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }
    else if (numEnemyMilUnitsNearMBInR80 > 10)
    {
        return;
    }

    bool settlementPosDefPlanActive = false;
    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true ); // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                settlementPosDefPlanActive = true;
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 35.0, true);

                int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
                int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
                int Combined = NumEnemyBuildings + enemyMilUnitsInR50;
                if (Combined <= 5)
                    settlementPosDefPlanActive = false;
            }
        }
    }

    if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1) && (Combined > 5))
    {
        return;
    }

    int requiredUnits = kbGetPopCap() / 10;
    if ((kbGetAge() == cAge2) && (gRushAttackCount < gRushCount) && (ShouldIAgeUp() == false))
    {
        if ((gRushCount > 1) && (gRushAttackCount == 0))
            requiredUnits = gFirstRushSize;
        else
            requiredUnits = gRushSize;
        if (numMilUnitsInDefPlans < requiredUnits * 0.8)
            return;
    }
    else
    {
        if (ReadyToAttack() == false)
            return;
    }

    if (TitanAvailable == true)
    {
        bool TitanGate = false;
        int eTGate = findUnitByRel(cUnitTypeTitanGate, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy);
        if (eTGate != -1)
        {
            enemyPlayerID = kbUnitGetOwner(eTGate);
            TitanGate = true;
        }
    }

    int landAttackPlanID = createDefOrAttackPlan("landAttackPlan", false, -1, 30, cInvalidVector, -1, 50, false);
    if (landAttackPlanID < 0)
        return;

    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
    aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans*0.85, numMilUnitsInDefPlans, numMilUnitsInDefPlans);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    if (TitanGate == true)
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanSpecificTargetID, 0, eTGate);

    // Specify other continent so that armies will transport
    if (gTransportMap == true)
    {
        aiPlanSetNumberVariableValues(landAttackPlanID, cAttackPlanTargetAreaGroups, 2, true);
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mainBaseLocation));
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(kbBaseGetLocation(enemyPlayerID, kbBaseGetMainID(enemyPlayerID))));
    }

    gLandAttackPlanID = landAttackPlanID;
    if ((cMyCiv == cCivKronos) && (gGlutRatio >= 0.25))
        aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);

    int GPFindPlan = aiFindBestAttackGodPowerPlan();
    if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
        aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);

    if (gRushAttackCount < gRushCount)
        gRushAttackCount = gRushAttackCount + 1;
    aiPlanSetActive(landAttackPlanID);

    if (gSomeData != -1)
        aiPlanSetUserVariableInt(gSomeData, LandAttackTarget, 0, aiPlanGetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0));
    attackPlanStartTime = xsGetTime();
}

//==============================================================================
rule defendBaseUnderAttack
minInterval 1 //starts in cAge2, activated in baseAttackTracker rule
inactive
{
    xsSetRuleMinIntervalSelf(17);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gBaseUnderAttackLocation);

    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);

    static int defendPlanStartTime = -1;

    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);

    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gBaseUnderAttackLocation, 15.0, true);

    int enemyMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 40.0, true);
    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 50.0, true);
    int enemySettlementAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 15.0);
    int numMotherNatureSettlementsAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, gBaseUnderAttackLocation, 15.0);
    int numAttEnemySiegeInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, gBaseUnderAttackLocation, 50.0, true);

    //If we already have a gBaseUnderAttackDefPlanID, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;

            int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
            if (defendPlanID == gBaseUnderAttackDefPlanID)
            {

                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                    || (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                    || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 2.5)))
                {
                    aiPlanDestroy(defendPlanID);
                    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
                        gBaseUnderAttackDefPlanID = -1;
                    gBaseUnderAttackID = -1;
                    xsSetRuleMinInterval("defendPlanRule", 2);
                    xsEnableRule("defendPlanRule");
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }

                if ((alliedBaseAtDefPlanPosition > 0) || ((xsGetTime() > defendPlanStartTime + 1*20*1000) && (enemyMilUnitsInR50 < 3) && (numAttEnemySiegeInR50 < 1)))
                {
                    aiPlanDestroy(defendPlanID);
                    if (alliedBaseAtDefPlanPosition > 0)
                        gBaseUnderAttackID = -1;
                    gBaseUnderAttackDefPlanID = -1;
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }

                if (defPlanBaseID != gBaseUnderAttackID)
                {
                    aiPlanSetBaseID(defendPlanID, gBaseUnderAttackID);
                }
                return;
            }
        }
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }

    if (numMilUnits < 20)
    {
        return;
    }
    int baseUnderAttackDefPlanID = createDefOrAttackPlan("baseUnderAttackDefPlan", true, 40, 20, gBaseUnderAttackLocation, gBaseUnderAttackID, 53, false);
    if (baseUnderAttackDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();

        if (distToMainBase < 80.0)
        {
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);

            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary, 4, 16, 16);
            if (cMyCiv == cCivHades)
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 2, 2);
        }
        else
        {
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 1, 2);
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, 18, 20);
            if (cMyCiv == cCivHades)
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 4, 4);
        }
        aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);


        //override
        if (enemyMilUnitsInR40 > 16)
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR40 + 6, enemyMilUnitsInR40 + 6);
        aiPlanSetActive(baseUnderAttackDefPlanID);
        gBaseUnderAttackDefPlanID = baseUnderAttackDefPlanID;
        xsSetRuleMinIntervalSelf(17);
    }
}

//==============================================================================
rule defendAlliedBase   //TODO: check all allied bases not just the main base of each ally
minInterval 89 //starts in cAge2
inactive
{
    if (mCanIDefendAllies == false)
    {
        xsDisableSelf();
        return;
    }
    xsSetRuleMinIntervalSelf(89);
    int alliedBaseUnitID = -1;
    int startIndex = aiRandInt(cNumberPlayers);

    for (i = 0; < cNumberPlayers)
    {
        //If we're past the end of our players, go back to the start.
        int actualIndex = i + startIndex;
        if (actualIndex >= cNumberPlayers)
            actualIndex = actualIndex - cNumberPlayers;
        if (actualIndex <= 0)
            continue;
        if (actualIndex == cMyID)
            continue;
        if (kbIsPlayerAlly(actualIndex) == true)
        {
            if (kbIsPlayerResigned(actualIndex) == true)
                continue;

            alliedBaseUnitID = getMainBaseUnitIDForPlayer(actualIndex);

            vector alliedBaseLocation = kbUnitGetPosition(alliedBaseUnitID);
            int numEnemyTitansInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 70.0, true);
            int numEnemyMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 70.0, true);
            int alliedMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 70.0, true);

            if ((numEnemyTitansInR70 > 0) || (numEnemyMilUnitsInR70 > alliedMilUnitsInR70))
            {
                break;
            }
            else
                alliedBaseUnitID = -1;
        }
    }


    static int defendPlanStartTime = -1;
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);

    int enemySettlementAtAlliedBasePosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 15.0);
    int numMotherNatureSettlementsAtAlliedBasePosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, alliedBaseLocation, 15.0);

    //If we already have a gAlliedBaseDefPlanID, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (j = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, j);
            if (defendPlanID == -1)
                continue;

            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int enemySettlementAtDefPointPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 15.0);
            int alliedTcs = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            int numMotherNatureSettlementsAtDefPointPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, defPlanDefPoint, 15.0);
            int numEnemyTitansNearDefPointInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int numEnemyMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int alliedMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 90.0, true);
            static int count = 0;

            if (defendPlanID == gAlliedBaseDefPlanID)
            {
                HelpSettleID = -1;
                xsSetRuleMinIntervalSelf(20); // be on alert
                if ((enemySettlementAtDefPointPosition - numMotherNatureSettlementsAtDefPointPosition > 0) || (alliedTcs < 1))
                {
                    aiPlanDestroy(defendPlanID);
                    gAlliedBaseDefPlanID = -1;
                    xsSetRuleMinIntervalSelf(40);
                    count = 0;
                    return;
                }

                if ((numEnemyTitansNearDefPointInR70 < 1) && (numEnemyMilUnitsNearDefPointInR70 < alliedMilUnitsNearDefPointInR70))
                {
                    if (count > 1)
                    {
                        aiPlanDestroy(defendPlanID);
                        gAlliedBaseDefPlanID = -1;
                        xsSetRuleMinIntervalSelf(40);
                        count = 0;
                        return;
                    }
                    else
                        count = count + 1;
                }
                else
                {
                    count = 0;
                    if ((numEnemyTitansNearDefPointInR70 > 0) && (numEnemyMilUnitsNearDefPointInR70 < 16))
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 20, 20);
                    }
                    else
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, numEnemyMilUnitsNearDefPointInR70 - alliedMilUnitsInR70 + 4, numEnemyMilUnitsNearDefPointInR70 - alliedMilUnitsNearDefPointInR70 + 4);
                    }
                }
                return;
            }
        }
    }


    if (HelpSettleID != -1)
    {
        alliedBaseUnitID = HelpSettleID;
        HelpSettleID = -1;
        alliedBaseLocation = kbUnitGetPosition(alliedBaseUnitID);
        numEnemyTitansInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 90.0, true);
        numEnemyMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 90.0, true);
        alliedMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 90.0, true);
        enemySettlementAtAlliedBasePosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 15.0);
        numMotherNatureSettlementsAtAlliedBasePosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, alliedBaseLocation, 15.0);

        if ((alliedMilUnitsInR70 > numEnemyMilUnitsInR70+6))
            return;
    }

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    if ((SameAG(alliedBaseLocation, mainBaseLocation) == false) && (gTransportMap == true)) // transport and can't reach?
        return;

    if (alliedBaseUnitID == -1)
    {
        return;
    }

    if (enemySettlementAtAlliedBasePosition - numMotherNatureSettlementsAtAlliedBasePosition > 0)
    {
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }

    if (numMilUnits < 14)
    {
        return;
    }

    int alliedBaseDefPlanID = createDefOrAttackPlan("alliedBaseDefPlan", true, 85, 20, alliedBaseLocation, -1, 35, false);
    if (alliedBaseDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);

        if ((numEnemyTitansInR70 > 0) && (numEnemyMilUnitsInR70 < 16))
        {
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 20, 20);
        }
        else
        {
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeLandMilitary, 0, numEnemyMilUnitsInR70 - alliedMilUnitsInR70 + 4, numEnemyMilUnitsInR70 - alliedMilUnitsInR70 + 4);
        }
        aiPlanSetActive(alliedBaseDefPlanID);
        gAlliedBaseDefPlanID = alliedBaseDefPlanID;
        xsSetRuleMinIntervalSelf(20); // be on alert
    }
}

//==============================================================================
rule tacticalBuildings
minInterval 11
inactive
{
    int numAttBuildings = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, cActionRangedAttack, cMyID);
    if (numAttBuildings < 1)
    {
        return;
    }
    for (i = 0; < numAttBuildings)
    {
        int attBuildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, cActionRangedAttack, cMyID);
        if (attBuildingID == -1)
            continue;


        int currentTargetID = kbUnitGetTargetUnitID(attBuildingID);
        if (kbUnitIsType(currentTargetID, cUnitTypeHumanSoldier) == true)
        {
            continue;
        }

        float radius = 20.0;
        if (kbUnitIsType(attBuildingID, cUnitTypeAbstractFortress) == true)
        {
            if (cMyCulture == cCultureNorse)
                radius = radius - 2;
        }
        else if (kbUnitIsType(attBuildingID, cUnitTypeAbstractSettlement) == true)
        {
            if (kbGetTechStatus(cTechFortifyTownCenter) > cTechStatusResearching)
                radius = radius + 2;
        }

        vector buildingPosition = kbUnitGetPosition(attBuildingID);
        int numEnemyHumanSoldiersInR = getNumUnitsByRel(cUnitTypeHumanSoldier, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
        int numEnemyVillagersInR = getNumUnitsByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);

        if (numEnemyHumanSoldiersInR < 1)
        {
            if (numEnemyVillagersInR > 0)
            {
                int enemyVillagerUnitID = findUnitByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
                if (enemyVillagerUnitID != -1)
                {
                    aiTaskUnitWork(attBuildingID, enemyVillagerUnitID);
                    continue;
                }
            }
        }
        else
        {
            int enemyHumanSoldierID = findUnitByRel(cUnitTypeHumanSoldier, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
            if (enemyHumanSoldierID != -1)
            {
                aiTaskUnitWork(attBuildingID, enemyHumanSoldierID);
                continue;
            }
        }
    }
}

//==============================================================================
rule tacticalTitan
minInterval 5 //starts in cAge5, activated in repairTitanGate /11
inactive
{
    static bool titanCreated = false;
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    if (titanCreated == false)
    {
        if (numTitans > 0)
        {
            titanCreated = true;
        }
        else
        {
            return;
        }
    }

    int titanID = findUnit(cUnitTypeAbstractTitan);
    if (titanID == -1)
    {
        xsDisableSelf();
        return;
    }

    vector titanPosition = kbUnitGetPosition(titanID);
    int myMilUnitsInR20 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, titanPosition, 20.0);
    int numAttEnemyMilUnitsInR10 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 10.0, true);

    int currentTargetID = kbUnitGetTargetUnitID(titanID);

    int planID = kbUnitGetPlanID(titanID);
    vector defPlanDefPoint = aiPlanGetVariableVector(planID, cDefendPlanDefendPoint, 0);
    if (equal(defPlanDefPoint, cInvalidVector) == false)
    {
        float defPlanEngageRange = aiPlanGetVariableFloat(planID, cDefendPlanEngageRange, 0);
        float distanceToDefPoint = xsVectorLength(titanPosition - defPlanDefPoint);
        if (distanceToDefPoint > defPlanEngageRange - 1.0)
        {
            float minDistance = 5.0 + distanceToDefPoint - defPlanEngageRange;
            if (minDistance < 10.0)
                minDistance = 10.0;
            float multiplier = minDistance / distanceToDefPoint;
            vector directionalVector = titanPosition - defPlanDefPoint;
            vector desiredPosition = titanPosition - directionalVector * multiplier;

            if ((numAttEnemyMilUnitsInR10 < 5) || (myMilUnitsInR20 < 5))
            {
                aiTaskUnitMove(titanID, desiredPosition);
                return;
            }
        }
    }
    else
    {
        int attPlanTargetID = aiPlanGetVariableInt(planID, cAttackPlanSpecificTargetID, 0);
        if ((attPlanTargetID != -1) && (aiPlanGetState(planID) == cPlanStateAttack))
        {
            if ((kbUnitIsType(currentTargetID, cUnitTypeAbstractVillager) == true)
                || (kbUnitIsType(currentTargetID, cUnitTypeAbstractTradeUnit) == true))
            {
                aiTaskUnitWork(titanID, attPlanTargetID);
                return;
            }
        }
    }

    if ((kbUnitIsType(currentTargetID, cUnitTypeHumanSoldier) == true)
        || (kbUnitIsType(currentTargetID, cUnitTypeLogicalTypeMythUnitNotTitan) == true)
        || (kbUnitIsType(currentTargetID, cUnitTypeAbstractTitan) == true)
        || (kbUnitIsType(currentTargetID, cUnitTypeBuildingsThatShoot) == true))
    {
        return;
    }

    int numAttEnemyHumanSoldiersInR8 = getNumUnitsByRel(cUnitTypeHumanSoldier, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 8.0, true);
    int numAttEnemyArchersInR20 = getNumUnitsByRel(cUnitTypeAbstractArcher, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
    int numEnemyMythUnitsInR8 = getNumUnitsByRel(cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);

    if (numAttEnemyHumanSoldiersInR8 < 4)
    {
        if (numEnemyMythUnitsInR8 > 0)
        {
            int enemyMythUnitID = findUnitByRelByIndex(cUnitTypeLogicalTypeMythUnitNotTitan, 0, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);
            if (enemyMythUnitID != -1)
            {
                aiTaskUnitWork(titanID, enemyMythUnitID);
                return;
            }
        }
        else if (numAttEnemyArchersInR20 > 4)
        {
            int attEnemyArcherID = findUnitByRelByIndex(cUnitTypeAbstractArcher, 0, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
            if (attEnemyArcherID != -1)
            {
                aiTaskUnitWork(titanID, attEnemyArcherID);
                return;
            }
        }
    }
    else
    {
        int attEnemyHumanSoldierID = findUnitByRelByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 8.0, true);
        if (attEnemyHumanSoldierID != -1)
        {
            aiTaskUnitWork(titanID, attEnemyHumanSoldierID);
            return;
        }
    }
}

//==============================================================================
rule baseAttackTracker
minInterval 13 //starts in cAge2
inactive
{
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    static int lastBaseID = -1;
    bool townDefenseGPActivated = false;
    bool BUADefPlanActivated = false;

    for (i = 0; < numSettlements)
    {
        int otherBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive);
        if (otherBaseUnitID < 0)
            continue;
        else
        {
            //Get the base ID
            int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
            if (otherBaseID == -1)
                continue;

            vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
            float distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            int enemyMilUnitsInR45 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation, 45.0, true);
            int myMilUnitsInR45 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, otherBaseLocation, 45.0, true);
            //Get the time under attack.
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, otherBaseID);
            if ((secondsUnderAttack > 15) || ((secondsUnderAttack > 0) && (enemyMilUnitsInR45 > 9)))
            {
                //Try to use a god power to help us.
                if (secondsUnderAttack > 30)
                {
                    if (townDefenseGPActivated == false)
                    {
                        if (gTownDefenseGodPowerPlanID != -1)
                        {
                            if (otherBaseID == lastBaseID)
                            {
                                //skip it once
                                lastBaseID = -1;
                            }
                            else
                            {
                                //release previous GP plan
                                releaseTownDefenseGP();
                            }
                        }

                        if (gTownDefenseGodPowerPlanID == -1)
                        {
                            //if there is no gTownDefenseGodPowerPlanID, find one
                            findTownDefenseGP(otherBaseID);
                            if (gTownDefenseGodPowerPlanID != -1)
                            {
                                townDefenseGPActivated = true;
                                //save the lastBaseID
                                lastBaseID = otherBaseID;
                            }
                        }
                    }
                }

                if (otherBaseID != mainBaseID)
                {
                    if (myMilUnitsInR45 < enemyMilUnitsInR45)
                    {
                        //Try to train a military unit there
                        taskMilUnitTrainAtBase(otherBaseID);
                    }
                }

                //if it's not our main base, create a defend plan
                if ((otherBaseID != mainBaseID) && (distanceToMainBase > 60.0) && (BUADefPlanActivated == false)
                    && ((equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), gBaseUnderAttackLocation) == false)
                        || (gBaseUnderAttackDefPlanID == -1)))
                {
                    xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                    xsDisableRule("defendBaseUnderAttack");
                    aiPlanDestroy(gBaseUnderAttackDefPlanID);
                    gBaseUnderAttackDefPlanID = -1;
                    gBaseUnderAttackLocation = otherBaseLocation;
                    gBaseUnderAttackID = otherBaseID;
                    xsEnableRule("defendBaseUnderAttack");
                    xsSetRuleMinInterval("defendPlanRule", 2);
                    xsEnableRule("defendPlanRule");
                    BUADefPlanActivated = true;
                }
            }
        }
    }
}

rule updatePlayerToAttack   //Updates the player we should be attacking.
minInterval 27         //starts in cAge1
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


rule ShouldIResign
minInterval 10         //starts in cAge1
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
