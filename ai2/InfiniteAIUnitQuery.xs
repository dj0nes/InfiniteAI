//=================================================================================================================================
// Unit Query.xs
// Creator: WarriorMario
//
// Created with ADE v0.08
//=================================================================================================================================

//=================================================================================================================================
// getUnitFromPlayer(int playerID, int unitType, int action, vector center)
// 
// Returns a unit of the given player,specified type, doing the specified action.
// Defaults = any unit, any action.
// Searches units owned by this player only, can include buildings.
// If a location is specified, the nearest matching unit is returned.
//=================================================================================================================================
int getUnitFromPlayer(int playerID = -1, int unitType = -1, vector center = vector(-1,-1,-1), float range = -1.0, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getUnitFromPlayer");
    }
    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);   // only my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);   // only if specified
        }
        if (center != vector(-1,-1,-1))
        {
            kbUnitQuerySetPosition(unitQueryID, center);
            if(range != -1.0)
            {
                kbUnitQuerySetMaximumDistance(unitQueryID, range);
            }
            kbUnitQuerySetAscendingSort(unitQueryID, true);
        }
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
        kbUnitQuerySetSeeableOnly(unitQueryID,visible);
    }
    else
    {
        xsSetContextPlayer(cMyID);
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateAliveOrBuilding);
    int count  = kbUnitQueryExecute(unitQueryID);
    // Pick a unit and return its ID, or return -1.
    if(count > 0)
    {
        int retval = -1;
        if (center != vector(-1,-1,-1))
        {
            retval = kbUnitQueryGetResult(unitQueryID, 0);
            xsSetContextPlayer(cMyID);
            return(retval);   // closest unit
        }
        else
        {
            retval = kbUnitQueryGetResult(unitQueryID, aiRandInt(count));
            xsSetContextPlayer(cMyID);
            return(retval);   // get the ID of a random unit
        }
    }
    else
    {
        xsSetContextPlayer(cMyID);
        return(-1);
    }
}

int getUnitArrayFromPlayer(int playerID = -1, int unitType = -1, vector center = vector(-1,-1,-1), float range = -1.0, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getUnitArrayFromPlayer");
    }
    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);   // only my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);   // only if specified
        }
        if (center != vector(-1,-1,-1))
        {
            kbUnitQuerySetPosition(unitQueryID, center);
            if(range != -1.0)
            {
                kbUnitQuerySetMaximumDistance(unitQueryID, range);
            }
            kbUnitQuerySetAscendingSort(unitQueryID, true);
        }
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
        kbUnitQuerySetSeeableOnly(unitQueryID,visible);
    }
    else
    {
        xsSetContextPlayer(cMyID);
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    int count  = kbUnitQueryExecute(unitQueryID);
    if(count > 0)
    {
        // Try to create an array
        int retArrayIndex = arrayCreate(cArrayTypeInt);
        for(i=0;<count)
        {
            arrayAddInt(retArrayIndex,kbUnitQueryGetResult(unitQueryID,i));
        }
        xsSetContextPlayer(cMyID);
        return(retArrayIndex);
    }
    else
    {
        xsSetContextPlayer(cMyID);
        return(-1);
    }
}

int getUnitsFromPlayer(int playerID = -1, int unitType = -1, vector center = vector(-1,-1,-1), float range = -1.0, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getUnitsFromPlayer");
    }
    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);   // only my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);   // only if specified
        }
        if (center != vector(-1,-1,-1))
        {
            kbUnitQuerySetPosition(unitQueryID, center);
            if(range != -1.0)
            {
                kbUnitQuerySetMaximumDistance(unitQueryID, range);
            }
            kbUnitQuerySetAscendingSort(unitQueryID, true);
        }
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
        kbUnitQuerySetSeeableOnly(unitQueryID,visible);
    }
    else
    {
        xsSetContextPlayer(cMyID);
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    return(unitQueryID);
}

int getNumUnitsFromPlayer( int playerID = -1, int unitType = -1, vector center = vector(-1,-1,-1),float range = -1.0, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getNumUnitsFromPlayer");
    }
    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);   // only my units
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);   // only my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);   // only if specified
        }
        if (center != vector(-1,-1,-1))
        {
            kbUnitQuerySetPosition(unitQueryID, center);
            if(range != -1.0)
            {
                kbUnitQuerySetMaximumDistance(unitQueryID, range);
            }
            kbUnitQuerySetAscendingSort(unitQueryID, true);
        }
        kbUnitQuerySetSeeableOnly(unitQueryID,visible);
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
    }
    else
    {
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    int num = kbUnitQueryExecute(unitQueryID);
    xsSetContextPlayer(cMyID);
    return(num);
}

int getNumUnitsFromPlayerInArea(int playerID = -1, int unitType = -1, int areaID = -1, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getNumUnitsFromPlayerInArea");
    } 

    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);// Default to my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);// Only if specified
        }
        if(areaID!=-1)
        {
            kbUnitQuerySetAreaID(unitQueryID,areaID);// Only if specified
        }
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
    }
    else
    {
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    xsSetContextPlayer(cMyID);
    return(kbUnitQueryExecute(unitQueryID));
}

int getNumUnitsFromPlayerInAreaGroup(int playerID = -1,int unitType = -1, int areaGroupID = -1, bool visible = true)
{
    if(visible==false)
    {
        xsSetContextPlayer(playerID);
    }
    static int unitQueryID = -1;
    if(unitQueryID==-1)
    {
        unitQueryID = kbUnitQueryCreate("getNumUnitsFromPlayerInAreaGroup");
    } 

    // Define a query to get all matching units
    if (unitQueryID != -1)
    {
        if(playerID != -1)
        {
            kbUnitQuerySetPlayerID(unitQueryID, playerID);
        }
        else
        {
            kbUnitQuerySetPlayerID(unitQueryID, cMyID);// Default to my units
        }
        if (unitType != -1)
        {
            kbUnitQuerySetUnitType(unitQueryID, unitType);// Only if specified
        }
        if(areaGroupID!=-1)
        {
            kbUnitQuerySetAreaGroupID(unitQueryID,areaGroupID);// Only if specified
        }
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
    }
    else
    {
        return(-1);
    }

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQueryExecute(unitQueryID);
    kbUnitQuerySetState(unitQueryID, cUnitStateBuilding);   // Add buildings in process
    xsSetContextPlayer(cMyID);
    return(kbUnitQueryExecute(unitQueryID));
}
