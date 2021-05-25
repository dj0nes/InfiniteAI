
//==============================================================================
// Void initRethlAge 2-4
//==============================================================================
void initRethlAge2(void)
{
    // The Greeks are working as intended, so we're skipping that.

    switch(cMyCulture)
    {
    case cCultureGreek:
    {
        if ((cMyCiv == cCivHades) && (aiGetWorldDifficulty() != cDifficultyEasy))
            xsEnableRuleGroup("HateScriptsSpecial");
        MedicMaintain = createSimpleMaintainPlan(cUnitTypePhysician, 1, false, kbBaseGetMainID(cMyID));
        aiPlanSetDesiredPriority(MedicMaintain, 1);
        aiPlanSetEscrowID(MedicMaintain, cMilitaryEscrowID);
        break;
    }
    case cCultureEgyptian:
    {
        xsEnableRule("buildMonuments");
        xsEnableRule("getHandsOfThePharaoh");
        if (cMyCiv == cCivIsis)
            xsEnableRule("getFloodOfTheNile");
        else if (cMyCiv == cCivRa)
            xsEnableRule("getSkinOfTheRhino");
        else if (cMyCiv == cCivSet)
        {
            xsEnableRule("getFeral");
            int Hyena = createSimpleMaintainPlan(cUnitTypeHyenaofSet, 1, false, kbBaseGetMainID(cMyID));
            aiPlanSetDesiredPriority(Hyena, 20);
        }
        if (cMyCiv != cCivSet)
        {
            int Spearman = createSimpleMaintainPlan(cUnitTypeSpearman, 1, false, kbBaseGetMainID(cMyID));
            aiPlanSetDesiredPriority(Spearman, 20);
            gAirScout = cUnitTypeSpearman;
            xsEnableRule("airScout1");
        }
        break;
    }
    case cCultureNorse:
    {
        if (gUlfsarkMaintainPlanID != -1)
            aiPlanSetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0, 2);
        if (cMyCiv == cCivThor)
            xsEnableRule("getPigSticker");
        else if (cMyCiv == cCivOdin)
            xsEnableRule("getLoneWanderer");
        else if (cMyCiv == cCivLoki)
            xsEnableRule("getEyesInTheForest");
        break;
    }
    case cCultureAtlantean:
    {
        if (cMyCiv == cCivGaia)
            xsEnableRule("getChannels");
        else if (cMyCiv == cCivOuranos)
            xsEnableRule("buildSkyPassages");
        else if (cMyCiv == cCivKronos)
            xsEnableRule("getFocus");
        int Turma = createSimpleMaintainPlan(cUnitTypeJavelinCavalry, 1, false);
        gAirScout = cUnitTypeJavelinCavalry;
        xsEnableRule("airScout1");
        break;
    }
    case cCultureChinese:
    {
        xsEnableRule("buildGarden");
        xsEnableRule("ChooseGardenResource");
        if (cMyCiv == cCivNuwa)
            xsEnableRule("getAcupuncture");
        else if (cMyCiv == cCivShennong)
            xsEnableRule("getWheelbarrow");
        else if (cMyCiv == cCivFuxi)
            xsEnableRule("rSpeedUpBuilding");
        aiPlanSetVariableInt(mChineseImmortal, cTrainPlanNumberToMaintain, 0, 8);
        break;
    }
    }

    if ((cRandomMapName == "highland") || (cRandomMapName == "nomad"))
    {
        gWaterMap=true;
        xsEnableRule("fishing");
        if (cRandomMapName == "nomad")
        {
            xsEnableRule("NavalGoalMonitor");
            xsEnableRule("WaterDefendPlan");
            xsEnableRule("getHeroicFleet");
        }
        if (ShowAIDebug == true) aiEcho("Fishing enabled for Nomad and Highland map");
    }

    if (cRandomMapName == "valley of kings")
        xsEnableRule("BanditMigdolRemoval");

    //HateScripts
    if (aiGetWorldDifficulty() != cDifficultyEasy)
        xsEnableRuleGroup("HateScripts");

    if ((bWallAllyMB == true) && (HasHumanAlly == true))
        xsEnableRule("WallAllyMB");

    if (bWallCleanup == true)
        xsEnableRuleGroup("WallCleanup");

    //Try to transport stranded Units.
    if (gTransportMap == true)
        xsEnableRuleGroup("BuggedTransport");
}

//==============================================================================
// RULE ActivateRethOverridesAge 2-4
//==============================================================================
rule ActivateRethOverridesAge2
minInterval 30
inactive
group reth
{
    if (kbGetAge() > cAge1)
    {
        initRethlAge2();
        //GREEK MINOR GOD SPECIFIC
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge2Hermes) == cTechStatusActive)
            xsEnableRuleGroup("Hermes");

        //CHINESE MINOR GOD SPECIFIC
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Change) == cTechStatusActive)
            xsEnableRuleGroup("Change");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Huangdi) == cTechStatusActive)
            xsEnableRuleGroup("Huangdi");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge2Sunwukong) == cTechStatusActive)
            xsEnableRuleGroup("Sunwukong");

        //EGYPTIAN MINOR GOD SPECIFIC
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Bast) == cTechStatusActive)
            xsEnableRuleGroup("Bast");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Ptah) == cTechStatusActive)
            xsEnableRuleGroup("Ptah");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Anubis) == cTechStatusActive)
            xsEnableRuleGroup("Anubis");

        //Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Forseti) == cTechStatusActive)
            xsEnableRuleGroup("Forseti");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Freyja) == cTechStatusActive)
            xsEnableRuleGroup("Freyja");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge2Heimdall) == cTechStatusActive)
            xsEnableRuleGroup("Heimdall");

        //Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Leto) == cTechStatusActive)
            xsEnableRuleGroup("Leto");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Prometheus) == cTechStatusActive)
            xsEnableRuleGroup("Prometheus");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge2Okeanus) == cTechStatusActive)
        {
            xsEnableRuleGroup("Oceanus");
            MedicMaintain = createSimpleMaintainPlan(cUnitTypeFlyingMedic, 1, false, kbBaseGetMainID(cMyID));
            aiPlanSetDesiredPriority(MedicMaintain, 1);
            aiPlanSetEscrowID(MedicMaintain, cMilitaryEscrowID);
        }
        xsEnableRule("activateObeliskClearingPlan"); // this also looks for villagers, don't get confused by the name.
        if (aiGetWorldDifficulty() != cDifficultyEasy)
            xsEnableRule("LaunchAttacks"); // try to get them running more often, if pop/mil is within reason etc.
        xsDisableSelf();
    }
}

rule ActivateRethOverridesAge3
minInterval 30
inactive
group reth
{
    if (kbGetAge() > cAge2)
    {
        //GREEK MINOR GOD SPECIFIC
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge3Aphrodite) == cTechStatusActive)
            xsEnableRuleGroup("Aphrodite");

        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge3Apollo) == cTechStatusActive)
            xsEnableRuleGroup("Apollo");

        //CHINESE MINOR GOD SPECIFIC
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Dabogong) == cTechStatusActive)
        {
            xsEnableRuleGroup("Dabogong");
            aiPlanSetVariableInt(cMonkMaintain, cTrainPlanNumberToMaintain, 0, 3);
        }
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Hebo) == cTechStatusActive)
            xsEnableRuleGroup("Hebo");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge3Zhongkui) == cTechStatusActive)
            xsEnableRuleGroup("Zhongkui");

        //EGYPTIAN MINOR GOD SPECIFIC
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Nephthys) == cTechStatusActive)
            xsEnableRuleGroup("Nephthys");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Sekhmet) == cTechStatusActive)
            xsEnableRuleGroup("Sekhmet");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge3Hathor) == cTechStatusActive)
        {
            xsEnableRuleGroup("Hathor");
            if (gTransportMap == true)
                int hRoc = createSimpleMaintainPlan(cUnitTypeRoc, 1, false, kbBaseGetMainID(cMyID));
        }

        //Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Skadi) == cTechStatusActive)
            xsEnableRuleGroup("Skadi");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Njord) == cTechStatusActive)
            xsEnableRuleGroup("Njord");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge3Bragi) == cTechStatusActive)
            xsEnableRuleGroup("Bragi");

        //Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Rheia) == cTechStatusActive)
            xsEnableRuleGroup("Rheia");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Theia) == cTechStatusActive)
            xsEnableRuleGroup("Theia");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge3Hyperion) == cTechStatusActive)
            xsEnableRuleGroup("Hyperion");

        mRusher = false;
        if (cMyCulture == cCultureChinese)
        {
            if (aiGetWorldDifficulty() != cDifficultyEasy)
                xsEnableRuleGroup("HateScriptsSpecial");
            aiPlanDestroy(eChineseHero);
        }

        if (cMyCulture == cCultureEgyptian)
        {
            xsEnableRule("rebuildSiegeCamp");
            if (cMyCiv == cCivRa)
            {
                CPlanID=aiPlanCreate("Market Priest Empower", cPlanEmpower);
                if (CPlanID >= 0)
                {
                    aiPlanSetEconomy(CPlanID, true);
                    aiPlanAddUnitType(CPlanID, cUnitTypePriest, 0, 1, 1);
                    aiPlanSetVariableInt(CPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMarket);
                    aiPlanSetDesiredPriority(CPlanID, 69);
                    aiPlanSetActive(CPlanID);
                }
            }
        }
        if (cMyCulture == cCultureNorse)
        {
            kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAbstractArcher, 1.0); // Ok to Bogsveigir now
            xsEnableRuleGroup("HateScriptsSpecial");
        }
        if (aiGetWorldDifficulty() != cDifficultyEasy)
        {
            int MyCata = -1;
            if (cMyCulture == cCultureGreek)
                MyCata = cUnitTypePetrobolos;
            if (cMyCulture == cCultureEgyptian)
                MyCata = cUnitTypeCatapult;
            if (cMyCulture == cCultureNorse)
                MyCata = cUnitTypeBallista;
            if (cMyCulture == cCultureAtlantean)
                MyCata = cUnitTypeOnager;
            if (cMyCulture == cCultureChinese)
            {
                if (cMyCiv == cCivShennong)
                    MyCata = cUnitTypeSittingTigerShennong;
                else MyCata = cUnitTypeSittingTiger;
            }
            if (MyCata != -1)
            {
                CataMaintain = createSimpleMaintainPlan(MyCata, 1, false, kbBaseGetMainID(cMyID));
                aiPlanSetDesiredPriority(CataMaintain, 100);
            }
            xsEnableRuleGroup("Forwarding");
        }
        xsDisableSelf();
    }
}

rule ActivateRethOverridesAge4
minInterval 15
inactive
group reth
{
    if (kbGetAge() > cAge3)
    {
        //GREEK MINOR GOD SPECIFIC
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Artemis) == cTechStatusActive)
            xsEnableRuleGroup("Artemis");
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Hera) == cTechStatusActive)
            xsEnableRuleGroup("Hera");
        if (cMyCulture == cCultureGreek && kbGetTechStatus(cTechAge4Hephaestus) == cTechStatusActive)
            xsEnableRuleGroup("Hephaestus");

        //CHINESE MINOR GOD SPECIFIC
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Aokuang) == cTechStatusActive)
            xsEnableRuleGroup("Aokuang");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Xiwangmu) == cTechStatusActive)
            xsEnableRuleGroup("Xiwangmu");
        if (cMyCulture == cCultureChinese && kbGetTechStatus(cTechAge4Chongli) == cTechStatusActive)
            xsEnableRuleGroup("Chongli");

        //Egyptian MINOR GOD SPECIFIC
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Horus) == cTechStatusActive)
            xsEnableRuleGroup("Horus");
        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Osiris) == cTechStatusActive)
        {
            xsEnableRuleGroup("Osiris");
            eOsiris=aiPlanCreate("Son of Osiris Empower", cPlanEmpower);
            if (eOsiris >= 0)
            {
                aiPlanSetEconomy(eOsiris, true);
                aiPlanAddUnitType(eOsiris, cUnitTypePharaohofOsiris, 1, 1, 1);
                aiPlanSetVariableInt(eOsiris, cEmpowerPlanTargetTypeID, 0, cUnitTypeAbstractSettlement);
                aiPlanSetDesiredPriority(eOsiris, 91);
                aiPlanSetBaseID(eOsiris, kbBaseGetMainID(cMyID));
                aiPlanSetVariableInt(eOsiris, cEmpowerPlanTargetID, 0, getMainBaseUnitIDForPlayer(cMyID));
                aiPlanSetActive(eOsiris);
            }
            Pempowermarket=aiPlanCreate("Pharaoh Secondary Empower", cPlanEmpower);
            if (Pempowermarket >= 0)
            {
                aiPlanSetEconomy(Pempowermarket, true);
                aiPlanAddUnitType(Pempowermarket, cUnitTypePharaohSecondary, 1, 1, 1);
                aiPlanSetVariableInt(Pempowermarket, cEmpowerPlanTargetTypeID, 0, cUnitTypeMarket); // market rarely works, but it's worth it.
                aiPlanSetDesiredPriority(Pempowermarket, 90);
                aiPlanSetActive(Pempowermarket);
            }
            if ((cMyCiv == cCivRa) && (CPlanID != -1))
                aiPlanDestroy(CPlanID);
        }

        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge4Thoth) == cTechStatusActive)
        {
            xsEnableRuleGroup("Thoth");
            int PhoenixReborn = createSimpleMaintainPlan(cUnitTypePhoenixFromEgg, 5, false);
            aiPlanSetVariableBool(PhoenixReborn, cTrainPlanUseMultipleBuildings, 0, true);
            aiPlanSetVariableInt(PhoenixReborn, cTrainPlanBuildFromType, 0, cUnitTypePhoenixEgg);
        }


        //Norse MINOR GOD SPECIFIC
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Tyr) == cTechStatusActive)
            xsEnableRuleGroup("Tyr");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Baldr) == cTechStatusActive)
            xsEnableRuleGroup("Baldr");
        if (cMyCulture == cCultureNorse && kbGetTechStatus(cTechAge4Hel) == cTechStatusActive)
            xsEnableRuleGroup("Hel");

        //Atlantean MINOR GOD SPECIFIC
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Atlas) == cTechStatusActive)
            xsEnableRuleGroup("Atlas");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Helios) == cTechStatusActive)
            xsEnableRuleGroup("Helios");
        if (cMyCulture == cCultureAtlantean && kbGetTechStatus(cTechAge4Hekate) == cTechStatusActive)
            xsEnableRuleGroup("Hekate");


        if (kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusObtainable)
            xsEnableRule("repairTitanGate");
        if (aiGetWorldDifficulty() > cDifficultyModerate && (aiGetGameMode() != cGameModeDeathmatch))
            xsEnableRule("randomUpgrader");

        if (cMyCulture == cCultureEgyptian && kbGetTechStatus(cTechAge2Bast) == cTechStatusActive) // Sphinx maintain, because they're just that good.
            createSimpleMaintainPlan(cUnitTypeSphinx, 2, false, kbBaseGetMainID(cMyID));
        // Unit picker

        if (cMyCiv == cCivSet)
            kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCrocodileofSet, 0.05);
        xsDisableSelf();
    }
}
//==============================================================================
// wonder death handler
//==============================================================================
void wonderDeathHandler(int playerID = -1)
{
    if (playerID == cMyID)
    {
        aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWonderDestroyed, -1);
        return;
    }
    if (playerID == aiGetMostHatedPlayerID())
        aiCommsSendStatement(playerID, cAICommPromptPlayerWonderDestroyed, -1);
}

//==============================================================================
// RULE HuntingDogsAsap
//==============================================================================
rule HuntingDogsAsap
        minInterval 4
inactive
{
    int HuntingDogsUpgBuilding = cUnitTypeGranary;
    if (cMyCulture == cCultureChinese)
        HuntingDogsUpgBuilding = cUnitTypeStoragePit;
    if (cMyCulture == cCultureAtlantean)
        HuntingDogsUpgBuilding = cUnitTypeGuild;

    if ((WaitForDock == true) && (kbGetAge() < cAge2) || (cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeManor, cUnitStateAlive) < 1)
        || (cMyCulture != cCultureNorse) && (kbUnitCount(cMyID, HuntingDogsUpgBuilding, cUnitStateAlive) < 1))
        return;

    if (gHuntingDogsASAP == true && aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, cTechHuntingDogs) < 0)
        createSimpleResearchPlan(cTechHuntingDogs, -1, cEconomyEscrowID, 25, true);
    xsDisableSelf();
}

//==============================================================================
// RULE ALLYCatchUp
//==============================================================================
rule ALLYCatchUp
minInterval 45
inactive
Group Donations
{
    if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
    {
        xsDisableSelf();
        return;
    }

    xsSetRuleMinIntervalSelf(45+aiRandInt(18));
    static int lastTargetPlayerID = -1;
    int Tcs = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    if ((Tcs < 1) || (kbGetAge() < cAge2) || (xsGetTime() < 10*60*1000))
        return;

    //First, check if we need a boost ourselves...
    int VilPop = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);
    if ((kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAliveOrBuilding) < VilPop * 0.6))
    {
        bool FoodTooLow = false;
        bool GoldTooLow = false;
        bool WoodTooLow = false;
        float REFood = (kbEscrowGetAmount(cEconomyEscrowID, cResourceFood) + kbEscrowGetAmount(cRootEscrowID, cResourceFood));
        float REgold = (kbEscrowGetAmount(cEconomyEscrowID, cResourceGold) + kbEscrowGetAmount(cRootEscrowID, cResourceGold));
        float REWood = (kbEscrowGetAmount(cEconomyEscrowID, cResourceWood) + kbEscrowGetAmount(cRootEscrowID, cResourceWood));
        if (REFood < 200)
            FoodTooLow = true;
        if (REgold < 80)
            GoldTooLow = true;
        if (REWood < 50)
            WoodTooLow = true;

        if (FoodTooLow == true)
        {
            MessageRel(cPlayerRelationAlly, RequestFood, cEmergency);
            echo("AI Comms: This is looking bad, requesting extra Food!");
        }
        if (GoldTooLow == true)
        {
            MessageRel(cPlayerRelationAlly, RequestGold, cEmergency);
            echo("AI Comms: This is looking bad, requesting extra Gold!");
        }
        if (WoodTooLow == true)
        {
            MessageRel(cPlayerRelationAlly, RequestWood, cEmergency);
            echo("AI Comms: This is looking bad, requesting extra Wood!");
        }
        if ((FoodTooLow == true) || (GoldTooLow == true) || (WoodTooLow == true))
        {
            xsSetRuleMinIntervalSelf(20);
            return;
        }
    }

    if (ShouldIAgeUp() == true)
    {
        int Food = 800;
        int Gold = 500;
        if (kbGetAge() == cAge3)
        {
            Food = 1000;
            Gold = 1000;
        }
        if (kbResourceGet(cResourceFood) < Food)
        {
            MessageRel(cPlayerRelationAlly, RequestFood);
            echo("AI Comms: Requesting Food for age up!");
        }
        if (kbResourceGet(cResourceGold) < Gold)
        {
            MessageRel(cPlayerRelationAlly, RequestGold);
            echo("AI Comms: Requesting Gold for age up!");
        }
        xsSetRuleMinIntervalSelf(25);
        return;
    }

    int actualPlayerID = -1;
    if (lastTargetPlayerID != -1)
        actualPlayerID = getRandomPlayerByRel(cPlayerRelationAlly, lastTargetPlayerID);
    if (actualPlayerID == -1)
        actualPlayerID = getRandomPlayerByRel(cPlayerRelationAlly);

    if (actualPlayerID != -1)
    {
        lastTargetPlayerID = actualPlayerID;
        int iTcs = kbUnitCount(actualPlayerID, cUnitTypeAbstractSettlement, cUnitStateAlive);
        int iMarkets = kbUnitCount(actualPlayerID, cUnitTypeMarket, cUnitStateAlive);
        int houseProtoID = cUnitTypeHouse;
        if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
            houseProtoID = cUnitTypeManor;
        int iHouses = kbUnitCount(actualPlayerID, houseProtoID, cUnitStateAlive);
        int Combined = iHouses + iTcs;
        if (Combined < 1)
            return;

        float foodSupply = kbResourceGet(cResourceFood);
        float goldSupply = kbResourceGet(cResourceGold);
        float woodSupply = kbResourceGet(cResourceWood);

        if ((kbGetAgeForPlayer(actualPlayerID) < cAge3) && (iTcs >= 1) && (kbGetAge() > cAge3) && (foodSupply > 1000) && (goldSupply > 800))
        {
            aiTribute(actualPlayerID, cResourceFood, 800);
            aiTribute(actualPlayerID, cResourceGold, 600);
            xsSetRuleMinIntervalSelf(65+aiRandInt(18));
            return;
        }
        if ((kbGetAgeForPlayer(actualPlayerID) < cAge4) && (kbGetAgeForPlayer(actualPlayerID) == cAge3) && (iTcs >= 1) && (iMarkets >= 1) && (kbGetAge() > cAge3) && (foodSupply > 1400) && (goldSupply > 1400))
        {
            aiTribute(actualPlayerID, cResourceFood, 1000);
            aiTribute(actualPlayerID, cResourceGold, 1000);
            xsSetRuleMinIntervalSelf(92+aiRandInt(18));
            return;
        }
        else
        {
            int donateFAmount = 100;
            int donateWAmount = 100;
            int donateGAmount = 100;
            int VillagerScore = kbUnitCount(actualPlayerID, cUnitTypeAbstractVillager, cUnitStateAlive);
            int InfiniteAIAlly = aiPlanGetUserVariableInt(gSomeData, PlayersData+actualPlayerID, 0);

            if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
                VillagerScore = VillagerScore * 3;

            if (aiGetWorldDifficulty() > cDifficultyHard)
            {
                if (foodSupply > 5000)
                    donateFAmount = 1000;
                if (woodSupply > 3500)
                    donateWAmount = 750;
                if (goldSupply > 5000)
                    donateGAmount = 1000;
            }

            if (foodSupply > 2000)
            {
                if (InfiniteAIAlly == 1)
                    MessagePlayer(actualPlayerID, ExtraFood);
                else
                    aiTribute(actualPlayerID, cResourceFood, donateFAmount);
            }
            if (woodSupply > 2000)
            {
                if (InfiniteAIAlly == 1)
                    MessagePlayer(actualPlayerID, ExtraWood);
                else
                    aiTribute(actualPlayerID, cResourceWood, donateWAmount);
            }
            if (goldSupply > 2000)
            {
                if (InfiniteAIAlly == 1)
                    MessagePlayer(actualPlayerID, ExtraGold);
                else
                    aiTribute(actualPlayerID, cResourceGold, donateGAmount);
            }

            if ((iTcs >= 1) && (InfiniteAIAlly == 0))
            {
                if ((VillagerScore <= 6) && (foodSupply > 350) && (kbGetAge() > cAge2)) // Ally appears to be dying, try to save it!
                {
                    if (kbGetCultureForPlayer(actualPlayerID) == cCultureAtlantean)
                    {
                        aiTribute(actualPlayerID, cResourceFood, 125);
                        if (woodSupply > 125)
                            aiTribute(actualPlayerID, cResourceWood, 25);
                    }
                    else
                        aiTribute(actualPlayerID, cResourceFood, 100);
                }
            }
        }
    }
}
//==============================================================================
// RULE introChat
//==============================================================================
rule introChat
minInterval 10
inactive
group reth
{
    if (aiGetWorldDifficulty() != cDifficultyEasy)
    {
        for (i=1; < cNumberPlayers)
        {
            if (i == cMyID)
                continue;
            if (kbIsPlayerAlly(i) == true)
                continue;
            if (kbIsPlayerHuman(i) == true)
                aiCommsSendStatement(i, cAICommPromptIntro, -1);
        }
    }
    xsDisableSelf();
}

//==============================================================================
// RULE myAgeTracker
//==============================================================================
rule myAgeTracker
minInterval 60
inactive
group reth
{
    static bool bMessage=false;
    static int messageAge=-1;

    //Disable this in deathmatch.
    if (aiGetGameMode() == cGameModeDeathmatch)
    {
        xsDisableSelf();
        return;
    }

    //Only the captain does this.
    if (aiGetCaptainPlayerID(cMyID) != cMyID)
        return;

    //Are we greater age than our most hated enemy?
    int myAge=kbGetAge();
    int hatedPlayerAge=kbGetAgeForPlayer(aiGetMostHatedPlayerID());

    //Reset the message counter if we have changed ages.
    if (bMessage == true)
    {
        if (messageAge == myAge)
            return;
        bMessage=false;
    }

    //Make a message??
    if ((myAge > hatedPlayerAge) && (bMessage == false))
    {
        bMessage=true;
        messageAge=myAge;
        aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWinningAgeRace, -1);
    }
    if ((hatedPlayerAge > myAge) && (bMessage == false))
    {
        bMessage=true;
        messageAge=myAge;
        aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILosingAgeRace, -1);
    }

    //Stop when we reach the finish line.
    if (myAge == cAge4)
        xsDisableSelf();
}

//==============================================================================
// RULE Helpme
//==============================================================================
rule Helpme
minInterval 23
inactive
{
    static bool messageSent=false;
    //Set our min interval back to 23 if it has been changed.
    if (messageSent == true)
    {
        xsSetRuleMinIntervalSelf(23);
        messageSent=false;
    }

    //Get our main base.
    int mainBaseID=kbBaseGetMainID(cMyID);
    if (mainBaseID < 0)
        return;

    //Get the time under attack.
    int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
    if (secondsUnderAttack < 42)
        return;

    vector location=kbBaseGetLastKnownDamageLocation(cMyID, kbBaseGetMainID(cMyID));
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        if(kbIsPlayerAlly(i) == true)
            if( CanIChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptHelpHere, -1, location);
    }

    //Keep the books
    messageSent=true;
    xsSetRuleMinIntervalSelf(600);
}

//==============================================================================
// IHateSiege
//==============================================================================
rule IHateSiege
minInterval 5
inactive
group HateScripts
{
    int UnitType = cUnitTypeLogicalTypeLandMilitary;
    int Range = 30;
    int UnitToCounter = cUnitTypeAbstractSiegeWeapon;

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if ((kbUnitIsType(unitID, cUnitTypeAbstractSiegeWeapon)) ||
            (kbUnitIsType(unitID, cUnitTypeAbstractArcher)) && (kbUnitIsType(enemyID,cUnitTypeFireLance) != true) ||
            (kbUnitIsType(unitID, cUnitTypeAbstractArcher)) && (kbUnitIsType(enemyID, cUnitTypeFireLanceShennong) != true) ||
            (kbUnitIsType(unitID, cUnitTypeAbstractInfantry)) && (kbUnitIsType(enemyID, cUnitTypeFireLance) == true) ||
            (kbUnitIsType(unitID, cUnitTypeAbstractInfantry)) && (kbUnitIsType(enemyID, cUnitTypeFireLanceShennong) == true) ||
            (kbUnitIsType(unitID, cUnitTypeHero)) || (kbUnitIsType(unitID, cUnitTypeMythUnit)))
            continue;
        int NumBSelf = getNumUnits(cUnitTypeBuilding, cUnitStateAlive, -1, cMyID, unitLoc, 36.0);
        int NumBAllies = getNumUnitsByRel(cUnitTypeBuilding, cUnitStateAlive, -1, cPlayerRelationAlly, unitLoc, 36.0, true);
        int Combined = NumBSelf + NumBAllies;
        if ((enemyID > -1) && (Combined > 0) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// tacticalHeroAttackMyth
//==============================================================================
rule tacticalHeroAttackMyth
minInterval 5
inactive
group HateScripts
{
    int UnitType = cUnitTypeHero;
    if (cMyCulture == cCultureChinese)
        UnitType = cUnitTypeHeroChineseImmortal;
    int Range = 24;
    int UnitToCounter = cUnitTypeMythUnit;
    static bool RunOnlyOnce = false;

    if (cMyCulture == cCultureGreek && RunOnlyOnce == false)
    {
        static int RangedHero = -1;
        if (cMyCiv == cCivZeus)
            RangedHero = cUnitTypeHeroGreekOdysseus;
        else if (cMyCiv == cCivPoseidon)
            RangedHero = cUnitTypeHeroGreekHippolyta;
        else if (cMyCiv == cCivHades)
            RangedHero = cUnitTypeHeroGreekChiron;
        RunOnlyOnce = true;
    }

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        if ((cMyCulture == cCultureAtlantean) && (kbUnitIsType(unitID, cUnitTypeVillagerAtlanteanHero)))
            continue;
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if (cMyCulture != cCultureEgyptian)
        {
            if ((kbUnitIsType(enemyID, cUnitTypeFlyingUnit)) || (kbUnitIsType(enemyID, cUnitTypeEarthDragon)))
            {
                if (cMyCulture == cCultureGreek)
                {
                    if (kbUnitIsType(unitID, RangedHero) == false)
                        continue;
                }
                else if (cMyCulture == cCultureNorse)
                    continue;
                else if (cMyCulture == cCultureAtlantean)
                {
                    if ((kbUnitIsType(unitID, cUnitTypeJavelinCavalryHero) == false ) && (kbUnitIsType(unitID, cUnitTypeArcherAtlanteanHero) == false))
                        continue;
                }
                else if (cMyCulture == cCultureChinese)
                {
                    if (kbUnitIsType(unitID, cUnitTypeHeroChineseMonk))
                        continue;
                }
            }
        }
        if((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// AntiArchSpecial
//==============================================================================
rule AntiArchSpecial
minInterval 5
inactive
group HateScriptsSpecial
{
    int UnitType = cUnitTypeCrossbowman;
    int Range = 25;
    int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;
    if (cMyCulture == cCultureChinese)
    {
        if (cMyCiv == cCivShennong)
            UnitType = cUnitTypeFireLanceShennong;
        else UnitType = cUnitTypeFireLance;
        UnitToCounter = cUnitTypeAbstractArcher;
    }
    else if (cMyCulture == cCultureNorse)
    {
        UnitType = cUnitTypeBogsveigir;
        UnitToCounter = cUnitTypeMythUnit;
    }

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeSettlementsThatTrainVillagers, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if (UnitType == cUnitTypeCrossbowman)
        {
            if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true)
                || (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
                || (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true))
                continue;
        }
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// BanditMigdolRemoval // Valley of Kings special
//==============================================================================
rule BanditMigdolRemoval
minInterval 8
inactive
{
    int UnitType = cUnitTypeLogicalTypeLandMilitary;
    int Range = 20;
    int UnitToCounter = cUnitTypeBanditMigdol;

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, unitLoc, 40.0);
        if ((enemyID > -1) && (NumSelf > 10))
            aiTaskUnitWork(unitID, enemyID);
    }
}

rule AntiInf
minInterval 5
inactive
group HateScripts
{
    int UnitType = -1;
    int Range = 20;
    int UnitToCounter = cUnitTypeAbstractInfantry;

    if (cMyCulture == cCultureGreek)
        UnitType = cUnitTypeToxotes;
    else if (cMyCulture == cCultureEgyptian)
        UnitType = cUnitTypeChariotArcher;
    else if (cMyCulture == cCultureNorse)
    {
        UnitType = cUnitTypeThrowingAxeman;
        Range = 16;
    }
    else if (cMyCulture == cCultureAtlantean)
        UnitType = cUnitTypeArcherAtlantean;
    else if (cMyCulture == cCultureChinese)
        UnitType = cUnitTypeChuKoNu;

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if (cMyCulture != cCultureNorse)
        {
            if ((kbUnitIsType(enemyID, cUnitTypeHuskarl) == true) || (kbUnitIsType(enemyID, cUnitTypeTridentSoldier) == true))
                continue;
        }
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

rule AntiArch
minInterval 5
inactive
group HateScripts
{
    int UnitType = -1;
    int Range = 18;
    int UnitToCounter = cUnitTypeAbstractArcher;

    if (cMyCulture == cCultureGreek)
        UnitType = cUnitTypePeltast;
    else if (cMyCulture == cCultureEgyptian)
        UnitType = cUnitTypeSlinger;
    else if (cMyCulture == cCultureAtlantean)
        UnitType = cUnitTypeJavelinCavalry;

    int UnitsFound = getNumUnits(UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if ((enemyID > -1)&& (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// IHateVillagers
//==============================================================================
rule IHateVillagers  //Monks too
minInterval 5
inactive
group HateScripts
{
    int UnitType = cUnitTypeAbstractArcher;
    int Range = 20;
    int UnitToCounter = cUnitTypeLogicalTypeIdleCivilian;

    int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeHeroChineseMonk, cUnitStateAliveOrBuilding, unitLoc, Range);
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// IHateUnderworldPassages
//==============================================================================
rule IHateUnderworldPassages
minInterval 10
inactive
{
    int UnitType = cUnitTypeLogicalTypeLandMilitary;
    int Range = 20;
    int UnitToCounter = cUnitTypeTunnel;
    int Tunnels = getNumUnitsByRel(UnitToCounter, cUnitStateAlive, -1, cPlayerRelationEnemy);
    int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
    if ((Tunnels < 1) || (UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}

//==============================================================================
// IHateBuildingsBeheAndScarab
//==============================================================================
rule IHateBuildingsMythUnitSiege
minInterval 5
inactive
group Sekhmet
group Rheia
group Hephaestus
group Skadi
group Baldr
group Hel
{
    int UnitType = cUnitTypeMythUnitSiege;
    int Range = 25;
    int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;
    int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);

    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        if (kbUnitIsType(unitID, cUnitTypeAbstractTitan) == true)
            continue;
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeSettlementsThatTrainVillagers, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAlive, unitLoc, Range);
        if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true)
            || (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
            || (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true))
            continue;
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}
//==============================================================================
// MeleeGateAssist
//==============================================================================
rule MeleeGateAssist
minInterval 5
inactive
group HateScripts
{
    int UnitType = cUnitTypeLogicalTypeLandMilitary;
    int Range = 8;
    int UnitToCounter = cUnitTypeGate;

    int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        int Action = kbUnitGetActionType(unitID);
        if ((Action == cActionHandAttack) || (Action == cActionRangedAttack))
            continue;
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAliveOrBuilding, unitLoc, Range);
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}
//==============================================================================
// IHateBuildingsSiege
//==============================================================================
rule IHateBuildingsSiege
minInterval 5
inactive
group HateScripts
{
    int UnitType = cUnitTypeAbstractSiegeWeapon;
    int Range = 34;
    int UnitToCounter = cUnitTypeLogicalTypeBuildingsNotWalls;

    int UnitsFound = kbUnitCount(cMyID, UnitType, cUnitStateAlive);
    if ((UnitsFound < 1) || (UnitType == -1) || (UnitToCounter == -1))
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(UnitType, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeGate, cUnitStateAliveOrBuilding, unitLoc, 10);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeSettlementsThatTrainVillagers, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, UnitToCounter, cUnitStateAliveOrBuilding, unitLoc, Range);
        if (enemyID < 0)
            enemyID = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeGate, cUnitStateAlive, unitLoc, Range);
        if ((kbUnitIsType(enemyID, cUnitTypeSettlement) == true) || (kbUnitIsType(enemyID, cUnitTypeAbstractFarm) == true)
            || (kbUnitIsType(enemyID, cUnitTypeHealingSpringObject) == true) || (kbUnitIsType(enemyID, cUnitTypePlentyVault) == true)
            || (kbUnitIsType(enemyID, cUnitTypeHesperidesTree) == true) || (kbUnitIsType(unitID, cUnitTypeChieroballista)))
            continue;
        if ((enemyID > -1) && (kbUnitIsType(kbUnitGetTargetUnitID(unitID), UnitToCounter) == false))
            aiTaskUnitWork(unitID, enemyID);
    }
}
//==============================================================================
// MonitorAllies
//==============================================================================
rule MonitorAllies
minInterval 1
inactive
{
    xsSetRuleMinIntervalSelf(181);
    static bool BTDT = false;
    bool Success = false;

    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        if (kbIsPlayerMutualAlly(i) == true && kbIsPlayerResigned(i) == false && kbIsPlayerValid(i) == true && kbHasPlayerLost(i) == false)
            Success = true;
        if ((kbIsPlayerHuman(i) == true) && (kbIsPlayerMutualAlly(i) == true))
            HasHumanAlly = true;
    }

    if (Success == true)
    {
        if (BTDT == false)
        {
            xsEnableRuleGroup("Donations");
            xsEnableRule("defendAlliedBase");
            xsEnableRule("Helpme");
            IhaveAllies = true;
            BTDT = true;
        }
    }
    else
    {
        xsDisableRuleGroup("Donations");
        xsDisableRule("defendAlliedBase");
        xsDisableRule("Helpme");
        IhaveAllies = false;
        InfiniteAIAllies = false;
    }
}

// KOTH COMPLEX both Land and Water
//==============================================================================
// ClaimKoth
// @param where: the position of the Vault to claim
// @param baseID: the base to get the units from. If left unspecified, the
//                funct will try to find units
//==============================================================================
void ClaimKoth(vector where=cInvalidVector, int baseToUseID=-1)
{
    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    int BoatToUse=kbUnitCount(cMyID, transportPUID, cUnitStateAlive);

    if (BoatToUse <= 0)
    {
        xsEnableRule("KOTHMonitor");
        DestroyTransportPlan = true;
        return;
    }

    int IdleTransportPlans = aiGetNumberIdlePlans(cPlanTransport);
    if (IdleTransportPlans >= 1)
    {
        DestroyHTransportPlan = true;
        xsEnableRule("KOTHMonitor");
    }

    vector baseLoc = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    int startAreaID = kbAreaGetIDByPosition(baseLoc);
    int ActiveTransportPlans = aiPlanGetNumber(cPlanTransport, -1, true);
    if (ActiveTransportPlans >= 1)
        return;

    if (KoTHOkNow == true)
    {
        int baseID = KOTHBASE;
        KOTHTHomeTransportPlan=createTransportPlan("GO HOME AGAIN", kbAreaGetIDByPosition(where), startAreaID, false, transportPUID, 97, baseID);
        aiPlanAddUnitType(KOTHTHomeTransportPlan, cUnitTypeHumanSoldier, 3, 6, 10);
        KoTHOkNow = false;
        return;
    }
    else
    {
        KOTHTransportPlan=createTransportPlan("TRANSPORT TO KOTH VAULT", startAreaID, kbAreaGetIDByPosition(where), false, transportPUID, 80, baseID);
        if (kbGetTechStatus(cTechEnclosedDeck) == cTechStatusActive)
            aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 10, 20, 20);
        else aiPlanAddUnitType(KOTHTransportPlan, cUnitTypeHumanSoldier, 5, 10, 10);
    }
}

//==============================================================================
rule getKingOfTheHillVault
        minInterval 10
inactive
{
    static bool LandActive = false;
    bool LandNeedReCalculation = false;
    xsSetRuleMinIntervalSelf(22+aiRandInt(12));
    int NumEnemy = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, KOTHGlobal, 4.0, true);
    int NumSelf = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, KOTHGlobal, 60.0);

    int numAvailableUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    if (KoTHWaterVersion == true)
        numAvailableUnits = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    if ((numAvailableUnits < 5) || (kbGetAge() < cAge2) || (numAvailableUnits < 10) && (xsGetTime() > 14*60*1000))
        return;

    if (KoTHWaterVersion == false)
    {
        if (NumEnemy+15 > NumSelf)
            LandNeedReCalculation = true;

        if (LandNeedReCalculation == true)
        {
            if (LandActive == false)
            {
                gDefendPlentyVault = createDefOrAttackPlan("KOTH VAULT DEFEND", true, 30, 12, KOTHGlobal, -1, 70, false);
                aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
                aiPlanSetInitialPosition(gDefendPlentyVault, KOTHGlobal);
                aiPlanSetActive(gDefendPlentyVault);
                KothDefPlanActive = true;
                LandActive = true; // active, will add more units below.
            }
            aiPlanSetNoMoreUnits(gDefendPlentyVault, false);
            aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeLogicalTypeLandMilitary, numAvailableUnits * 0.8, numAvailableUnits * 0.85, numAvailableUnits * 0.9); // Most mil units.
            KOTHStopRefill = true;
            xsEnableRule("KOTHMonitor");
        }
    }

    else if (KoTHWaterVersion == true)
    {
        if ((KothDefPlanActive == false) && (NumSelf >= 1))
        {
            gDefendPlentyVault = createDefOrAttackPlan("KOTH WATER VAULT DEFEND", true, 30, 12, KOTHGlobal, KOTHBASE, 70, false);
            aiPlanAddUnitType(gDefendPlentyVault, cUnitTypeHumanSoldier, 0, 0, 200);
            aiPlanSetInitialPosition(gDefendPlentyVault, KOTHGlobal);
            aiPlanSetActive(gDefendPlentyVault);
            xsEnableRule("getEnclosedDeck");
            KothDefPlanActive = true;
        }

        if (NumEnemy+14 > NumSelf)
        {
            LandNeedReCalculation = false;
            ClaimKoth(KOTHGlobal);
            return;
        }
        else if (NumSelf >  NumEnemy + 14)
            SendBackCount = SendBackCount+1;

        if (SendBackCount > 6)
        {
            KoTHOkNow = true;
            ClaimKoth(KOTHGlobal);
            SendBackCount = 0;
        }
    }
}

//==============================================================================
rule KOTHMonitor
minInterval 2
inactive
{
    xsSetRuleMinIntervalSelf(2);

    if (KOTHStopRefill == true)
    {
        xsSetRuleMinIntervalSelf(5); // give some extra time to fetch units.
        aiPlanSetNoMoreUnits(gDefendPlentyVault, true);
        xsDisableSelf();
        KOTHStopRefill = false;
        return;
    }

    if ((DestroyTransportPlan == true) || (DestroyHTransportPlan == true))
    {
        int TransportToKOTHID = findPlanByString("TRANSPORT TO KOTH VAULT", cPlanTransport, -1);
        int GoHomeID = findPlanByString("GO HOME AGAIN", cPlanTransport, -1);
        if (TransportToKOTHID != -1)
            aiPlanDestroy(TransportToKOTHID);
        if (GoHomeID != -1)
            aiPlanDestroy(GoHomeID);
        DestroyTransportPlan = false;
        DestroyHTransportPlan = false;
    }
    xsDisableSelf();
}
// KOTH COMPLEX END
//==============================================================================

//==============================================================================
rule RemoveBadWalls
minInterval 20
group WallCleanup
inactive
{
    bool Success = false;
    xsSetRuleMinIntervalSelf(12);
    int UnitsFound = kbUnitCount(cMyID, cUnitTypeGate, cUnitStateAlive);
    if (UnitsFound < 1)
        return;

    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(cUnitTypeGate, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        for (k=0; < 4)
        {
            int unitTypeID=cUnitTypeWallConnector;
            if (k==1)
                unitTypeID=cUnitTypeWallMedium;
            else if (k==2)
                unitTypeID=cUnitTypeWallShort;
            else if (k==3)
                unitTypeID=cUnitTypeWallLong;
            int BadWalls = getNumUnits(unitTypeID, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 4);
            for (j=0; < BadWalls)
            {
                int WallPiece = findUnit(unitTypeID, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 4);
                if (WallPiece != -1)
                {
                    aiTaskUnitDelete(WallPiece);
                    Success = true;
                }
            }
        }
    }
    if (Success == true)
        xsSetRuleMinIntervalSelf(2);
}

//==============================================================================
rule RemoveTooCloseDocks
minInterval 6
inactive
{
    int unitTypeID = cUnitTypeDock;
    int UnitsFound = kbUnitCount(cMyID, unitTypeID, cUnitStateAlive);
    if (UnitsFound < 1)
        return;
    for (i=0; < UnitsFound)
    {
        int unitID = findUnitByIndex(unitTypeID, i, cUnitStateAlive);
        vector unitLoc = kbUnitGetPosition(unitID);
        int BadDocks = kbUnitCount(cMyID, unitTypeID, cUnitStateBuilding);
        for (j=0; < BadDocks)
        {
            int BadDock = findUnit(unitTypeID, cUnitStateBuilding, -1, cMyID, unitLoc, 15);
            if (BadDock != unitID)
            {
                aiTaskUnitDelete(BadDock);
            }
        }
    }
}
//==============================================================================
rule TransportBuggedUnits
minInterval 14
group BuggedTransport
inactive
{
    static int TransportAttPlanID = -1;
    int IdleMil = aiNumberUnassignedUnits(cUnitTypeLogicalTypeLandMilitary);
    static int attackPlanStartTime = -1;
    static int targetSettlementID = -1;
    int AttackPlayer = aiGetMostHatedPlayerID();
    xsSetRuleMinIntervalSelf(30);
    static vector attPlanPosition = cInvalidVector;
    bool Filled = false;

    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true); // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            if (attackPlanID == TransportAttPlanID)
            {
                int planState = aiPlanGetState(TransportAttPlanID);
                int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
                attPlanPosition = aiPlanGetLocation(TransportAttPlanID);
                int numMilUnitsNearAttPlan = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, attPlanPosition);
                int numInPlan = aiPlanGetNumberUnits(TransportAttPlanID, cUnitTypeLogicalTypeLandMilitary);
                int numTransport = kbUnitCount(cMyID, transportPUID, cUnitStateAlive);
                if (numMilUnitsNearAttPlan >= 20)
                    numMilUnitsNearAttPlan = 20;
                if (numInPlan > 1)
                    Filled = true;


                if (Filled == false)
                {
                    aiPlanSetInitialPosition(TransportAttPlanID, attPlanPosition);
                    aiPlanAddUnitType(TransportAttPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, numMilUnitsNearAttPlan);
                    aiPlanSetVariableFloat(TransportAttPlanID, cAttackPlanGatherDistance, 0, 500.0);
                }

                if ((numInPlan < 1) || (xsGetTime() > attackPlanStartTime + 30*60*1000) || (planState == cPlanStateNone) && (xsGetTime() > attackPlanStartTime + 5*60*1000) ||
                    (planState == cPlanStateGather) && (xsGetTime() > attackPlanStartTime + 5*60*1000)
                    || ((aiPlanGetState(attackPlanID) == cPlanStateTransport) && (numTransport < 1)(aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)))
                {
                    aiPlanDestroy(TransportAttPlanID);
                    xsSetRuleMinIntervalSelf(5);
                }
                return;
            }
        }
    }
    if (IdleMil < 3)
        return;

    TransportAttPlanID = aiPlanCreate("Transport bugged units", cPlanAttack);
    if (TransportAttPlanID < 0)
        return;

    TransportAttPlanID = TransportAttPlanID;
    targetSettlementID = getMainBaseUnitIDForPlayer(AttackPlayer);
    if (targetSettlementID == -1)
        targetSettlementID = findUnit(cUnitTypeUnit, cUnitStateAlive, -1, AttackPlayer);
    vector targetSettlementPos = kbUnitGetPosition(targetSettlementID); // uses main TC
    vector RandUnit = kbUnitGetPosition(findUnit(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, AttackPlayer));
    vector RandBuilding = kbUnitGetPosition(findUnit(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, AttackPlayer));
    vector RandVillager = kbUnitGetPosition(findUnit(cUnitTypeAbstractVillager, cUnitStateAlive, -1, AttackPlayer));
    attPlanPosition = aiPlanGetLocation(TransportAttPlanID);
    aiPlanSetNumberVariableValues(TransportAttPlanID, cAttackPlanTargetAreaGroups, 5, true);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(attPlanPosition));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetSettlementPos));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 2, kbAreaGroupGetIDByPosition(RandUnit));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 3, kbAreaGroupGetIDByPosition(RandBuilding));
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetAreaGroups, 4, kbAreaGroupGetIDByPosition(RandVillager));
    aiPlanAddUnitType(TransportAttPlanID, cUnitTypeHumanSoldier, 0, 0, 1);


    aiPlanSetInitialPosition(TransportAttPlanID, attPlanPosition);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    aiPlanSetUnitStance(TransportAttPlanID, cUnitStanceDefensive);
    aiPlanSetDesiredPriority(TransportAttPlanID, 1);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanPlayerID, 0, AttackPlayer);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    aiPlanSetNumberVariableValues(TransportAttPlanID, cAttackPlanTargetTypeID, 4, true);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeUnit);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeBuilding);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeAbstractTradeUnit);
    aiPlanSetVariableInt(TransportAttPlanID, cAttackPlanRefreshFrequency, 0, 12);
    aiPlanSetVariableFloat(TransportAttPlanID, cAttackPlanGatherDistance, 0, 50.0);

    aiPlanSetActive(TransportAttPlanID);
    attackPlanStartTime = xsGetTime();

    xsSetRuleMinIntervalSelf(5);
}

//==============================================================================
rule TransportShipMonitor
minInterval 30
group BuggedTransport
inactive
{
    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    int TransAlive = kbUnitCount(cMyID, transportPUID, cUnitStateAlive);
    int Docks = kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAlive);

    if ((TransAlive > 0) || (Docks < 1))
        return;

    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    int TransInProgress = kbUnitCount(cMyID, transportPUID, cUnitStateBuilding);
    if ((currentPop >= currentPopCap - 3) && (currentPopCap > 100) && (TransInProgress > 0))
    {
        int PlanToUse = findPlanByString("landAttackPlan", cPlanAttack);
        int KillCounter = 0;
        if (PlanToUse == -1)
            PlanToUse = findPlanByString("enemy settlement attack plan", cPlanAttack);
        bool Success = false;
        if ((PlanToUse != -1) && (aiPlanGetState(PlanToUse) == cPlanStateTransport))
        {
            for (i = 0; < kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive))
            {
                int UnitToKill = findUnitByIndex(cUnitTypeHumanSoldier, i, cUnitStateAlive, -1, cMyID);
                if ((aiPlanGetState(kbUnitGetPlanID(UnitToKill)) <=0) || (UnitToKill == -1))
                    continue;
                aiTaskUnitDelete(UnitToKill);
                KillCounter = KillCounter + 1;
                //aiEcho("Using method 1 ");
                Success = true;
                if (KillCounter >= 2)
                    break;
            }
        }
        if (Success == false)
        {
            for (i = 0; < kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive))
            {
                UnitToKill = findUnitByIndex(cUnitTypeHumanSoldier, i, cUnitStateAlive, cActionIdle, cMyID);
                if (UnitToKill == -1)
                    continue;
                aiTaskUnitDelete(UnitToKill);
                //aiEcho("Using method 2 ");
                KillCounter = KillCounter + 1;
                if (KillCounter >= 2)
                    break;
            }
        }
    }
    else if ((currentPop >= currentPopCap - 3) && (currentPopCap > 100) && (TransInProgress < 1) && (kbResourceGet(cResourceWood) > 250))
        aiTaskUnitTrain(findUnit(cUnitTypeDock), transportPUID);
}

//==============================================================================
rule LaunchAttacks
minInterval 12
inactive
{
    if (ShouldIAgeUp() == true) {
        echo("LaunchAttacks: skipping because I should age up");
        return;
    }
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    vector defPlanDefPoint = aiPlanGetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0);
    int numEnemyMilUnitsNearDefPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 90.0, true);
    int LandAActive = findPlanByString("landAttackPlan", cPlanAttack);
    int RaidingAActive = findPlanByString("Raiding Party", cPlanAttack);
    int SettlementAActive = findPlanByString("enemy settlement attack plan", cPlanAttack);

    if ((numEnemyTitansNearMBInR85 > 0) ||
        (numEnemyMilUnitsNearMBInR80 > 10) ||
        (numEnemyMilUnitsNearDefPlan > 10))
    {
        echo("LaunchAttacks: skipping because enemies are near main base");
        return;
    }

    if((LandAActive > 0) && (SettlementAActive > 0) && (RaidingAActive > 0))
    {
        echo("LaunchAttacks: skipping because there are already land, raiding, and settlement attack plans");
        return;
    }

    if ((kbGetAge() == cAge2) && (LandAActive > 0 || xsGetTime() >= 15*60*1000))
    {
        echo("LaunchAttacks: skipping because it's age 2 and we have a land attack plan, or it's too late (15m+)");
        return;
    }

    if (ReadyToAttack() == true)
    {
        echo("LaunchAttacks: ready to attack, enabling attack rules");
        if ((LandAActive > 0) && (SettlementAActive > 0))
        {
            xsSetRuleMinInterval("createRaidingParty", 2);
            xsEnableRule("createRaidingParty");
        }
        else if ((LandAActive < 0) && (SettlementAActive != -1) || (kbGetAge() == cAge2))
        {
            xsSetRuleMinInterval("createLandAttack", 2);
            xsEnableRule("createLandAttack");
        }
        else if ((SettlementAActive < 0) && (LandAActive != -1))
        {
            xsSetRuleMinInterval("attackEnemySettlement", 2);
            xsEnableRule("attackEnemySettlement");
        }
        else
        {
            if (aiRandInt(3) == 0)
            {
                xsSetRuleMinInterval("attackEnemySettlement", 2);
                xsEnableRule("attackEnemySettlement");
            }
            else
            {
                xsSetRuleMinInterval("createLandAttack", 2);
                xsEnableRule("createLandAttack");
            }
        }
    }
}

//==============================================================================
rule Maintenance
minInterval 2
inactive
group reth
{
    // Self Destruct Plans
    static int LastRun = -1;
    if (LastRun == -1)
        LastRun = xsGetTime();

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    bool SwitchType = false;
    int PlanType = cPlanBuild;
    for (j = 0; < 2)
    {
        if (SwitchType == true)
            PlanType = cPlanTrain;
        SwitchType = true;
        int ActivePlans = aiPlanGetNumber(PlanType, -1, true);
        if (ActivePlans > 0)
        {
            for (i = 0; < ActivePlans)
            {
                int PlanID = aiPlanGetIDByIndex(PlanType, -1, true, i);
                if (PlanID == -1)
                    continue;
                int NumVar = aiPlanGetNumberUserVariableValues(PlanID, 0);
                if (NumVar == 2)
                {
                    int SpecialNum = aiPlanGetUserVariableInt(PlanID, 0, 0);
                    int TimeActive = aiPlanGetUserVariableInt(PlanID, 0, 1);
                    if ((SpecialNum == 150) && (xsGetTime() > TimeActive))
                    {
                        aiPlanDestroy(PlanID);
                        int Overdue = xsGetTime()/1000-(TimeActive/1000);
                        if (ShowAIDebug == true) aiEcho("Destroyed plan, it was active for too long ID: "+PlanID+"  Overdue by seconds: "+Overdue+"");
                    }
                }
            }
        }
    }
    //Farm Patcher & Idle Villagers
    if ((aiGetWorldDifficulty() >= cDifficultyHard) && (aiGetGameMode() != cGameModeLightning) && (cvMapSubType != VINLANDSAGAMAP))
    {
        for (i = 0; < aiPlanGetNumber(cPlanFarm))
        {
            int FarmPlanID = aiPlanGetIDByIndex(cPlanFarm, -1, true, i);
            if (FarmPlanID == -1)
                continue;
            if (aiPlanGetBaseID(FarmPlanID) == gFarmBaseID)
            {
                vector InitialPos = aiPlanGetInitialPosition(FarmPlanID);
                int CurrentID = aiPlanGetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0);
                if ((kbUnitIsType(CurrentID, cUnitTypeAbstractSettlement) != true) && (CurrentID != -1) && (equal(InitialPos, kbBaseGetLocation(cMyID, mainBaseID)) == true))
                {
                    int TC = getMainBaseUnitIDForPlayer(cMyID);
                    if (TC != -1)
                    {
                        aiPlanSetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0, TC);
                        aiPlanSetVariableVector(FarmPlanID, cFarmPlanFarmingPosition, 0, InitialPos);
                    }
                }
            }
        }
    }
    int IdleVillagers = getNumUnits(cUnitTypeAbstractVillager, cUnitStateAlive, cActionIdle, cMyID);
    for (v = 0; < IdleVillagers)
    {
        int Villager = findUnitByIndex(cUnitTypeAbstractVillager, v, cUnitStateAlive, cActionIdle, cMyID);
        int Food = findUnit(cUnitTypeFarm, cUnitStateAlive, -1, cMyID, kbUnitGetPosition(Villager), 40);
        if ((Villager != -1) && (Food != -1))
            aiTaskUnitWork(Villager, Food);
    }
    //Crashed plans
    if ((aiGetGameMode() != cGameModeDeathmatch) && (xsGetTime() >= LastRun+ 1*45*1000))
    {
        if ((kbResourceGet(cResourceFood) > 200) && (kbResourceGet(cResourceWood) > 200) && (kbResourceGet(cResourceGold) > 200))
        {
            LastRun = xsGetTime();
            bool cSwitchType = false;
            int cPlanType = cPlanResearch;
            for (j = 0; < 2)
            {
                if (cSwitchType == true)
                    cPlanType = cPlanProgression;
                cSwitchType = true;
                int PlanToUse = -1;
                bool PlanCrashed = false;
                bool Progression = false;
                int cActivePlans = aiPlanGetNumber(cPlanType, -1, true);
                if (cActivePlans > 0)
                {
                    for (i = 0; < cActivePlans)
                    {
                        int cPlanID = aiPlanGetIDByIndex(cPlanType, -1, true, i);
                        if ((cPlanID == -1) || (kbGetTechStatus(cPlanID) >= cTechStatusResearching))
                            continue;
                        int cNumVar = aiPlanGetNumberUserVariableValues(cPlanID, 0);
                        if (cNumVar == 3)
                        {
                            int cSpecialNum = aiPlanGetUserVariableInt(cPlanID, 0, 0);
                            int cTimeActive = aiPlanGetUserVariableInt(cPlanID, 0, 1);
                            if ((cSpecialNum == 19) && (xsGetTime() > cTimeActive + 6*60*1000))
                            {
                                PlanCrashed = true;
                                PlanToUse = cPlanID;
                                if (cPlanType == cPlanProgression)
                                    Progression = true;
                                break;
                            }
                        }
                    }
                    if ((PlanCrashed == true) && (PlanToUse != -1))
                    {
                        int Tech = aiPlanGetUserVariableInt(PlanToUse, 0, 2);
                        int BuildingID = aiPlanGetVariableInt(PlanToUse, cResearchPlanBuildingTypeID, 0);
                        int EscrowID = aiPlanGetEscrowID(PlanToUse);
                        int Prio = aiPlanGetActualPriority(PlanToUse);
                        int IdleTime = (xsGetTime() - cTimeActive) / 1000;
                        if (ShowAIDebug == true) aiEcho("Plan to research (" + kbGetTechName(Tech) + ") appears to have crashed, idle time: "+IdleTime +" seconds.. restarting the plan!");
                        aiPlanDestroy(PlanToUse);
                        if (Tech != -1)
                            createSimpleResearchPlan(Tech, BuildingID, EscrowID, Prio, Progression, true);
                    }
                }
            }
        }
    }
    //Water stuff
    if (gFishPlanID != -1)
    {
        int Ship = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
        int IdleFishingShips = getNumUnits(Ship, cUnitStateAlive, cActionIdle, cMyID);
        int FishingShips = getNumUnits(Ship, cUnitStateAlive, -1, cMyID);
        int Training = aiPlanGetVariableInt(gFishPlanID, cFishPlanNumberInTraining, 0);

        if ((kbResourceGet(cResourceWood) < 125) || (IdleFishingShips >= 1)
            || (gNavalAttackGoalID != -1) && (kbGetAge() >= cAge2) && (aiGetWorldDifficulty() > cDifficultyModerate) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) < 2)
            || (kbGetAge() == cAge1) && (FishingShips >= 4) && (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding) < 1) && (cMyCulture != cCultureEgyptian))
        {
            aiPlanSetVariableBool(gFishPlanID, cFishPlanAutoTrainBoats, 0, false);
        }
        else aiPlanSetVariableBool(gFishPlanID, cFishPlanAutoTrainBoats, 0, true);
    }
    if (gMaintainWaterXPortPlanID != -1)
    {
        if ((gNavalAttackGoalID != -1) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) < 1))
            aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 0);
        else
            aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);
    }
    //Norse Transform
    if (cMyCulture == cCultureNorse)
    {
        if (kbUnitIsType(StuckTransformID, cUnitTypeUlfsark))
        {
            vector currentPosition = kbUnitGetPosition(StuckTransformID);
            aiUnitCreateCheat(cMyID, cUnitTypeUlfsark, currentPosition, "Replacing Stuck Ulfsark", 1);
            aiTaskUnitDelete(StuckTransformID);
        }
        StuckTransformID = 0;
    }
}
//==============================================================================
//Testing ground
rule TEST
minInterval 1
inactive
{
}
