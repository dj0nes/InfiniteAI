extern bool infinitePopMode = false; // for check if we have infinite population

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
extern bool NoFishing = false;            // changed in map specifics, should be safe to init to false


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
// Behavior modifiers - "control variable" sliders that range from -1 to +1 to adjust AI personalities.  Set them in setParameters().
extern float cvRushBoomSlider = 0.0;         // +1 is extreme rush, -1 is extreme boom.  Rush will age up fast and light
                                             // with few upgrades, and will start a military sooner.  Booming will hit
                                             // age 2 earlier, but will buy upgrades sooner, make more villagers, and
                                             // will put a priority on additional settlements...but starts a military
                                             // much later.
extern float cvMilitaryEconSlider = 0.0;     // Works in conjunction with Rush/Boom.  Settings near 1 will put a huge
                                             // emphasis on military pop and resources, at the expense of the economy.
                                             // Setting it near -1 will put almost everything into the economy.  This
                                             // slider loses most of its effect in 4th age once all settlements are claimed
                                             // Military/Econ at 1.0, Rush/Boom at 1.0:  Quick jump to age 2, rush with almost no vill production.
                                             // Military 1, Rush/Boom -1:  Late to age 2, normal to age 3 with small military, grab 2 more settlements, then all military
                                             // Military/Econ -1, Rush/Boom +1:  Jump quickly to age 2, then jump quickly to age 3, delay upgrades and military.
                                             // Military/Econ -1, Rush/Boom -1:  Almost no military until all settlements are claimed.  Extremely risky boom.
extern float cvOffenseDefenseSlider = 0.0;   // Set high (+1+, causes all military investment in units.  Set low (-1), most military investment in towers and walls.
extern float cvSliderNoise = 0.3;            // The amount of random variance in slider variables.  Set it to 0.0 to have the values locked.  0.3 allows some variability.
                                             // Must be non-negative.  Resultant slider values will be clipped to range -1 through +1.

// Minor god choices.  These MUST be made in setParameters and not changed after that.
// -1 means the AI chooses as it normally would.  List of god names follows.
extern int cvAge2GodChoice = -1;
extern int cvAge3GodChoice = -1;
extern int cvAge4GodChoice = -1;

// DelayStart:  Setting this true will suspend ai initialization.  To resume, call setDelayStart(false).
extern bool cvDelayStart = false;

// MaxAge:  Sets the age limit for this player.  Be careful to use cAge1...cAge4 constants, like cvMaxAge = cAge2 to
// limit the player to age 2.  The actual age numbers used by the code are 0...3, so cAge1...cAge4 is much clearer.
// Set initially in setParameters(), then update dynamically with setMaxAge() if needed.
extern int cvMaxAge = cAge5;

// MaxGathererPop:  Sets the maximum number of gatherers, but doesn't include fishing boats or trade carts (or dwarves?).
// Set initially in setParameters(), can be changed dynamically with setMaxGathererPop().
extern int cvMaxGathererPop = -1;        // -1 turns it off, meaning the scripts can do what they want.  0 means no gatherers.

// MaxMilPop:  The maximum number of military UNITS (not pop slots) that the player can create.
// Set initially in setParameters(), can be changed dynamically with setMaxMilPop().
extern int cvMaxMilPop = -1;             // -1 turns it off, meaning the scripts can do what they want.  0 means no military.

// MaxTradePop:  Tells the AI how many trade units to make.  May be changed via setMaxTradePop().  If set to -1, the AI decides on its own.
extern int cvMaxTradePop = -1;

// OkToAttack:  Setting this false will prevent the AI from using its military units outside of its bases.
// Setting it true allows the AI to attack at will.  This variable can be changed during the course of the game
// by using setOkToAttack().
extern bool cvOkToAttack = true;

// OkToBuildWalls:  Gives the AI permission to build walls if it wants to.  Set it initially in setParamaters, change
// it later if needed using setOkToBuildWalls().  Setting it true later will FORCE wall-building...the AI decision on its own can
// only happen at game start.
extern bool cvOkToBuildWalls = true;

// OkToGatherRelics:  Setting this false will prevent the AI from gathering relics.
extern bool cvOkToGatherRelics = true;

// OkToResign:  Setting this true will allow the AI to resign when it feels bad.  Setting it false will force it to play to the end.
extern bool cvOkToResign = true;

// God power activation switches.  Set in setParameters(), can be modified later via cvOkToUseAge*GodPower() calls.
extern bool cvOkToUseAge1GodPower = true;
extern bool cvOkToUseAge2GodPower = true;
extern bool cvOkToUseAge3GodPower = true;
extern bool cvOkToUseAge4GodPower = true;

// PlayerToAttack:  -1 means not defined.  Number > 0 means attack that player number, overrides mostHatedPlayer.
extern int cvPlayerToAttack = -1;

// Random map name.  Can be set in setParameters to make scenario AI's adopt map-specific behaviors.  Must be set in setParameters() to be
// used, there is no way to activate it later.

extern string cvRandomMapName="None";
// if your scenario needs a special treatment, consider to change "None" to one of these: "Transport Scenario" or "Migration Scenario"

// special maps
extern const int KOTHMAP = 1;
extern const int NOMADMAP = 2;
extern const int SHIMOMAP = 3;
extern const int VINLANDSAGAMAP = 4;
extern const int WATERNOMADMAP = 5;
// nothing special for start...
extern int cvMapSubType = -1;

//for trigonometric functions
extern float PI = 3.141592;

// Reth vars
extern bool mCanIDefendAllies = true;     // Allows the AI to defend his allies.
extern bool gWallsInDM = true;            // This allows the Ai to build walls in the game mode ''Deathmatch''.
extern bool gAgeReduceMil = false;         // This will lower the amount of military units the AI will train until Mythic Age, this will also help the AI to advance a little bit faster, more configs below.
extern bool bWallUp = true;              // This ensures that the Ai will build walls, regardless of personality.

extern bool CanIChat = true;              // This will allow the Ai to send chat messages, such as asking for help if it's in danger.
extern bool bHouseBunkering = true;       // Makes the Ai bunker up towers with Houses.
extern bool bWallAllyMB = true;          // Walls up TCs for human allies, only the team captain can do this and MBs are skipped.
extern bool bWallCleanup = true;          // Prevents the AI from building small wall pieces inside of gates and/or deletes them if one were to slip through the check.

extern int onBuildOrders = -1;
extern int dwarfTypeID = -1;
extern int gathererTypeID = -1;

// econ management, start of a major refactor

//Set up the initial resource break downs.
extern int numFoodEasyPlans = 1;
extern int numFoodHuntPlans = 0;
extern int numFoodHuntAggressivePlans = 0;
extern int numFarmPlans = 0;
extern int numFishPlans = 0;
extern int numWoodPlans = 0;
extern int numGoldPlans = 0;
extern int numFavorPlans = 0;

//Cost weights.
extern int gatherPlanCostWeight = 4;
extern float gatherGoldCostWeight = 1.0;
extern float gatherWoodCostWeight = 1.0;
extern float gatherFoodCostWeight = 1.0;
extern float gatherFavorCostWeight = 1.0;

// farm limits
extern int farmLimitPerPlan = 20;
extern int maxFarmLimit = 40;

// resource rough percent of gatherer allotment (?)
extern float foodPct = 0.9;
extern float woodPct = 0.0;
extern float goldPct = 0.01;
extern float favorPct = 0.0;

// gather plan priority per resource
extern int foodEasyPriority = 100;
extern int foodHuntPriority = 100;
extern int foodHuntAggressivePriority = 90;
extern int foodFishingPriority = 100;
extern int favorPriority = 40;
extern int woodPriority = 55;
extern int goldPriority = 100;
