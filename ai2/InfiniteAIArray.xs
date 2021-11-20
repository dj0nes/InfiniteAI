//=================================================================================================================================
// Array.xs
// Creator: WarriorMario
//
// Created with ADE v0.08
//=================================================================================================================================
const bool cvArrayDebug = true;

const extern int cArrayDataType = 0;

const extern int cArrayTypeInvalid = -1;
const extern int cArrayTypeType = 0;
const extern int cArrayTypeInt = 1;
const extern int cArrayTypeFloat = 2;
const extern int cArrayTypeVector = 3;

extern int gArrayData = -1;

mutable bool arraySortVectorClosestToPoint(int array=-1,vector center = cInvalidVector) {}

void echoArray(string msg = "")
{
    if(cvArrayDebug)
    {
        aiEcho(msg);
    }
}

int arrayCreate(int type = -1)
{
    int index = aiPlanGetNumberUserVariableValues(gArrayData,cArrayDataType);
    switch(type)
    {
        case cArrayTypeInt:
        {
            aiPlanAddUserVariableInt(gArrayData,index,"Int array",1);
            break;
        }
        case cArrayTypeFloat:
        {
            aiPlanAddUserVariableFloat(gArrayData,index,"Float array",1);
            break;
        }
        case cArrayTypeVector:
        {
            aiPlanAddUserVariableVector(gArrayData,index,"Vector array",1);
            break;
        }
        default:
        {
            echoArray("Array creation failed because type "+type+" is invalid");
            return(-1);
        }
    }
    aiPlanAddUserVariableInt(gArrayData,cArrayDataType,type);
    return(index);
}

int arrayGetSize(int array = -1)
{
    return(aiPlanGetNumberUserVariableValues(gArrayData,array));
}

bool arrayOfType(int array = -1, int type=-1)
{
    return(aiPlanGetUserVariableInt(gArrayData,cArrayDataType,array)==type);
}

bool arrayIndexIsValid(int array = -1, int index = -1)
{
    return(arrayGetSize(array)>index);
}

bool arrayAddInt(int array = -1, int value = -1)
{
    if(arrayOfType(array,cArrayTypeInt)==false)
    {
        echoArray("Could not add int to array "+ array + " because it is not of type int");
        return(false);
    }
    aiPlanAddUserVariableInt(gArrayData,array,value);
}

bool arrayAddFloat(int array = -1, float value = -1.0)
{
    if(aiPlanGetUserVariableInt(gArrayData,cArrayDataType,array)!=cArrayTypeFloat)
    {
        echoArray("Could not add int to array "+ array + " because it is not of type float");
        return(false);
    }
    aiPlanAddUserVariableFloat(gArrayData,array,value);
}

bool arrayAddVector(int array = -1, vector value = cInvalidVector)
{
    if(aiPlanGetUserVariableInt(gArrayData,cArrayDataType,array)!=cArrayTypeVector)
    {
        echoArray("Could not add int to array "+ array + " because it is not of type vector");
        return(false);
    }
    aiPlanAddUserVariableVector(gArrayData,array,value);  
}

int arrayGetVectorIndexByElement(int array=-1,int elementIndex=-1,float value = -1.0)
{
    if(arrayOfType(array,cArrayTypeVector)==false)
    {
        echoArray("Could not add int to array "+ array + " because it is not of type int");
        return(-1);
    }
    return(aiPlanGetUserVariableVector(gArrayData, array, elementIndex,value));
}

bool arrayIncrementVectorElement(int array=-1,int index=-1, int elementIndex=-1)
{
    
    aiEcho("NOT IMPLEMENTED - MISSING FUNCTION aiPlanIncrementUserVariableVectorElement")
    // if(arrayOfType(array,cArrayTypeVector)==false)
    // {
    //     echoArray("Could not add int to array "+ array + " because it is not of type int");
    //     return(false);
    // }
    // return(aiPlanIncrementUserVariableVectorElement(gArrayData, array, index,elementIndex));
}

int arrayGetInt(int array = -1, int index = -1)
{
    if(arrayOfType(array,cArrayTypeInt)==false)
    {
        echoArray("Could not get int of array "+ array + " because it is not of type int");
        return(false);
    }
    return(aiPlanGetUserVariableInt(gArrayData,array,index));
}

vector arrayGetVector(int array = -1, int index = -1)
{
    if(arrayOfType(array,cArrayTypeVector)==false)
    {
        echoArray("Could not get vector of array "+ array + " because it is not of type vector");
        return(cInvalidVector);
    }
    return(aiPlanGetUserVariableVector(gArrayData,array,index));
}

bool arraySetVector(int array = -1, int index = -1, vector value = cInvalidVector)
{
    if(arrayOfType(array,cArrayTypeVector)==false)
    {
        echoArray("Could not set vector of array "+ array + " because it is not of type vector");
        return(false);
    }
    if(arrayIndexIsValid(array,index) == false)
    {
        echoArray("Index out of range: "+ index+ " of array: "+array);
        return(false);
    }
    return(aiPlanSetUserVariableVector(gArrayData,array,index,value));
}

bool arrayDestroy(int array = -1)
{
    aiPlanSetUserVariableInt(gArrayData,cArrayDataType,array,cArrayTypeInvalid);
    aiPlanRemoveUserVariable(gArrayData,array);
}

void initArray()
{
    gArrayData = aiPlanCreate("Array Data", cPlanData);
    aiPlanAddUserVariableInt(gArrayData,cArrayDataType,"Array type",1);
    aiPlanAddUserVariableInt(gArrayData,cArrayDataType,cArrayTypeType);
}
