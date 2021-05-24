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
