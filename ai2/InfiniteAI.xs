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
//The first part of this file is just a long list of global variables.  The
//'extern' keyword allows them to be used in any of the included files.  These
//are here to facilitate information sharing, etc.  The global variables are
//attempted to be named appropriately, but you should take a look at how they are
//used before making any assumptions about their actual utility.

//==============================================================================
//Map-Related Globals.
extern bool gWaterMap=false;              // Set true if fishing is likely to be good.
extern bool gTransportMap=false;          // Set true if transports are needed or very useful, i.e. island and shallow-chokepoint maps.

//==============================================================================
//Housing & PopCap.
extern int gHouseBuildLimit=-1;
extern int gHouseAvailablePopRebuild=10;     // Build a house when pop is within this amount of the current pop limit
extern int gHardEconomyPopCap=-1;            // Sets an absolute upper limit on the number of villagers maintained in the updateEM rules
extern int gEarlySettlementTarget = 3;       // How many age 1/2 settlements do we want?

//==============================================================================
//Econ Globals.
extern int gGatherGoalPlanID=-1;
extern int gCivPopPlanID=-1;
extern int gNumBoatsToMaintain=6;         // Target number of fishing boats
extern bool gFarming=false;               // Set true when a farming plan is created, used to forecast farm resource needs.
extern bool gFishing=false;               // Set true when a fishing plan is created, used to forecast fish boat wood demand
extern float gGoldForecast = 0.0;         // Forecasted demand over the next few minutes
extern float gWoodForecast = 0.0;
extern float gFoodForecast = 0.0;
extern int gHerdPlanID = -1;              // Herds animals to base
extern float gGlutRatio = 0.0;            // 1.0 indicates all resources at 3 min forecast.  2.0 means all at least double.  Used to trim econ pop.
extern float gFoodGlutRatio = 0;
extern float gWoodGlutRatio = 0;
extern float gGoldGlutRatio = 0;
extern int gLastAgeHandled = cAge1;       // Set to cAge2..cAge5 as the age handlers run. Used to detect age-ups granted via triggers and starting conditions,


// Trade globals
extern int gMaxTradeCarts = 22;           // Max trade carts
extern int gTradePlanID = -1;
extern bool gExtraMarket = false;         // Used to indicate if an extra (non-trade) market has been requested
extern int gTradeMarketUnitID = -1;       // Used to identify the market being used in our trade plan.
extern vector gTradeMarketLocation = cInvalidVector; // location of our trade market
extern vector gTradeMarketDesiredLocation = cInvalidVector; // location, where we want to build our trade market.
extern int gExtraMarketUnitID = -1;       // Used to identify the extra market
extern bool gResetTradeMarket = false;


//==============================================================================
//Military Globals.
extern bool gBuildWalls = true;
extern int gWallPlanID = -1;
extern int gRushUPID=-1;            // Unit picker ID for age 2 (cAge2) armies.
extern int gLateUPID=-1;            // Unit picker for age 3/4 (cAge3 and cAge4).
extern int gNavalUPID=-1;
extern int gNumberBuildings=3;      // Number of buildings requested for late unit picker
extern int gNavalAttackGoalID=-1;
extern int gRushGoalID=-1;
extern int gLandAttackGoalID=-1;
extern int gIdleAttackGID=-1;       // Attack goal, inactive, used to maintain mil pop after rush and/or before age 3 (cAge3) attack.
extern int gDefendPlanID = -1;      // Uses military units to defend main base while waiting to mass an attack army
extern int gWonderDefendPlan = -1;     // Uber-plan to defend my wonder
extern int gEnemyWonderDefendPlan = -1;   // Uber-uber-plan to attack or defend other wonder
extern int gObeliskClearingPlanID = -1;   // Small attack plan used to remove enemy obelisks
extern int gTargetNavySize = 0;     // Set periodically based on difficulty, enemy navy/fish boat count. Units, not pop slots.

//==============================================================================
//Minor Gods.
extern int gAge2MinorGod = -1;
extern int gAge3MinorGod = -1;
extern int gAge4MinorGod = -1;

//==============================================================================
//God Powers
extern int gAge1GodPowerID = -1;
extern int gAge2GodPowerID = -1;
extern int gAge3GodPowerID = -1;
extern int gAge4GodPowerID = -1;
extern int gAge5GodPowerID = -1;
extern int gAge1GodPowerPlanID = -1;
extern int gAge2GodPowerPlanID = -1;
extern int gAge3GodPowerPlanID = -1;
extern int gAge4GodPowerPlanID = -1;
extern int gAge5GodPowerPlanID = -1;
extern int gTownDefenseGodPowerPlanID = -1;
extern int gTownDefenseEvalModel = -1;
extern int gTownDefensePlayerID = -1;
extern int gTownDefenseTargetingModel = -1;
extern vector gTownDefenseLocation = cInvalidVector;

extern int gUnbuildPlanID = -1;
extern int gPlaceTitanGatePlanID = -1;

extern int gCeaseFirePlanID=-1;
extern int gSentinelPlanID=-1;
extern int gDwarvenMinePlanID = -1;
extern int gRagnorokPlanID = -1;
extern int gHeavyGPTechID = -1;
extern int gHeavyGPPlanID = -1;
extern int gGaiaForestPlanID = -1;
extern int gHesperidesPlanID = -1;


//==============================================================================
//Special Case Stuff
extern int gLandScout = -1;
extern int gAirScout = -1;
extern int gWaterScout = -1;

extern int gMaintainNumberLandScouts = 1;
extern int gMaintainNumberAirScouts = 1;
extern int gMaintainNumberWaterScouts = 1;

extern int gEmpowerPlanID = -1;
//Ra
extern int eOsiris = -1;
extern int Pempowermarket = -1;
extern int APlanID = -1;
extern int BPlanID = -1;
extern int CPlanID = -1;
//Ra end
extern int gRelicGatherPlanID = -1;
extern int gMaintainWaterXPortPlanID=-1;
extern int gResignType = -1;
extern int gVinlandsagaTransportExplorePlanID=-1;
extern int gVinlandsagaInitialBaseID=-1;
extern int gNomadExplorePlanID1=-1;
extern int gNomadExplorePlanID2=-1;
extern int gNomadExplorePlanID3=-1;
extern int gNomadSettlementBuildPlanID=-1;
extern int gKOTHPlentyUnitID=-1;
extern int gLandExplorePlanID=-1;
extern int gFarmBaseID = -1;
extern int gUlfsarkMaintainPlanID = -1;   // Used to maintain a small pop of ulfsarks for building

//New globals
extern int gGatherRelicType = -1;

extern bool gBuildWallsAtMainBase = true;

extern vector gBackAreaLocation = cInvalidVector;
extern vector gHouseAreaLocation = cInvalidVector;
extern int gBackAreaID = -1;
extern int gHouseAreaID = -1;
extern bool gResetWallPlans = false;

extern float gMainBaseAreaWallRadius = 45;

extern int gMainBaseAreaWallTeam1PlanID = -1;
extern int gMainBaseAreaWallTeam2PlanID = -1;

extern int gOtherBaseRingWallTeam1PlanID = -1;
extern float gOtherBaseWallRadius = 21.0;

extern int gBuildBuilding1AtOtherBasePlanID = -1;

extern int gMBDefPlan1ID = -1;
extern int gOtherBase1ID = -1;                  // globals for defend plans for other bases
extern int gOtherBase2ID = -1;
extern int gOtherBase3ID = -1;
extern int gOtherBase4ID = -1;
extern int gOtherBase1UnitID = -1;
extern int gOtherBase2UnitID = -1;
extern int gOtherBase3UnitID = -1;
extern int gOtherBase4UnitID = -1;
extern int gOtherBase1DefPlanID = -1;
extern int gOtherBase2DefPlanID = -1;
extern int gOtherBase3DefPlanID = -1;
extern int gOtherBase4DefPlanID = -1;
extern int gOtherBase1RingWallTeamPlanID = -1;
extern int gOtherBase2RingWallTeamPlanID = -1;
extern int gOtherBase3RingWallTeamPlanID = -1;
extern int gOtherBase4RingWallTeamPlanID = -1;

extern int gHero1MaintainPlan = -1;
extern int gHero2MaintainPlan = -1;
extern int gHero3MaintainPlan = -1;
extern int gHero4MaintainPlan = -1;

extern int gEnemySettlementAttPlanID = -1;
extern int gEnemySettlementAttPlanTargetUnitID = -1;
extern vector gEnemySettlementAttPlanLastAttPoint = cInvalidVector;
extern vector gSettlementPosDefPlanDefPoint = cInvalidVector;
extern int gSettlementPosDefPlanID = -1;

extern int gRaidingPartyAttackID = -1;
extern int gRaidingPartyTargetUnitID = -1;
extern vector gRaidingPartyLastTargetLocation = cInvalidVector;
extern vector gRaidingPartyLastMarketLocation = cInvalidVector;

extern int gRushCount = 0;
extern int gNumRushAttacks = 0;
extern int gRushSize = 0;
extern int gFirstRushSize = 0;
extern int gRushAttackCount = 0;
extern int gLandAttackPlanID = -1;

extern int gDockBaseID = -1;
extern int gWaterExploreID = -1;
extern int gFishPlanID = -1;

extern int gResearchGranaryID = -1;

extern int gAirScout1PlanID = -1;
extern int gAirScout2PlanID = -1;

extern vector gBaseUnderAttackLocation = cInvalidVector;
extern int gBaseUnderAttackID = -1;
extern int gBaseUnderAttackDefPlanID = -1;

extern bool gHuntersExist = false;

extern int gAlliedBaseDefPlanID = -1;
//New globals end

//==============================================================================
//Base Globals.
extern int gGoldBaseID=-1;          // Base used for gathering gold, although main base is used if gold exists there
extern int gWoodBaseID=-1;          // Ditto for wood
extern float gMaximumBaseResourceDistance = 85.0;

//==============================================================================
//Age Progression Plan IDs.
extern int gAge2ProgressionPlanID = -1;
extern int gAge3ProgressionPlanID = -1;
extern int gAge4ProgressionPlanID = -1;

//==============================================================================
//Forward declarations.
mutable void setParameters(void) {
}                                         // Used in loader file to set control parameters, called at start of main()
mutable void setMilitaryUnitPrefs(int primaryType = -1, int secondaryType = -1, int tertiaryType = -1) {
}                                                                                                           // Used by loader to override unitPicker choices
mutable void age2Handler(int age=1) {
}
mutable void age3Handler(int age=2) {
}
mutable void age4Handler(int age=3) {
}
mutable int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1) {
}
mutable bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
                                   bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1) {
}
mutable void buildHandler(int protoID=-1) {
}
mutable void gpHandler(int powerID=-1)    {
}
mutable int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1,
                                      int builderUnitTypeID=-1, bool autoUpdate=true, int pri=100) {
}
mutable int getSoftPopCap(void) {
}
mutable void unbuildHandler() {
}
mutable void age5Handler(int age=4) {
}
mutable int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
                                bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1) {
}
mutable int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
                                   int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
                                   int baseID=-1, bool allowRetreat=false) {
}
mutable bool mapPreventsHousesAtTowers()    {
}
mutable void updateGlutRatio(void) {
}

//TODO: Check if they are really necessary!
mutable void findTownDefenseGP(int baseID=-1) {
}
mutable void releaseTownDefenseGP() {
}
mutable bool mapRestrictsMarketAttack() {
}
mutable void pullBackUnits(int planID = -1, vector retreatPosition = cInvalidVector) {
}

// Reth Placeholder for Int's etc
extern bool ShowAIDebug = true;
extern int KOTHTransportPlan = -1;
extern int KOTHTHomeTransportPlan = -1;
extern int SendBackCount = 0;
extern bool KoTHOkNow = false;
extern bool DestroyTransportPlan = false;
extern bool DestroyHTransportPlan = false;
extern int rExploreIsland = -1;
extern int MyFortress = cUnitTypeAbstractFortress;
extern int cBuilderType = cUnitTypeAbstractVillager;

extern int cNumResourceTypes = 3;
extern int fCitadelPlanID = -1;
extern bool AutoDetectMap = false;
extern bool NeedTransportCheck = false;
extern int gShiftingSandPlanID= -1;
mutable void wonderDeathHandler(int playerID=-1) {
}
extern bool gHuntingDogsASAP = false;     // Will automatically be called upon if there is hunt nearby the MB.
extern bool RiverSLowBoar = false;
extern bool RetardedLowBoarSpawn = false;
extern bool gpDelayMigration = false;
extern int gGardenBuildLimit = 0;
extern int wonderBPID = -1;
extern bool IsRunHuntingDogs = false;
extern int gDefendPlentyVault = -1;
extern int gHeavyGPTech=-1;
extern int gHeavyGPPlan=-1;
extern int gDefendPlentyVaultWater=-1;
extern int WallAllyPlanID=-1;
extern int FailedToTrain = 0;
extern int defWantedCaravans = 20;
extern int MedicMaintain = -1;
extern bool KOTHStopRefill = false;
extern vector KOTHGlobal = cInvalidVector;
extern bool IhaveAllies = false;
extern bool mRusher = false;
extern bool BeenmRusher = false;
extern int MoreFarms = 26;
extern bool TitanAvailable = false;
extern bool KoTHWaterVersion = false;
extern int KOTHBASE = -1;
extern bool KothDefPlanActive = false;
extern bool WaitForDock = false;
extern int mChineseImmortal = -1;
extern int eChineseHero = -1;
extern int cMonkMaintain = -1;
extern int CataMaintain = -1;
extern int StuckTransformID = 0;
extern int ResourceBaseID = -1;
extern bool HasHumanAlly = false;
extern int gExaminationID = -1;
extern int MigrationAreaID = -1;
extern int HealDefPlan = -1;
extern int gSomeData = -1;
extern bool InfiniteAIAllies = false;
extern const int Tellothers = 30;
extern const int admiralTellothers = 31;
extern const int AttackTarget = 35;
extern const int cAttackTC = 36;
extern int aEnemyTCID = -1;
extern int aLastTCIDTime = 0;
extern const int cEmergency = 38;
extern const int cLowPriority = 39;
extern const int VectorData = 40;
extern bool ChangeMHP = false;
extern int MHPTime = 0;
extern const int INeedHelp = 32;
extern int HelpSettleID = -1;
extern const int Yes = 60;
extern const int No = 61;
extern int gLastSentTime = 0;
extern const int RequestFood = 70;
extern const int RequestWood = 71;
extern const int RequestGold = 72;
extern const int ExtraFood = 73;
extern const int ExtraWood = 74;
extern const int ExtraGold = 75;
extern const int RequestTower = 76;
extern const int EcoPercentage = 80;
extern const int MilPercentage = 81;
extern const int RootPercentage = 82;
extern const int LandAttackTarget = 85;
extern const int SettlementAttackTarget = 86;
extern const int MainUnit = 87;
extern const int SecondaryUnit = 88;
extern const int ThirdUnit = 89;
extern const int PlayersData = 100;


//==============================================================================
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
rule checkEscrow    //Verify that escrow totals and real inventory are in sync
minInterval 6 //starts in cAge1
active
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
                echo("Flushing wood and gold escrow");
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


//==============================================================================
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

//==============================================================================
rule updateEMAllAges
        minInterval 12 //starts in cAge1
active
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
        civPopTarget = 25;
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
    updateEM(civPopTarget, milPopTarget, econPercent, 0.20, econEscrow, econEscrow, econEscrow, econEscrow);
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
