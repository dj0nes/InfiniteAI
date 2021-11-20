void echo(string msg="") {
    if(ShowAIDebug) {
        aiEcho(msg);
    }
}


bool initInfinitePopModeCheck(void) {
    infinitePopMode = kbGetPop() == 0;
}

void resetGlobalsWithInfinitePop(void) {
    gMaxTradeCarts = 100; // I'm sorry, CPU
}


//==============================================================================
bool equal(vector left=cInvalidVector, vector right=cInvalidVector) //true if the given vectors are equal
{
    float lx = xsVectorGetX( left );
    float ly = xsVectorGetY( left );
    float lz = xsVectorGetZ( left );
    float rx = xsVectorGetX( right );
    float ry = xsVectorGetY( right );
    float rz = xsVectorGetZ( right );

    if ( lx == rx &&
         ly == ry &&
         lz == rz )
    {
        return(true);
    }

    return(false);
}
// *****************************************************************************
// configQuery
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
// *****************************************************************************
bool configQuery( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int player = -1,
                  vector center = cInvalidVector, bool sort = false, float radius = -1, bool seeable = false, int areaID = -1 )
{
    if ( queryID == -1)
        return(false);

    kbUnitQuerySetPlayerID(queryID, player);
    kbUnitQuerySetUnitType(queryID, unitType);
    kbUnitQuerySetActionType(queryID, action);
    if(state > -1)
        kbUnitQuerySetState(queryID, state);

    kbUnitQuerySetPosition(queryID, center);
    kbUnitQuerySetAscendingSort(queryID, sort);
    kbUnitQuerySetMaximumDistance(queryID, radius);

    kbUnitQuerySetAreaID(queryID, areaID);
    kbUnitQuerySetSeeableOnly(queryID, seeable);

    return(true);
}

// *****************************************************************************
// configQueryRelation
//
// Sets up all the non-default parameters so you can config a query on a single call.
// Query must be created prior to calling, and the results reset and the query executed
// after the call.
// Unlike configQuery(), this uses the PLAYER RELATION rather than the player number
// *****************************************************************************
bool configQueryRelation( int queryID = -1, int unitType = -1, int action = -1, int state = -1, int playerRelation = -1,
                          vector center = cInvalidVector, bool sort = false, float radius = -1, bool seeable = false, int areaID = -1)
{
    if (queryID == -1)
    {
        aiEcho("Invalid query ID");
        return(false);
    }

    kbUnitQuerySetPlayerRelation(queryID, playerRelation);
    kbUnitQuerySetUnitType(queryID, unitType);
    kbUnitQuerySetActionType(queryID, action);
    kbUnitQuerySetState(queryID, state);
    kbUnitQuerySetPosition(queryID, center);
    kbUnitQuerySetAscendingSort(queryID, sort);
    kbUnitQuerySetMaximumDistance(queryID, radius);

    kbUnitQuerySetAreaID(queryID, areaID);
    kbUnitQuerySetSeeableOnly(queryID, seeable);

    return(true);
}


int getStartingUlfsarkID(void) 
{
    // add the one ulfsark to this plan
    int qid = kbUnitQueryCreate("getUlfsarksQuery");
    // if (qid < 0) return -1;

    configQuery(qid, cUnitTypeAbstractInfantry, -1, cUnitStateAlive, cMyID);
    kbUnitQueryResetResults(qid);
    int numBuilders = kbUnitQueryExecute(qid);
    for (i=0; < numBuilders)
    {
        int builderID = kbUnitQueryGetResult(qid, i);
        if(i == 0) {
            echo("getStartingUlfsarkID: found ulfsark ID: " + builderID);
            return(builderID);
        }
    }
    return(-1);
}


//==============================================================================
int NumUnitsOnAreaGroupByRel(bool Player = false, int AreaGroupID = -1, int UnitID = -1, int PlayerIDOrRelation = cPlayerRelationSelf, int iState = cUnitStateAlive, int Action = cActionAny)
{
    static int AreaUnitQuery = -1;
    if (AreaUnitQuery < 0)
    {
        AreaUnitQuery = kbUnitQueryCreate("AreaGroupQuery");
        if (AreaUnitQuery < 0)
            return(-1);
    }
    kbUnitQuerySetPlayerRelation(AreaUnitQuery, -1);
    kbUnitQuerySetPlayerID(AreaUnitQuery, -1);
    if (Player == false)
        kbUnitQuerySetPlayerRelation(AreaUnitQuery, PlayerIDOrRelation);
    else
        kbUnitQuerySetPlayerID(AreaUnitQuery, PlayerIDOrRelation);

    kbUnitQuerySetUnitType(AreaUnitQuery, UnitID);
    kbUnitQueryResetResults(AreaUnitQuery);
    kbUnitQuerySetState(AreaUnitQuery, iState);
    kbUnitQuerySetAreaGroupID(AreaUnitQuery, AreaGroupID);
    kbUnitQueryResetResults(AreaUnitQuery);
    return(kbUnitQueryExecute(AreaUnitQuery));
}
bool SameAG(vector vec1 = cInvalidVector, vector vec2 = cInvalidVector)
{
    if ((kbAreaGroupGetIDByPosition(vec1) == kbAreaGroupGetIDByPosition(vec2)))
        return(true);
    else
        return(false);
}

int addSDT(int planID = -1, int TimerInSeconds = 1)
{
    if (planID != -1)
    {
        TimerInSeconds = TimerInSeconds * 1000;
        aiPlanAddUserVariableInt(planID, 0, "SelfDestruct Timer", 2);
        aiPlanSetUserVariableInt(planID, 0, 0, 150);
        aiPlanSetUserVariableInt(planID, 0, 1, xsGetTime()+TimerInSeconds);
    }
}
//==============================================================================
bool hasWaterNeighbor(int areaID = -1)    // True if the test area has a water area neighbor
{
    int areaCount = -1;
    int areaIndex = -1;
    int testArea = -1;
    bool hasWater = false;

    areaCount = kbAreaGetNumberBorderAreas(areaID);
    if (areaCount > 0)
    {
        for (areaIndex=0; < areaCount)
        {
            testArea = kbAreaGetBorderAreaID(areaID, areaIndex);
            if ( kbAreaGetType(testArea) == cAreaTypeWater )
                hasWater = true;
        }
    }
    return(hasWater);
}

//==============================================================================
int verifyVinlandsagaBase(int goalAreaID = -1, int recurseCount = 3)    //verify that this area borders water, find another if it doesn't.
{
    int newAreaID = goalAreaID;  // New area will be the one we use.  By default,
    // we'll start with the one passed to us.
    bool done = false;           // Set true when we find an acceptable one
    int index = -1;              // Which number are we checking
    int areaCount = -1;          // How many areas to search
    int testArea = -1;


    if (hasWaterNeighbor(goalAreaID) == true) // Simple case
    {
        return(goalAreaID);
    }
    int recurseLevel = 0;
    if (recurseCount > 0)
    {
        for (recurseLevel=0; < recurseCount)
        {
            // Test each area that borders each border area.
            for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID)) // Get each border area
            {
                testArea = kbAreaGetBorderAreaID(goalAreaID, index);
                if (verifyVinlandsagaBase(testArea, recurseLevel) > 0)
                {
                    return(testArea);
                }
            }
        }
    }
    return(-1);
}

//==============================================================================
// some trigonometric functions stolen from The Void RMS by Wolfenhex
// Many thanks to Wolfenhex for providing these functions
// His RMS can be found here:
// http://aom.heavengames.com/downloads/showfile.php?fileid=1377
//==============================================================================
float _pow(float n = 0,int x = 0)
{
    float r = n;
    for (i = 1; < x)
    {
        r = r * n;
    }
    return (r);
}

float _atan(float n = 0)
{
    float m = n;
    if (n > 1)
        m = 1.0 / n;
    if (n < -1)
        m = -1.0 / n;
    float r = m;
    for (i = 1; < 100)
    {
        int j = i * 2 + 1;
        float k = _pow(m,j) / j;
        if (k == 0)
            break;
        if (i % 2 == 0)
            r = r + k;
        if (i % 2 == 1)
            r = r - k;
    }
    if (n > 1 || n < -1)
        r = PI / 2.0 - r;
    if (n < -1)
        r = 0.0 - r;
    return (r);
}

float _atan2(float z = 0,float x = 0)
{
    if (x > 0)
        return (_atan(z / x));
    if (x < 0)
    {
        if (z < 0)
            return (_atan(z / x) - PI);
        if (z > 0)
            return (_atan(z / x) + PI);
        return (PI);
    }
    if (z > 0)
        return (PI / 2.0);
    if (z < 0)
        return (0.0 - (PI / 2.0));
    return (0);
}

float _fact(float n = 0)
{
    float r = 1;
    for (i = 1; <= n)
    {
        r = r * i;
    }
    return (r);
}

float _cos(float n = 0)
{
    float r = 1;
    for (i = 1; < 100)
    {
        int j = i * 2;
        float k = _pow(n,j) / _fact(j);
        if (k == 0)
            break;
        if (i % 2 == 0)
            r = r + k;
        if (i % 2 == 1)
            r = r - k;
    }
    return (r);
}

float _sin(float n = 0)
{
    float r = n;
    for (i = 1; < 100)
    {
        int j = i * 2 + 1;
        float k = _pow(n,j) / _fact(j);
        if (k == 0)
            break;
        if (i % 2 == 0)
            r = r + k;
        if (i % 2 == 1)
            r = r - k;
    }
    return (r);
}

//==============================================================================
// findUnit // Will find a random unit of the given playerID
//==============================================================================
int findUnit(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1,
             int playerID = cMyID, vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("randFindUnitQuery");

    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, true, radius, seeable, areaID); //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
    return(-1);
}

//==============================================================================
// findUnitByRel    // Will find a random unit of the given playerRelation
//==============================================================================
int findUnitByRel(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, int playerRelation = cPlayerRelationSelf,
                  vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("randFindUnitByRelQuery");

    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, true, radius, seeable, areaID); //sort = true
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound = kbUnitQueryExecute(unitQueryID);
    for (i=0; < numberFound)
        return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
    return(-1);
}

//==============================================================================
// findUnitByIndex // Will find a random unit of the given playerID  // Thanks goes to nate_e for optimizing this loop! :)
//==============================================================================
int findUnitByIndex(int unitTypeID = -1, int index = 0, int state = cUnitStateAlive, int action = -1, int playerID = cMyID,
                    vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("findUnitByIndex");
    if (index == 0)
    {
        kbUnitQueryResetResults(unitQueryID);
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, true, radius, seeable, areaID ); //sort = true
        kbUnitQueryExecute(unitQueryID);
    }
    int retval = kbUnitQueryGetResult(unitQueryID, index);
    return(retval);
}
//==============================================================================
// findUnitByRelByIndex // Will find a random unit of the given playerRelation // Thanks goes to nate_e for optimizing this loop! :)
//==============================================================================
int findUnitByRelByIndex(int unitTypeID = -1, int index = 0, int state = cUnitStateAlive, int action = -1,
                         int playerRelation = cPlayerRelationSelf, vector center = cInvalidVector, float radius = -1,
                         bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("findUnitByRelByIndex");
    if (index == 0)
    {
        kbUnitQueryResetResults(unitQueryID);
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, true, radius, seeable, areaID); //sort = true
        kbUnitQueryExecute(unitQueryID);
    }
    int retval = kbUnitQueryGetResult(unitQueryID, index);
    return(retval);
}
//==============================================================================
// getNumUnits  // Returns the number of units of the given playerID (within the radius of a position)
//==============================================================================
int getNumUnits(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1,
                int playerID = cMyID, vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;
    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getNumUnitsQuery");

    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQuery(unitQueryID, unitTypeID, action, state, playerID, center, false, radius, seeable, areaID);
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound = kbUnitQueryExecute(unitQueryID);
    return(numberFound);
}

//==============================================================================
// getNumUnitsByRel // Returns the number of units of the given playerRelation (within the radius of a position)
//==============================================================================
int getNumUnitsByRel(int unitTypeID = -1, int state = cUnitStateAlive, int action = -1, int playerRelation = cPlayerRelationSelf,
                     vector center = cInvalidVector, float radius = -1, bool seeable = false, int areaID = -1)
{
    static int unitQueryID = -1;
    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getNumUnitsByRelQuery");

    //Define a query to get all matching units
    if (unitQueryID != -1)
        configQueryRelation(unitQueryID, unitTypeID, action, state, playerRelation, center, false, radius, seeable, areaID);
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound = kbUnitQueryExecute(unitQueryID);
    return(numberFound);
}

//==============================================================================
vector getMainBaseMilitaryGatherPoint()
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector militaryGatherPoint = cInvalidVector;
    static float radius = 30.0;
    int gatherPointUnitIDNearMainBase = -1;
    for (i = 0; < 2)
    {
        if (gAge3MinorGod == cTechAge3Apollo)
            gatherPointUnitIDNearMainBase = findUnitByIndex(cUnitTypeTemple, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, radius);
        else if (gAge2MinorGod == cTechAge2Forseti)
            gatherPointUnitIDNearMainBase = findUnitByIndex(cUnitTypeHealingSpringObject, 0, cUnitStateAlive, -1, cMyID, mainBaseLocation, radius);

        if (gatherPointUnitIDNearMainBase < 0)
        {
            radius = radius + 20.0;
        }
        else
        {
            militaryGatherPoint = kbUnitGetPosition(gatherPointUnitIDNearMainBase);
            radius = 30.0;
            break;
        }
    }
    if (equal(militaryGatherPoint, cInvalidVector) == true)
    {
        vector baseFront = xsVectorNormalize(kbGetMapCenter() - mainBaseLocation);
        militaryGatherPoint = mainBaseLocation + baseFront * 18;
    }
    return(militaryGatherPoint);
}


//==============================================================================
int getMainBaseUnitIDForPlayer(int playerID = -1)
{

    int numSettlements = kbUnitCount(playerID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    if (numSettlements < 1)
    {
        return(-1);
    }

    int mainBaseUnitID = -1;

    int mainBaseID = kbBaseGetMainID(playerID); //For some reason the mainBaseID of enemies usually isn't a settlement base!
    vector mainBaseLocation = kbBaseGetLocation(playerID, mainBaseID); //doesn't actually return the settlement position
    float radius = 15.0;
    for (i = 0; < 4)
    {
        mainBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, 0, cUnitStateAlive, -1, playerID, mainBaseLocation, radius);
        if (mainBaseUnitID < 0)
        {
            radius = radius + 15.0;
        }
        else
        {
            break;
        }
    }

    if (mainBaseUnitID < 0)
    {
        for (i = 0; < numSettlements)
        {
            int settlementID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, playerID);
            if (settlementID != -1)
            {
                vector settlementLocation = kbUnitGetPosition(settlementID);
                int numTowersInR50 = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, playerID, settlementLocation, 50.0);
                int numFarmsInR30 = getNumUnits(cUnitTypeFarm, cUnitStateAlive, -1, playerID, settlementLocation, 30.0);
                if ((numTowersInR50 > 3) || (numFarmsInR30 > 6)) //TODO: rework and improve the main base detection!
                {
                    mainBaseUnitID = settlementID;
                    break;
                }
            }
        }
    }
    return(mainBaseUnitID);
}

//==============================================================================
int findNumUnitsInBase(int playerID = 0, int baseID = -1, int unitTypeID = -1, int state = cUnitStateAliveOrBuilding, int action = cActionAny)
{
    static int unitQueryID = -1;
    //Create the query if we don't have it.
    if (unitQueryID < 0)
        unitQueryID = kbUnitQueryCreate("getUnitsInBaseQuery");

    //Define a query to get all matching units
    if (unitQueryID != -1)
    {
        kbUnitQuerySetPlayerID(unitQueryID, playerID);
        kbUnitQuerySetBaseID(unitQueryID, baseID);
        kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
        kbUnitQuerySetState(unitQueryID, state);
        kbUnitQuerySetActionType(unitQueryID, action);
    }
    else
        return(-1);

    kbUnitQueryResetResults(unitQueryID);
    return(kbUnitQueryExecute(unitQueryID));
}
//==============================================================================
int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
                           int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
                           int baseID=-1, bool allowRetreat=false)
{
    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //Attack player ID.
    if (attackPlayerID >= 0)
        aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
    else
        aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
    //Base.
    if (baseID >= 0)
        aiPlanSetBaseID(goalID, baseID);
    else
        aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateBase, 0, true);
    //Attack.
    aiPlanSetAttack(goalID, true);
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeAttack);
    aiPlanSetVariableInt(goalID, cGoalPlanAttackStartFrequency, 0, 5);
    //Military.
    aiPlanSetMilitary(goalID, true);
    aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);
    //Unit Picker.
    aiPlanSetVariableInt(goalID, cGoalPlanUnitPickerID, 0, unitPickerID);
    //Retreat.
    aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, allowRetreat);
    // Upgrade Building prefs.

    aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 3, true);
    aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeTemple);
    aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
    if (cMyCiv == cCivThor)
        aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeDwarfFoundry);
    else
        aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeArmory);

    //Handle maps where the enemy player is usually on a diff island.
    if (gTransportMap == true)
    {
        aiPlanSetVariableBool(goalID, cGoalPlanSetAreaGroups, 0, true);
        aiPlanSetVariableInt(goalID, cGoalPlanAttackRoutePatternType, 0, cAttackPlanAttackRoutePatternBest);
    }
    // Handle OkToAttack control variable
    if (cvOkToAttack == false)
    {
        aiPlanSetVariableBool(goalID, cGoalPlanIdleAttack, 0, true); // Prevent attacks
    }

    //Done.
    return(goalID);
}

//==============================================================================
int createBaseGoal(string name="BUG", int goalType=-1, int attackPlayerID=-1,
                   int repeat=-1, int minAge=-1, int maxAge=-1, int parentBaseID=-1)
{
    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //"Parent" Base.
    aiPlanSetBaseID(goalID, parentBaseID);
    //Base Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, goalType);
    if (goalType == cGoalPlanGoalTypeForwardBase)
    {
        //Attack player ID.
        if (attackPlayerID >= 0)
            aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
        else
            aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
        //Military.
        aiPlanSetMilitary(goalID, true);
        aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
        //Active health.
        aiPlanSetVariableInt(goalID, cGoalPlanActiveHealthTypeID, 0, cUnitTypeBuilding);
        aiPlanSetVariableFloat(goalID, cGoalPlanActiveHealth, 0, 0.25);
    }
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

    //Done.
    return(goalID);
}

//==============================================================================
int createCallbackGoal(string name="BUG", string callbackName="BUG", int repeat=-1,
                       int minAge=-1, int maxAge=-1, bool autoUpdate=false)
{
    //Get the callbackFID.
    int callbackFID=xsGetFunctionID(callbackName);
    if (callbackFID < 0)
        return(-1);

    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Goal Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeCallback);
    //Auto update.
    aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
    //Callback FID.
    aiPlanSetVariableInt(goalID, cGoalPlanFunctionID, 0, callbackFID);
    //Priority.
    aiPlanSetDesiredPriority(goalID, 90);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

    //Done.
    return(goalID);
}

//==============================================================================
int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
                              bool autoUpdate=true, int pri=100)
{
    int buildingTypeID = cUnitTypeSettlementLevel1;
    //Create the goal.
    int goalID=aiPlanCreate(name, cPlanGoal);
    if (goalID < 0)
        return(-1);

    //Goal Type.
    aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
    //Base ID.
    aiPlanSetBaseID(goalID, baseID);
    //Auto update.
    aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
    //Building Type ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
    //Building Search ID.
    aiPlanSetVariableInt(goalID, cGoalPlanBuildingSearchID, 0, cUnitTypeSettlement);
    //Set the builder parms.
    aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
    aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
    aiPlanSetEscrowID(goalID, cRootEscrowID);

    //Priority.
    aiPlanSetDesiredPriority(goalID, pri);
    //Ages.
    aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
    aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
    //Repeat.
    aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, 1);

    //Done.
    return(goalID);
}

//==============================================================================
int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
                        bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1)
{
    //Create the plan.
    int planID=aiPlanCreate(name, cPlanTransport);
    if (planID < 0)
        return(-1);

    //Priority.
    aiPlanSetDesiredPriority(planID, pri);
    //Base.
    aiPlanSetBaseID(planID, baseID);
    //Set the areas.
    aiPlanSetVariableInt(planID, cTransportPlanPathType, 0, 1);
    aiPlanSetVariableInt(planID, cTransportPlanGatherArea, 0, startAreaID);
    aiPlanSetVariableInt(planID, cTransportPlanTargetArea, 0, goalAreaID);
    //Default the initial position to the start area's location.
    aiPlanSetInitialPosition(planID, kbAreaGetCenter(startAreaID));
    //Transport type.
    aiPlanSetVariableInt(planID, cTransportPlanTransportTypeID, 0, transportPUID);
    //Persistent.
    aiPlanSetVariableBool(planID, cTransportPlanPersistent, 0, persistent);
    //Always add the transport unit type.
    aiPlanAddUnitType(planID, transportPUID, 1, 1, 1);
    //Activate.
    aiPlanSetActive(planID);

    //Done.
    return(planID);
}

//==============================================================================
// claimSettlement
// @param where: the position of the settlement to claim
// @param baseID: the base to get the builders from. If left unspecified, the
//                funct will try to find builders
//==============================================================================
void claimSettlement(vector where=cInvalidVector, int baseToUseID=-1)
{
    int baseID=-1;
    int startAreaID=-1;
    static int builderQuery=-1;
    int NumBuilder = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(where), cBuilderType, cMyID);
    if (NumBuilder > 0)
        return;

    baseID = kbBaseGetMainID(cMyID);
    vector baseLoc = kbBaseGetLocation(cMyID, baseID);
    startAreaID = kbAreaGetIDByPosition(baseLoc);

    int remoteSettlementTransportPlan=createTransportPlan("Remote Settlement Transport", startAreaID, kbAreaGetIDByPosition(where),
                                                          false, cUnitTypeTransport, 80, baseID);

    // add the builders to the transport plan
    int NumBuilders = 2;
    if (cMyCulture == cCultureAtlantean)
        NumBuilders = 1;
    aiPlanAddUnitType(remoteSettlementTransportPlan, cBuilderType, NumBuilders, NumBuilders, NumBuilders);

    //Done with transport plan. build a settlement now!

    int planID=aiPlanCreate("Build Remote"+kbGetUnitTypeName(cUnitTypeSettlementLevel1),
                            cPlanBuild);
    if (planID < 0)
        return;

    aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
    aiPlanSetDesiredPriority(planID, 100);
    aiPlanSetEconomy(planID, true);
    aiPlanSetEscrowID(planID, cEconomyEscrowID);
    aiPlanAddUnitType(planID, cBuilderType, NumBuilders, NumBuilders, NumBuilders);
    aiPlanSetInitialPosition(planID, where);
    aiPlanSetVariableVector(planID, cBuildPlanSettlementPlacementPoint, 0, where);
    aiPlanSetActive(planID);
    if (rExploreIsland != -1)
        aiPlanDestroy(rExploreIsland);
    rExploreIsland = -1;

    if (rExploreIsland == -1)
    {
        rExploreIsland=aiPlanCreate("Explore there..", cPlanExplore);
        aiPlanAddUnitType(rExploreIsland, cBuilderType, 0, 0, NumBuilders);
        aiPlanSetInitialPosition(rExploreIsland, where);
        aiPlanAddWaypoint(rExploreIsland, where);
        aiPlanSetVariableBool(rExploreIsland, cExplorePlanDoLoops, 0, false);
        aiPlanSetVariableBool(rExploreIsland, cExplorePlanReExploreAreas,0, false);
        if (cMyCulture == cCultureNorse)
        {
            aiPlanSetVariableVector(rExploreIsland, cExplorePlanQuitWhenPointIsVisiblePt, 0, where);
            aiPlanSetVariableBool(rExploreIsland, cExplorePlanQuitWhenPointIsVisible,0, true);
        }
        aiPlanSetDesiredPriority(rExploreIsland, 3);
        aiPlanSetActive(rExploreIsland);
    }

}
//==============================================================================
int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1)
{
    //Create the plan name.
    string planName="Military";
    if (economy == true)
        planName="Economy";
    planName=planName+kbGetProtoUnitName(puid)+"Maintain";

    int planID=aiPlanCreate(planName, cPlanTrain);
    if (planID < 0)
        return(-1);

    //Economy or Military.
    if (economy == true)
        aiPlanSetEconomy(planID, true);
    else
        aiPlanSetMilitary(planID, true);
    //Unit type.
    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
    //Number.
    aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, number);
    //If we have a base ID, use it.
    if (baseID >= 0)
    {
        aiPlanSetBaseID(planID, baseID);
        if (economy == false)
            aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
    }

    aiPlanSetActive(planID);

    //Done.
    return(planID);
}

//==============================================================================
int createSimpleTrainPlan(int puid = -1, int number = 1, int escrowID = -1, int baseID = -1)
{
    string planName="Simple";
    planName=planName+kbGetProtoUnitName(puid)+"Train";
    int planID=aiPlanCreate(planName, cPlanTrain);
    if (planID < 0)
        return(-1);

    aiPlanSetEscrowID(planID, escrowID);
    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, number);
    if (baseID >= 0)
    {
        aiPlanSetBaseID(planID, baseID);
        aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
    }
    aiPlanSetActive(planID);
    return(planID);
}

//==============================================================================
bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
                           bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1)
{
    //Create the right number of plans.
    for (i=0; < number)
    {
        int planID=aiPlanCreate("SimpleBuild"+kbGetUnitTypeName(puid)+" "+number, cPlanBuild);
        if (planID < 0)
            return(false);
        //Puid.
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
        //Border layers.
        aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 2, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, baseID)) );
        //Priority.
        aiPlanSetDesiredPriority(planID, pri);
        //Mil vs. Econ.
        aiPlanSetMilitary(planID, military);
        aiPlanSetEconomy(planID, economy);
        //Escrow.
        aiPlanSetEscrowID(planID, escrowID);
        //Builders.
        aiPlanAddUnitType(planID, cBuilderType, numberBuilders, numberBuilders, numberBuilders);
        //Base ID.
        aiPlanSetBaseID(planID, baseID);
        if (puid != cUnitTypeFarm)
        {
            aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuilding);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 8);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -5.0); // -5 points per unit
        }
        //Go.
        aiPlanSetActive(planID);
    }
}
//==============================================================================
int getSoftPopCap(void) //Calculate our pop limit if we had all houses built
{

    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
        houseProtoID = cUnitTypeManor;
    int houseCount = -1;

    int maxHouses = kbGetBuildLimit(cMyID, houseProtoID);
    int popPerHouse = 10;
    if (cMyCulture == cCultureAtlantean)
        popPerHouse = 20;

    if (maxHouses == -1)
    {
        int Housepop=kbGetPopCapAddition(cMyID, houseProtoID);
        if (cMyCulture == cCultureAtlantean)
        {
            maxHouses = 15;
            if (Housepop <= 10)
                maxHouses = maxHouses + 5;
        }
        if (cMyCulture != cCultureAtlantean)
        {
            maxHouses = 30;
            if (Housepop <= 5)
                maxHouses = maxHouses + 10;
        }
    }
    houseCount = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive); // Do not count houses being built

    int retVal = -1;

    retVal = kbGetPopCap();

    retVal = retVal + (maxHouses-houseCount)*popPerHouse; // Add pop for missing houses

    return(retVal);
}

//==============================================================================
float adjustSigmoid(float var=0.0, float fraction=0.0,  float lowerLimit=0.0, float upperLimit=1.0)
{   // Adjust the variable by fraction amount.  Dampen it for movement near the limits like a sigmoid curve.
    // A fraction of +.5 means increase it by the lesser of 50% of its original value, or 50% of the space remaining.
    // A fraction of -.5 means decrease it by the lesser of 50% of its original value, or 50% of the distance from the upper limit.

    float spaceAbove = upperLimit - var;

    float adjustRaw = var * fraction;        // .8 at -.5 gives -.4  // .8 at .5 gives 1.2
    float adjustLimit = spaceAbove * fraction; // .2 at -.5 gives -.1  // .2 at .5 gives .1
    float retVal = 0.0;
    if (fraction > 0) // increasing it
    {
        // choose the smaller of the two
        if (adjustRaw < adjustLimit)
            retVal = var + adjustRaw;
        else
            retVal = var + adjustLimit;
    }
    else // decreasing it
    {
        // The "smaller" adjustment is the higher number, i.e. -.1 is a smaller adjustment than -.4
        if (adjustRaw < adjustLimit)
            retVal = var + adjustLimit;
        else
            retVal = var + adjustRaw;
    }
    return(retVal);
}

//==============================================================================
void pullBackUnits(int planID = -1, vector retreatPosition = cInvalidVector)
{
    int numUnitsInPlan = aiPlanGetNumberUnits(planID, cUnitTypeUnit);
    if (numUnitsInPlan > 0)
    {
        //Limited the maximum number of loops
        int max = 9;
        int unitID = -1;
        if (numUnitsInPlan > max)
            numUnitsInPlan = max;
        for (i = 0; < numUnitsInPlan)
        {
            unitID = aiPlanGetUnitByIndex(planID, i);
            if (unitID != -1)
                aiTaskUnitMove(unitID, retreatPosition);
        }
    }
}

//==============================================================================
void keepUnitsWithinRange(int planID = -1, vector retreatPosition = cInvalidVector)
{
    int numUnitsInPlan = aiPlanGetNumberUnits(planID, cUnitTypeUnit);
    if (numUnitsInPlan > 0)
    {
        //Limited the maximum number of loops
        int max = 16;

        float engageRange = aiPlanGetVariableFloat(planID, cDefendPlanEngageRange, 0);
        if (engageRange < 35.0)
            engageRange = 25.0;

        int unitID = -1;
        int actionType = -1;
        vector unitPosition = cInvalidVector;
        float distance = 0.0;
        float modifier = 0.0;
        float minDistance = 0.0;
        float multiplier = 0.0;
        vector directionalVector = cInvalidVector;
        vector desiredPosition = cInvalidVector;
        if (numUnitsInPlan > max)
            numUnitsInPlan = max;
        for (i = 0; < numUnitsInPlan)
        {
            unitID = aiPlanGetUnitByIndex(planID, i);
            if (unitID == -1)
                continue;

            if (kbUnitIsType(unitID, cUnitTypeAbstractTitan) == true)
                continue;

            actionType = kbUnitGetActionType(unitID);
            if ((actionType != cActionHandAttack) && (actionType != cActionRangedAttack) && (actionType != cActionLightningAttack))
                continue;

            unitPosition = kbUnitGetPosition(unitID);
            distance = xsVectorLength(unitPosition - retreatPosition);

            modifier = -1.0;
            if (kbUnitIsType(unitID, cUnitTypeAbstractArcher) == true)
                modifier = -8.0;
            else if (kbUnitIsType(unitID, cUnitTypeThrowingAxeman) == true)
                modifier = -5.0;

            if (distance < engageRange + modifier)
                continue;

            minDistance = 5.0 + distance - engageRange;
            if (minDistance < 10.0)
                minDistance = 10.0;
            multiplier = minDistance / distance;
            directionalVector = unitPosition - retreatPosition;
            desiredPosition = unitPosition - directionalVector * multiplier;
            aiTaskUnitMove(unitID, desiredPosition);
        }
    }
}
//==============================================================================
vector calcMonumentPos(int which=-1)
{
    vector basePos=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector towardCenter=kbGetMapCenter()-basePos;
    vector pos=cInvalidVector;
    float q=_atan2(xsVectorGetZ(towardCenter), xsVectorGetX(towardCenter)) - 2.0*PI/5.0;
    float whichfloat=which;
    q = q + whichfloat*2.0*PI/5.0;

    float c = _cos(q);
    float s = _sin(q);
    float x = c * 22.0;
    float z = s * 22.0;
    pos = xsVectorSetX(pos, x);
    pos = xsVectorSetZ(pos, z);
    pos = basePos+pos;
    return(pos);
}
//==============================================================================
bool AgingUp()
{
    if ((kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) == cTechStatusResearching) && (kbGetTechPercentComplete(gAge2MinorGod) > 0.0)
        || (kbGetAge() == cAge2) && (kbGetTechStatus(gAge3MinorGod) == cTechStatusResearching) && (kbGetTechPercentComplete(gAge3MinorGod) > 0.0)
        || (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) == cTechStatusResearching) && (kbGetTechPercentComplete(gAge4MinorGod) > 0.0)
        || (kbGetAge() == cAge4) && (kbGetTechStatus(cTechSecretsoftheTitans) == cTechStatusResearching) && (kbGetTechPercentComplete(cTechSecretsoftheTitans) > 0.0))
        return(true);
    return(false);
}
bool ShouldIAgeUp()
{
    if ((kbGetAge() > cAge3) || (kbGetAge() == cAge1))
        return(false);
    if ((kbGetAge() == cAge2) && (xsGetTime() > 15*60*1000))
        return(true);

    for (i=0; < cNumberPlayers)
    {
        if ((i == cMyID) || (kbIsPlayerAlly(i) == true))
            continue;
        if (kbGetAgeForPlayer(i) > kbGetAge())
            return(true);
    }
    return(false);
}
bool TrainPlanExists(int puid = -1, int baseID = -1)
{
    if ((puid == -1) || (baseID == -1))
        return(false);
    int activeTrainPlans = aiPlanGetNumber(cPlanTrain, -1, true);
    if (activeTrainPlans > 0)
    {
        for (i = 0; < activeTrainPlans)
        {
            int trainPlanIndexID = aiPlanGetIDByIndex(cPlanTrain, -1, true, i);
            if ((puid == aiPlanGetVariableInt(trainPlanIndexID, cTrainPlanUnitType, 0)) && (aiPlanGetBaseID(trainPlanIndexID) == baseID))
            {
                //aiEcho("Skipping train plan.. plan already exist for training unit:  "+kbGetProtoUnitName(puid));
                return(true);
            }
        }
    }
    return(false);
}
//==============================================================================
void taskMilUnitTrainAtBase(int baseID = -1, int amount = 1, int ignoreUnit1 = -1, int ignoreUnit2 = -1, int sdtTimer = 40)
{
    if (baseID == -1)
        return;

    bool CanAfford = false;
    vector baseLocation = kbBaseGetLocation(cMyID, baseID);
    int buildingToUse = -1;
    int bProto = -1;
    int puid = -1;
    int upID = gLateUPID;
    if (kbGetAge() < cAge3)
        upID = gRushUPID;

    for (i = 0; < kbUnitPickGetDesiredNumberUnitTypes(upID))
    {
        bProto = kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(upID, i), cMyCiv);
        int buildingsThere = getNumUnits(bProto, cUnitStateAlive, -1, cMyID, baseLocation, 25.0);
        if ((cMyCulture == cCultureNorse) && (bProto == cUnitTypeUlfsark) && (buildingsThere < 0))
            buildingsThere = getNumUnits(cUnitTypeLonghouse, cUnitStateAlive, -1, cMyID, baseLocation, 25.0);
        if (buildingsThere > 0)
        {
            if (TrainPlanExists(kbUnitPickGetResult(upID, i), baseID) == false)
            {
                buildingToUse = findUnitByIndex(kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(upID, i), cMyCiv), 0, cUnitStateAlive, -1, cMyID, baseLocation, 30.0);
                puid = kbUnitPickGetResult(upID, i);
                break;
            }
        }
    }

    if (buildingToUse == -1)
    {
        buildingToUse = findUnit(cUnitTypeLogicalTypeBuildingsThatTrainMilitary, cUnitStateAlive, -1, cMyID, baseLocation, 25.0);
        if (buildingToUse < 0)
            buildingToUse = findUnit(cUnitTypeSettlementsThatTrainVillagers, cUnitStateAlive, -1, cMyID, baseLocation, 25.0);
        bProto = kbGetUnitBaseTypeID(buildingToUse);
        if (buildingToUse > 0)
        {
            int UnitType = cUnitTypeHumanSoldier;
            if (kbProtoUnitIsUnitType(bProto, cUnitTypeTemple))
                UnitType = cUnitTypeMythUnit;
            for (l = 0; < 14)
            {
                int RandUnit = kbGetRandomEnabledPUID(UnitType, cMilitaryEscrowID);
                int RandBuildID = kbTechTreeGetUnitIDByTrain(RandUnit, cMyCiv);
                if ((kbProtoUnitIsUnitType(RandUnit, ignoreUnit1)) || (kbProtoUnitIsUnitType(RandUnit, ignoreUnit2)) || (kbProtoUnitIsUnitType(RandUnit, cUnitTypeKhopesh))
                    || (kbProtoUnitIsUnitType(RandUnit, cUnitTypePhysician)) || (kbProtoUnitIsUnitType(RandUnit, cUnitTypeRoc)) || (kbProtoUnitIsUnitType(RandUnit, cUnitTypeFlyingMedic))
                    || (cMyCulture == cCultureEgyptian) && (kbProtoUnitIsUnitType(RandBuildID, cUnitTypeAbstractSettlement)) && (RandUnit != cUnitTypePriest))
                    continue;
                if ((RandBuildID == bProto) && (TrainPlanExists(RandUnit, baseID) == false))
                {
                    puid = RandUnit;
                    break;
                }
            }
        }
    }

    if ((kbCanAffordUnit(puid, cRootEscrowID) == true) || (kbCanAffordUnit(puid, cMilitaryEscrowID) == true))
        CanAfford = true;

    if ((puid == -1) || (buildingToUse == -1) || (CanAfford == false))
        return;
    //aiEcho(" Made trainPlan for unit: "+kbGetProtoUnitName(puid));
    int planID = createSimpleTrainPlan(puid, amount, false, baseID);
    int Attackplan = aiPlanGetIDByIndex(cPlanAttack, -1, true, 0);
    if (Attackplan != -1)
        aiPlanSetVariableInt(planID, cTrainPlanIntoPlanID, 0, Attackplan);
    aiPlanSetVariableInt(planID, cTrainPlanFrequency, 0, 1);
    aiPlanSetDesiredPriority(planID, 100);
    addSDT(planID, sdtTimer);
}

// borrowed from "Notonecta" ):
//==============================================================================
int findPlanByString(string autoName = "BUG", int iPlanType = -1, int iState = -1, bool ActiveOnly = true, bool ReturnNumbers = false)
{
    int iPlanID = aiPlanGetID(autoName);
    if (iPlanID < 0)
    {
        int iNumberOfPlans = aiPlanGetNumber(iPlanType, iState, ActiveOnly);
        int Number = 0;
        for (i = 0; < iNumberOfPlans)
        {
            int iCurrentPlan = aiPlanGetIDByIndex(iPlanType, iState, ActiveOnly, i);
            if (aiPlanGetName(iCurrentPlan) == (autoName + ":" + iCurrentPlan))
            {
                iPlanID = iCurrentPlan;
                if (ReturnNumbers == true)
                {
                    Number = Number+1;
                    iPlanID = Number;
                }
                if (ReturnNumbers == false)
                    break;
            }
        }
    }
    return(iPlanID);
}

bool uOV(int UnitID = -1)
{
    if (UnitID < 0)
        return(false);
    int Owner = kbUnitGetOwner(UnitID);
    if ((kbIsPlayerResigned(Owner) == false) && (kbHasPlayerLost(Owner) == false))
        return(true);
    else
        return(false);
}

//------------------------------------------------------------------------
int findClosestUnitTypeByLoc(int Relevance = cPlayerRelationEnemy, int UnitType = -1, int Status = cUnitStateAliveOrBuilding, vector loc = cInvalidVector, int radius = -1, bool seeable = true, bool sameArea = false)
{
    static int findTargets = -1;
    if (findTargets < 0)
    {
        findTargets = kbUnitQueryCreate("Closest Target query");
        if (findTargets < 0)
            return(-1);
    }
    kbUnitQuerySetAreaGroupID(findTargets, -1);
    kbUnitQuerySetPlayerRelation(findTargets, Relevance);
    kbUnitQuerySetSeeableOnly(findTargets, seeable);
    kbUnitQuerySetAscendingSort(findTargets, true);
    kbUnitQuerySetUnitType(findTargets, UnitType);
    kbUnitQuerySetState(findTargets, Status);
    kbUnitQuerySetMaximumDistance(findTargets, radius);
    kbUnitQuerySetPosition(findTargets, loc);
    if (sameArea == true)
        kbUnitQuerySetAreaGroupID(findTargets, kbAreaGroupGetIDByPosition(loc));
    kbUnitQueryResetResults(findTargets);
    int Result = -1;
    int Run = kbUnitQueryExecute(findTargets);
    for (i=0; < Run)
    {
        int CurrentCandidate = kbUnitQueryGetResult(findTargets, i);
        if (uOV(CurrentCandidate) == true)
        {
            Result = CurrentCandidate;
            break;
        }
    }
    return(Result);
}
// Thank you, "Artifical Zoo"!. .I hope you don't mind me using your stuff. :)

//==============================================================================
vector GetMilGatherOrBase (bool Mil = true)
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    vector defPlanBaseLocation = cInvalidVector;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            baseLocationToUse = defPlanBaseLocation;
        }
    }
    if (Mil == false)
        return(baseLocationToUse);

    vector militaryGatherPoint = cInvalidVector;
    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1) && (equal(defPlanBaseLocation, cInvalidVector) == false))
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, defPlanBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        float fxOrig = fx;
        float fzOrig = fz;
        if (aiRandInt(2) < 1)
        {
            fx = fzOrig * (-11);
            fz = fxOrig * 11;
        }
        else
        {
            fx = fzOrig * 11;
            fz = fxOrig * (-11);
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        militaryGatherPoint = defPlanBaseLocation + frontVector;
    }
    else
    {
        militaryGatherPoint = getMainBaseMilitaryGatherPoint();
    }
    return(militaryGatherPoint);
}

//==============================================================================
int createDefOrAttackPlan(string Name = "INVALID", bool DefendPlan = true, int EngageRange = 50, int GatherRange = 30, vector Location = cInvalidVector, int BaseID = -1, int Prio = 50, bool Activated = true)
{
    int PlanID = -1;
    if (DefendPlan == true)
    {
        PlanID = aiPlanCreate(""+Name, cPlanDefend);
        if (PlanID != -1)
        {
            if (equal(Location, cInvalidVector) == false)
                aiPlanSetVariableVector(PlanID, cDefendPlanDefendPoint, 0, Location);

            aiPlanSetVariableFloat(PlanID, cDefendPlanEngageRange, 0, EngageRange);
            aiPlanSetVariableFloat(PlanID, cDefendPlanGatherDistance, 0, GatherRange);
            aiPlanSetVariableInt(PlanID, cDefendPlanRefreshFrequency, 0, 5);
            aiPlanSetUnitStance(PlanID, cUnitStanceDefensive);
            aiPlanSetVariableBool(PlanID, cDefendPlanPatrol, 0, false);
            aiPlanSetNumberVariableValues(PlanID, cDefendPlanAttackTypeID, 2, true);
            aiPlanSetVariableInt(PlanID, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
            aiPlanSetVariableInt(PlanID, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);
            aiPlanSetDesiredPriority(PlanID, Prio);

            if (BaseID != -1)
                aiPlanSetBaseID(PlanID, BaseID);

            if (Activated == true)
                aiPlanSetActive(PlanID);
        }
    }
    else if (DefendPlan == false)
    {
        PlanID = aiPlanCreate(""+Name, cPlanAttack);
        if (PlanID != -1)
        {
            aiPlanSetVariableVector(PlanID, cAttackPlanGatherPoint, 0, GetMilGatherOrBase(true));
            aiPlanSetInitialPosition(PlanID, GetMilGatherOrBase(false));
            aiPlanSetVariableFloat(PlanID, cAttackPlanGatherDistance, 0, GatherRange);
            aiPlanSetVariableInt(PlanID, cAttackPlanRefreshFrequency, 0, 5);
            aiPlanSetUnitStance(PlanID, cUnitStanceDefensive);
            aiPlanSetAllowUnderAttackResponse(PlanID, true);

            aiPlanSetVariableInt(PlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
            aiPlanSetVariableInt(PlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
            aiPlanSetVariableBool(PlanID, cAttackPlanMoveAttack, 0, true);
            aiPlanSetRequiresAllNeedUnits(PlanID, false);
            if (aiRandInt(2) < 1)
                aiPlanSetVariableBool(PlanID, cAttackPlanAutoUseGPs, 0, false);
            else
                aiPlanSetVariableBool(PlanID, cAttackPlanAutoUseGPs, 0, true);

            aiPlanSetNumberVariableValues(PlanID, cAttackPlanTargetTypeID, 5, true);
            aiPlanSetVariableInt(PlanID, cAttackPlanTargetTypeID, 0, cUnitTypeLogicalTypeIdleCivilian);
            aiPlanSetVariableInt(PlanID, cAttackPlanTargetTypeID, 1, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
            aiPlanSetVariableInt(PlanID, cAttackPlanTargetTypeID, 2, cUnitTypeUnit);
            aiPlanSetVariableInt(PlanID, cAttackPlanTargetTypeID, 3, cUnitTypeLogicalTypeBuildingsNotWalls);
            aiPlanSetVariableInt(PlanID, cAttackPlanTargetTypeID, 4, cUnitTypeAbstractWall);
            aiPlanSetDesiredPriority(PlanID, Prio);
            //Ban these units
            aiPlanAddUnitType(PlanID, cUnitTypePhysician, 0, 0, 0);
            aiPlanAddUnitType(PlanID, cUnitTypeFlyingMedic, 0, 0, 0);
            aiPlanAddUnitType(PlanID, cUnitTypeOracleHero, 0, 0, 0);
            aiPlanAddUnitType(PlanID, cUnitTypeOracleScout, 0, 0, 0);
            if (gTransportMap == true)
                aiPlanAddUnitType(PlanID, cUnitTypeRoc, 0, 0, 0);

            if (BaseID != -1)
                aiPlanSetBaseID(PlanID, BaseID);

            if (Activated == true)
                aiPlanSetActive(PlanID);
        }
    }
    return(PlanID);
}
//==============================================================================
bool IsTechActive(int TechID = -1)
{
    int TechStatus = kbGetTechStatus(TechID);
    if ((TechStatus == cTechStatusActive) || (TechStatus == cTechStatusPersistent))
        return(true);
    return(false);
}
//==============================================================================
//createSimpleResearchPlan
//==============================================================================
int createSimpleResearchPlan(int techID=-1, int buildingType=-1, int escrowID=cRootEscrowID, int pri = 50, bool progress = false, bool Override = false)
{

    string ReadableTech = kbGetTechName(techID);

    if ((IsTechActive(techID) == true) || (kbGetTechStatus(techID) < cTechStatusAvailable) || (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0) && (Override == false))
    {
        if (ShowAIDebug == true) aiEcho("Failed to create a simple research plan for ''"+ReadableTech+"'', already active, not available or researching?");
        return(-1);
    }
    int planID = -1;
    if (progress == true)
        planID=aiPlanCreate("Research "+kbGetTechName(techID), cPlanProgression);
    else
        planID=aiPlanCreate("Research "+kbGetTechName(techID), cPlanResearch);
    if (planID < 0)
    {
        if (ShowAIDebug == true) aiEcho("Failed to create simple research plan for "+techID);
    }
    else
    {
        string ReadablePlan = "research";
        if (progress == true)
        {
            aiPlanSetVariableInt(planID, cProgressionPlanGoalTechID, 0, techID);
            ReadablePlan = "progression";
        }
        else
            aiPlanSetVariableInt(planID, cResearchPlanTechID, 0, techID);
        if (buildingType != -1)
            aiPlanSetVariableInt(planID, cResearchPlanBuildingTypeID, 0, buildingType);
        aiPlanSetDesiredPriority(planID, pri);
        aiPlanSetEscrowID(planID, escrowID);
        aiPlanAddUserVariableInt(planID, 0, "TechInfo", 3);
        aiPlanSetUserVariableInt(planID, 0, 0, 19);
        aiPlanSetUserVariableInt(planID, 0, 1, xsGetTime());
        aiPlanSetUserVariableInt(planID, 0, 2, techID);
        aiPlanSetActive(planID);
        string Escrow = "INVALID ESCROW";
        if (escrowID == 0)
            Escrow = "RootEscrow";
        else if (escrowID == 1)
            Escrow = "EcoEscrow";
        else if (escrowID == 2)
            Escrow = "MilEscrow";
        if (ShowAIDebug == true) aiEcho("Created a simple "+ReadablePlan+" plan for ''"+ReadableTech+"'', which is taxed on our "+Escrow+" and given a priority of "+pri+".");
    }
    return(planID);
}
//==============================================================================
int AvailableUnitsFromDefPlans(int NumberFound=0)
{
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary) * 0.4;
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary) * 0.4;
    int numMilUnitsInOB1DefPlan = aiPlanGetNumberUnits(gOtherBase1DefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInOB2DefPlan = aiPlanGetNumberUnits(gOtherBase2DefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInOB3DefPlan = aiPlanGetNumberUnits(gOtherBase3DefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInOB4DefPlan = aiPlanGetNumberUnits(gOtherBase4DefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInMBDefPlan1 + numMilUnitsInBaseUnderAttackDefPlan + numMilUnitsInSettlementPosDefPlan
                                + numMilUnitsInOB1DefPlan + numMilUnitsInOB2DefPlan + numMilUnitsInOB3DefPlan + numMilUnitsInOB4DefPlan;
    NumberFound = numMilUnitsInDefPlans;
    return(NumberFound);
}

//==============================================================================
int MilitaryPopFromDefPlan(int NumberFound=0)
{
    if (kbGetPopSlots(cMyID, cUnitTypeHoplite) != 2)
        NumberFound = AvailableUnitsFromDefPlans() * 3;
    else
    {
        int MilUnits = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID);
        float InfPop = 0.5;
        for (a = 0; < MilUnits)
        {
            int cMilUnit = findUnitByIndex(cUnitTypeLogicalTypeLandMilitary, a, cUnitStateAlive, -1, cMyID);
            int Plan = kbUnitGetPlanID(cMilUnit);
            if ((Plan == gDefendPlanID) || (Plan == gMBDefPlan1ID) || (Plan == gOtherBase1DefPlanID)
                || (Plan == gOtherBase2DefPlanID) || (Plan == gOtherBase3DefPlanID) || (Plan == gOtherBase4DefPlanID))
                InfPop = InfPop + kbGetPopSlots(cMyID, kbGetUnitBaseTypeID(cMilUnit));
            else if ((Plan == gBaseUnderAttackDefPlanID) || (Plan == gSettlementPosDefPlanID))
                InfPop = InfPop + kbGetPopSlots(cMyID, kbGetUnitBaseTypeID(cMilUnit))*0.4;
        }
    }
    if (InfPop > 0.5)
        NumberFound = InfPop;
    return(NumberFound);
}
//==============================================================================
bool ReadyToAttack()
{
    bool Ready = false;

    // Try not to be too aggressive if we're lagging behind.
    if ((kbGetAge() == cAge2) && (ShouldIAgeUp() == true))
        return(Ready);

    // Standard AI
    int upID = gLateUPID;
    if (kbGetAge() < cAge3)
        upID = gRushUPID;
    int targetPop = kbUnitPickGetMinimumPop(upID);
    int NumMilPopInDefPlans = MilitaryPopFromDefPlan();
    //
    if (NumMilPopInDefPlans >= targetPop)
        Ready = true;
    return(Ready);
}

//==============================================================================
int newResourceBase(int oldResourceBase=-1, int resourceID=-1)
{
    int Villagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    if (cMyCulture == cCultureAtlantean)
        Villagers = Villagers * 2;
    if ((Villagers < 14) || (findPlanByString("Remote Resource Transport", cPlanTransport) != -1) || (kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive) < 1))
        return(-1);

    int queryUnitID=cUnitTypeGold;
    if (resourceID==cResourceWood)
        queryUnitID=cUnitTypeTree;

    static int resourceQueryID=-1;
    if (resourceQueryID < 0)
        resourceQueryID=kbUnitQueryCreate("Resource Query");
    configQuery(resourceQueryID, queryUnitID, -1, cUnitStateAlive, 0, kbBaseGetLocation(cMyID, kbBaseGetMain(cMyID)), true);
    kbUnitQueryResetResults(resourceQueryID);
    int numResults = kbUnitQueryExecute(resourceQueryID);
    if (numResults <= 0)
        return(-1);

    vector there = kbUnitGetPosition(kbUnitQueryGetResult(resourceQueryID, 0));

    if (SameAG(there, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) == true)
        return(-1);
    if (resourceID==cResourceGold)
    {
        static vector gTransportToGoldPos = cInvalidVector;
        if (equal(gTransportToGoldPos, there))
            return(-1);
    }
    else if (resourceID==cResourceWood)
    {
        static vector gTransportToWoodPos = cInvalidVector;
        if (equal(gTransportToWoodPos, there))
            return(-1);
    }

    int startBaseID = -1;
    if ( oldResourceBase >= 0 )
        startBaseID = oldResourceBase;
    else
        startBaseID = kbBaseGetMainID(cMyID);
    vector here=kbBaseGetLocation(cMyID, startBaseID);
    int startAreaID=kbAreaGetIDByPosition(here);
    if ((startAreaID == -1) || (startBaseID == -1))
        return(-1);
    int resourceTransportPlan = -1;
    resourceTransportPlan=createTransportPlan("Remote Resource Transport", startAreaID, kbAreaGetIDByPosition(there), false, cUnitTypeTransport, 80, startBaseID);

    int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
    int numVills = 0.5 + aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, resourceID) * gathererCount;
    if (cMyCulture == cCultureAtlantean)
    {
        if (numVills > 3)
            numVills = 3;
        else if ((cMyCulture == cCultureAtlantean) && (numVills <= 1))
            numVills = 1;
    }
    else
    {
        if (numVills > 12)
            numVills = 12;
        else if (numVills <= 6)
            numVills = 6;
    }
    aiPlanAddUnitType(resourceTransportPlan, cUnitTypeAbstractVillager, numVills, numVills, numVills);
    if ( cMyCulture == cCultureNorse )
        aiPlanAddUnitType( resourceTransportPlan, cUnitTypeOxCart, 1, 1, 1 );

    aiPlanSetRequiresAllNeedUnits( resourceTransportPlan, true );
    aiPlanSetActive(resourceTransportPlan);

    if (resourceID==cResourceGold)
        gTransportToGoldPos = there;
    else
        gTransportToWoodPos = there;

    string basename="";
    if (resourceID==cResourceGold)
        basename="Gold Base"+kbBaseGetNextID();
    else
        basename="Wood Base"+kbBaseGetNextID();

    int newBaseID=kbBaseCreate(cMyID, basename, there, gMaximumBaseResourceDistance);
    if (newBaseID > -1)
    {
        kbBaseSetEconomy(cMyID, newBaseID, true);
        kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
    }
    return(newBaseID);
}

bool IsImpossiblePoint(vector TestLocation = cInvalidVector)
{
    return((xsVectorGetX(TestLocation) < 0.0) || (xsVectorGetZ(TestLocation) < 0.0));
}

int CreateBaseInBackLoc(int BaseID = -1, float Distance = 0, float baseRadius = 25, string Name = "INVALID NAME")
{
    vector backVector=kbBaseGetBackVector(cMyID, BaseID);
    vector position = kbBaseGetLocation(cMyID, BaseID);
    int NewDistance = Distance;
    bool Success = false;
    for (i = 0; < 30) // test it a few times so we don't fall out of the map!
    {
        backVector=kbBaseGetBackVector(cMyID, BaseID);
        float x = xsVectorGetX(backVector);
        float z = xsVectorGetZ(backVector);
        x = x * NewDistance;
        z = z * NewDistance;
        backVector = xsVectorSetX(backVector, x);
        backVector = xsVectorSetZ(backVector, z);
        backVector = xsVectorSetY(backVector, 0.0);
        vector location = kbBaseGetLocation(cMyID, BaseID);
        location = location + backVector;
        int AreaGroupBase = kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, BaseID));
        int AreaGroupNewLoc=kbAreaGroupGetIDByPosition(location);
        int Trees = getNumUnits(cUnitTypeTree, cUnitStateAny, -1, 0, location, 3);
        if ((IsImpossiblePoint(location) == false) && (AreaGroupBase == AreaGroupNewLoc) && (kbCanPath2(position, location, cUnitTypeHoplite) == true) && (Trees <= 0) || (baseRadius == 0))
        {
            Success = true;
            break;
        }
        NewDistance = NewDistance - 1;
    }
    if ((Success == false) || (NewDistance < 0))
        return(-1);

    int Base = kbBaseCreate(cMyID, ""+Name, location, baseRadius);
    kbBaseSetEconomy(cMyID, Base, true);
    kbBaseSetMaximumResourceDistance(cMyID, Base, baseRadius);
    kbBaseSetActive(cMyID, Base, true);
    aiEcho("A New Base was successfully created! *** Name:  "+Name+",  ID:  "+Base+",  Final distance:  "+NewDistance+".");
    return(Base);
}

// Stolen from BD :)
int getRandomPlayerByRel(int Relation = -1, int exludePlayer = -1, bool InfiniteAIAllyReq = false)
{
    int retVal = -1;
    int matchCount = 0;
    int matchIndex = -1;

    for (matchIndex = 1; < cNumberPlayers)
    {
        if ((InfiniteAIAllyReq == false) && (Relation == cPlayerRelationAlly) && (kbIsPlayerAlly(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != cMyID) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
        if ((InfiniteAIAllyReq == true) && (aiPlanGetUserVariableInt(gSomeData, PlayersData+matchIndex, 0) == 1) && (Relation == cPlayerRelationAlly)
            && (kbIsPlayerAlly(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != cMyID) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
        if ((Relation == cPlayerRelationEnemy) && (kbIsPlayerEnemy(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != 0) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
    }
    if (matchCount < 1)
        return(-1);

    int playerToGet = aiRandInt(matchCount) + 1;
    matchCount = 0;
    for (matchIndex = 1; < cNumberPlayers)
    {
        if ((InfiniteAIAllyReq == false) && (Relation == cPlayerRelationAlly) && (kbIsPlayerAlly(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != cMyID) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
        if ((InfiniteAIAllyReq == true) && (aiPlanGetUserVariableInt(gSomeData, PlayersData+matchIndex, 0) == 1) && (Relation == cPlayerRelationAlly)
            && (kbIsPlayerAlly(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != cMyID) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
        if ((Relation == cPlayerRelationEnemy) && (kbIsPlayerEnemy(matchIndex) == true) && (kbHasPlayerLost(matchIndex) == false) && (matchIndex != 0) && (matchIndex != exludePlayer))
            matchCount = matchCount + 1;
        if (matchCount == playerToGet)
        {
            retVal = matchIndex;
            break;
        }
    }
    return(retVal);
}


//==============================================================================
// Comms  // taken from Noton <3, patched to use the EventHandler instead.
//==============================================================================
bool MessageRel(int cPlayerRelation = -1, int Prompt = -1, int Other = -1, vector location = cInvalidVector)
{
    bool Success = false;
    switch(cPlayerRelation)
    {
    case cPlayerRelationAlly:
    {
        for (i=0; < cNumberPlayers)
        {
            if (i == cMyID)
                continue;
            if ((kbIsPlayerMutualAlly(i) == true) && (kbIsPlayerResigned(i) == false) &&
                (kbIsPlayerValid(i) == true) && (kbHasPlayerLost(i) == false) && (kbIsPlayerHuman(i) == false))
            {
                if (Other == VectorData)
                    aiCommsSendOrderWithVector(i, Prompt, VectorData, location);
                else
                    aiCommsSendOrder(i, Prompt, Other);
                Success = true;
            }
        }
    }
    }
    if (Success == true)
        return(true);
    else
        return(false);
}

//==============================================================================
bool MessagePlayer(int PlayerID = -1, int Prompt = -1, int Other = -1, vector location = cInvalidVector)
{
    bool Success = false;
    if ((PlayerID == cMyID) || (PlayerID <= 0))
        return(false);

    if ((kbIsPlayerMutualAlly(PlayerID) == true) && (kbIsPlayerResigned(PlayerID) == false) &&
        (kbIsPlayerValid(PlayerID) == true) && (kbHasPlayerLost(PlayerID) == false) && (kbIsPlayerHuman(PlayerID) == false))
    {
        if (Other == VectorData)
            aiCommsSendOrderWithVector(PlayerID, Prompt, VectorData, location);
        else
            aiCommsSendOrder(PlayerID, Prompt, Other);
        Success = true;
    }
    if (Success == true)
        return(true);
    else
        return(false);
}

void Comms(int PlayerID = -1)
{
    int iSenderID = aiCommsGetRecordPlayerID(PlayerID);
    if ((kbIsPlayerMutualAlly(iSenderID) == true) && (kbIsPlayerValid(iSenderID) == true) && (kbHasPlayerLost(iSenderID) == false))
    {
        int iPromptType = aiCommsGetRecordPromptType(PlayerID);
        int iUserData = aiCommsGetRecordData(PlayerID);
        vector iPos = aiCommsGetRecordPosition(PlayerID);
        echo("AI Comms: Message received: From Player: "+iSenderID+", prompt "+iPromptType+", data "+iUserData+", vector "+iPos+".");

        if ((iPromptType == Tellothers) || (iPromptType == admiralTellothers))
        {
            InfiniteAIAllies = true;
            string PlayerType = "Undefined";
            if (iPromptType == Tellothers)
                PlayerType = "InfiniteAI";
            if (iPromptType == admiralTellothers)
                PlayerType = "AdmiralAI";

            aiPlanSetUserVariableInt(gSomeData, PlayersData+iSenderID, 0, 1);
            aiEcho("AI Comms: Player "+iSenderID+" is an allied "+PlayerType+" player, communication is possible! :)");
        }

        else if (iPromptType == AttackTarget)
        {
            if ((aiGetCaptainPlayerID(cMyID) != cMyID) || (iUserData == -1))
                return;
            aiSetMostHatedPlayerID(iUserData);
            ChangeMHP = true;
            MHPTime = xsGetTime();
        }
        else if (iPromptType == cAttackTC)
        {
            if ((aiGetCaptainPlayerID(cMyID) == cMyID) || (iUserData < 0))
                return;
            aEnemyTCID = iUserData;
            aLastTCIDTime = xsGetTime();
            echo("AI Comms: Player "+iSenderID+" is asking us to assist on tcid: "+iUserData);
            if (aiPlanGetState(gEnemySettlementAttPlanID) != -1)
            {
                int Owner = kbUnitGetOwner(aEnemyTCID);
                if ((Owner > 0) && (kbIsPlayerEnemy(Owner) == true))
                {
                    aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, aEnemyTCID);
                    aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanPlayerID, 0, Owner);
                }
            }
        }

        else if (iPromptType == INeedHelp)
        {
            if ((iUserData == -1) || (findPlanByString("alliedBaseDefPlan", cPlanDefend) != -1))
                return;
            HelpSettleID = iUserData;
            xsSetRuleMinInterval("defendAlliedBase", 0);
            xsEnableRule("defendAlliedBase");
            echo("AI Comms: Player "+iSenderID+" is asking for help at TC id "+iUserData);
        }

        else if (iPromptType == RequestTower)
        {
            if ((iUserData == VectorData) && (equal(iPos, cInvalidVector) == false) && (kbCanAffordUnit(cUnitTypeTower, cMilitaryEscrowID) == true))
            {
                int mainBaseID = kbBaseGetMainID(cMyID);
                vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
                if ((gTransportMap == true) && (SameAG(iPos, mainBaseLocation) == false)) // transport and can't reach?
                    return;
                int NumBThatShoots = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cMyID, iPos, 75.0);
                int ActiveBPlan = findPlanByString("TowerRequested", cPlanBuild);
                int allowconstructors = 15;
                if (cMyCulture == cCultureAtlantean)
                    allowconstructors = 5;
                int numGatherers = kbUnitCount(cMyID,cBuilderType, cUnitStateAlive);

                if ((ActiveBPlan  == -1) && (NumBThatShoots < 2) && (kbGetAge() > cAge2) && (numGatherers > allowconstructors))
                {
                    int TowerPlan=aiPlanCreate("TowerRequested", cPlanBuild);
                    if (TowerPlan < 0)
                        return;
                    int Building = cUnitTypeTower;
                    if ((cMyCulture == cCultureAtlantean) && (kbGetTechStatus(cTechAge4Helios) == cTechStatusActive) && (kbUnitCount(cMyID, cUnitTypeTowerMirror, cUnitStateAliveOrBuilding) < 10))
                        Building = cUnitTypeTowerMirror;
                    if ((aiRandInt(4) < 3) && (kbCanAffordUnit(MyFortress, cMilitaryEscrowID) == true) && (kbUnitCount(cMyID, MyFortress, cUnitStateAliveOrBuilding) < 9))
                        Building = MyFortress;
                    aiPlanSetVariableInt(TowerPlan, cBuildPlanBuildingTypeID, 0, Building);
                    aiPlanSetVariableInt(TowerPlan, cBuildPlanMaxRetries, 0, 5);
                    aiPlanSetVariableInt(TowerPlan, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(iPos));
                    aiPlanSetVariableFloat(TowerPlan, cBuildPlanRandomBPValue, 0, 0.99);
                    aiPlanSetVariableVector(TowerPlan, cBuildPlanInfluencePosition, 0, iPos);
                    aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluencePositionDistance, 0, 25.0);
                    aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluencePositionValue, 0, 1.0);
                    aiPlanSetVariableInt(TowerPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuildingsThatShoot);
                    aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluenceUnitDistance, 0, 12);
                    aiPlanSetVariableFloat(TowerPlan, cBuildPlanInfluenceUnitValue, 0, -20.0);
                    aiPlanSetDesiredPriority(TowerPlan, 80);
                    aiPlanSetEscrowID(TowerPlan, cMilitaryEscrowID);
                    if (cMyCulture == cCultureAtlantean)
                        aiPlanAddUnitType(TowerPlan, cBuilderType, 1, 1, 1);
                    else aiPlanAddUnitType(TowerPlan, cBuilderType, 1, 2, 2);
                    aiPlanSetActive(TowerPlan);
                    echo("AI Comms: Player "+iSenderID+" is requesting a tower over at the following location: "+iPos);
                }
                if ((ActiveBPlan != -1) && (numGatherers <= allowconstructors))
                    aiPlanDestroy(TowerPlan);
            }
        }

        else if ((iPromptType == RequestFood) || (iPromptType == RequestWood) || (iPromptType == RequestGold))
        {
            if ((ShouldIAgeUp() == true) && (iUserData != cEmergency))
                return;
            int AmountToSend = 0.0;
            float Percentage = 0.40;
            if (iUserData == cLowPriority)
                Percentage = 0.15;
            else if (IsTechActive(cTechAmbassadors) == true)
                Percentage = 0.50;

            switch(iPromptType)
            {
            case RequestFood:
            {
                AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceFood) * Percentage;
                if ((AmountToSend > 50.0) && (kbResourceGet(cResourceFood) >= 300))
                {
                    if (AmountToSend > 1200)
                        AmountToSend = 1200;
                    aiTribute(iSenderID, cResourceFood, AmountToSend);
                    gLastSentTime = xsGetTime();
                    echo("AI Comms: Donated "+AmountToSend+" Food to player "+iSenderID);
                    updateGlutRatio();
                }
                break;
            }
            case RequestWood:
            {
                AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceWood) * Percentage;
                if ((AmountToSend > 50.0) && (kbResourceGet(cResourceWood) >= 300))
                {
                    if (AmountToSend > 1200)
                        AmountToSend = 1200;
                    aiTribute(iSenderID, cResourceWood, AmountToSend);
                    gLastSentTime = xsGetTime();
                    echo("AI Comms: Donated "+AmountToSend+" Wood to player "+iSenderID);
                    updateGlutRatio();
                }
                break;
            }
            case RequestGold:
            {
                AmountToSend = kbEscrowGetAmount(cRootEscrowID, cResourceGold) * Percentage;
                if ((AmountToSend > 50.0) && (kbResourceGet(cResourceGold) >= 300))
                {
                    if (AmountToSend > 1200)
                        AmountToSend = 1200;
                    aiTribute(iSenderID, cResourceGold, AmountToSend);
                    gLastSentTime = xsGetTime();
                    echo("AI Comms: Donated "+AmountToSend+" Gold to player "+iSenderID);
                    updateGlutRatio();
                }
                break;
            }
            }
        }
        else if ((iPromptType == ExtraFood) || (iPromptType == ExtraWood) || (iPromptType == ExtraGold))
        {
            switch(iPromptType)
            {
            case ExtraFood:
            {
                if (kbResourceGet(cResourceFood) < 600)
                    MessagePlayer(iSenderID, RequestFood);
                break;
            }
            case ExtraWood:
            {
                if (kbResourceGet(cResourceWood) < 600)
                    MessagePlayer(iSenderID, RequestWood);
                break;
            }
            case ExtraGold:
            {
                if (kbResourceGet(cResourceGold) < 600)
                    MessagePlayer(iSenderID, RequestGold);
                break;
            }
            }
        }
    }
}


// Math.xs file by WarriorMario
//=================================================================================================================================
// Math.xs
// Creator: WarriorMario
//
// Created with ADE v0.08
//=================================================================================================================================

//=================================================================================================================================
// Variables
extern const float PI = 3.14159265358979323846;
extern const float nPI = -3.14159265358979323846;
extern const float PI_2 = 1.57079632679489661923;
extern const float nPI_2 = -1.57079632679489661923;
extern const float PI_4 = 0.78539816339744830962;
extern const float nPI_4 = -0.78539816339744830962;
//=================================================================================================================================

//=================================================================================================================================
// Checks if number lies between 2 other numbers
//=================================================================================================================================
bool inRange(float x = 0, float top = 0, float bottom = 0)
{
    if(x>top)
    {
        return(false);
    }
    if(x<bottom)
    {
        return(false);
    }
    return(true);
}
//=================================================================================================================================
// Convert degrees to radians
//=================================================================================================================================
float deg2Rad(float x = 0)
{
    return(x*(PI/180));
}

float rad2Deg(float x = 0)
{
    return(x*(180/PI));
}
//=================================================================================================================================
// Correctly clamps a radian between 0 and 2PI so we can use it to calculate sin and cos
//=================================================================================================================================
float clampRad(float x = 0)
{
    int PIs = -1;
    if(x>0.0)
    {
        PIs = x/(2.0*PI);
        return(x-(2.0*PI)*PIs);
        
    }
    else
    {
        PIs = x/(2.0*PI)-1;
        return(x-(2.0*PI)*PIs);
    }
}

//=================================================================================================================================
// Correctly clamps a degree between 0 and 360 so we can use it to calculate sin and cos
//=================================================================================================================================
float clampDeg(float x = 0)
{
    int PIs = -1;
    if(x>0.0)
    {
        PIs = x/360.0;
        return(x-360.0*PIs);
        
    }
    else
    {
        PIs = (x/360.0)-1;
        return(x-360.0*PIs);
    }
}

//=================================================================================================================================
// cos2 to quickly fix the float rounding error
//=================================================================================================================================
float cos2(float x = 0)
{
    // If we're between 0 and PI_2
    if(inRange(x, PI_2, 0))
    {
        return(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720); 
    }
    // If we're between PI_2 and PI
    if(inRange(x,PI_2,PI))
    {
        x = PI_2-(x-PI_2);
        return(-1.0*(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720)); 

    }
    // If we're between PI and 3PI_2
    if(inRange(x,PI, 3.0*PI_2))
    {
        x = x-PI;
        return(-1.0*(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720)); 

    }
    // If we're between 3PI_2 and 2PI
    if(inRange(x,3.0*PI_2,2.0*PI))
    {
        x = x-PI;
        x = PI_2-(x-PI_2);  
        return(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720); 
    }
}

//=================================================================================================================================
// Calculates sin using a Taylor serie
// Uses radians and needs to be between 0 and 2PI
//=================================================================================================================================
float sin(float x = 0)
{
    x = clampRad(x);
    // If we're between 0 and PI_2
    if(inRange(x, PI_2, 0))
    {
        if(x<PI_4)
        {
            return(x-(x*x*x)/6.0+(x*x*x*x*x)/120.0-(x*x*x*x*x*x*x)/5040.0); 
        }
        else
        {
            return(cos2(PI_2-x));
        }
    }
    // If we're between PI_2 and PI
    if(inRange(x,PI,PI_2))
    {
        x = PI_2-(x-PI_2);
        if(x<PI_4)
        {
            return(x-(x*x*x)/6.0+(x*x*x*x*x)/120.0-(x*x*x*x*x*x*x)/5040.0); 
        }
        else
        {
            return(cos2(PI_2-x));
        }
    }
    // If we're between PI and 3PI_2
    if(inRange(x,3.0*PI_2, PI))
    {
        x = x-PI;
        if(x<PI_4)
        {
            return(-1.0*(x-(x*x*x)/6.0+(x*x*x*x*x)/120.0-(x*x*x*x*x*x*x)/5040.0)); 
        }
        else
        {
            return(-1.0*cos2(PI_2-x));
        }
    }
    // If we're between 3PI_2 and 2PI
    if(inRange(x,2.0*PI,3.0*PI_2))
    {
        x = x-PI;
        x = PI_2-(x-PI_2);  
        if(x<PI_4)
        {
            return(-1.0*(x-(x*x*x)/6.0+(x*x*x*x*x)/120.0-(x*x*x*x*x*x*x)/5040.0)); 
        }
        else
        {
            return(-1.0*cos2(PI_2-x));
        }
    }
}


//=================================================================================================================================
// Calculates cos using a Taylor serie
// Uses radians and needs to be between 0 and 2PI
//=================================================================================================================================

float cos(float x = 0)
{
    x = clampRad(x);
    // If we're between 0 and PI_2
    if(inRange(x, PI_2, 0))
    {
        if(x<PI_4)
        {
            return(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720.0); 
        }
        else
        {
            return(sin(PI_2-x));
        }
    }
    // If we're between PI_2 and PI
    if(inRange(x,PI,PI_2))
    {
        x = PI_2-(x-PI_2);
        if(x<PI_4)
        {
            return(-1.0*(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720.0)); 
        }
        else
        {
            return(-1.0*sin(PI_2-x));
        }
    }
    // If we're between PI and 3PI_2
    if(inRange(x,3.0*PI_2,PI))
    {
        x = x-PI;
        if(x<PI_4)
        {
            return(-1.0*(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720.0)); 
        }
        else
        {
            return(-1.0*sin(PI_2-x));
        }
    }
    // If we're between 3PI_2 and 2PI
    if(inRange(x,2.0*PI,3.0*PI_2))
    {
        x = x-PI;
        x = PI_2-(x-PI_2);  
        if(x<PI_4)
        {
            return(1.0-(x*x)/2+(x*x*x*x)/24-(x*x*x*x*x*x)/720.0); 
        }
        else
        {
            return(sin(PI_2-x));
        }
    }
}

//=================================================================================================================================
// lowest
// returns the lowest of the 2 parameters
//=================================================================================================================================
float mathMin(float x = 0, float y = -1)
{
    if(x>y)
    {
        return(y);
    }
    return(x);
}

//=================================================================================================================================
// highest
// returns the highest of the 2 parameters
//=================================================================================================================================
float mathMax(float x = 0, float y = -1)
{
    if(x>y)
    {
        return(x);
    }
    return(y);
}


//=================================================================================================================================
// sq
// returns the square of the given parameter
//=================================================================================================================================
float sq(float x = -1)
{
    return(x*x);
}

//=================================================================================================================================
// sqr
// returns the square root of the given parameter
//=================================================================================================================================
float sqr(float x = -1)
{
    return(xsVectorLength(xsVectorSet(x,0,0)));
}

