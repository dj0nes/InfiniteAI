//=================================================================================================================================
// Vector2.xs
// Creator: WarriorMario
//
// Created using the ADE v0.08
//=================================================================================================================================

//=================================================================================================================================
// Variables
// Debug
extern bool debugVector2 = false;
// Map data
extern float mapSizeX = -1;
extern float mapSizeZ = -1;
extern vector mapCenter = cInvalidVector;
extern int mainBaseIndexOnMap = -1;
extern int mapCornerArray = -1;
//=================================================================================================================================

//=================================================================================================================================
// Functions
bool pointInRectangle(vector point = cInvalidVector, float left = -1.0, float top = -1.0, float right = -1.0, float bottom = -1.0)
{
    float pointX = xsVectorGetX(point);
    if(pointX < left)
    {
        return(false);
    }
    if(pointX>right)
    {
        return(false);
    }
    float pointZ = xsVectorGetZ(point);
    if(pointZ < bottom)
    {
        return(false);
    }
    if(pointZ > top)
    {
        return(false);
    }
    return(true);
}

bool pointOnMap(vector location = cInvalidVector)
{
    float locationX = xsVectorGetX(location);
    return(pointInRectangle(location,0,kbGetMapZSize(),kbGetMapXSize(),0));
}

vector clampPointToMap(vector point = cInvalidVector)
{
    return(xsVectorSet( mathMax(mathMin(xsVectorGetX(point),mapSizeX),0), xsVectorGetY(point), mathMax(mathMin(xsVectorGetZ(point),mapSizeZ),0) ));
}

float vec2LenSq(vector vec2 = cInvalidVector)
{
    return((xsVectorGetX(vec2)*xsVectorGetX(vec2))+(xsVectorGetZ(vec2)*xsVectorGetZ(vec2)));
}

float vec2Cross(vector v0 = cInvalidVector, vector v1 = cInvalidVector)
{
    return(xsVectorGetX(v0)*xsVectorGetZ(v1) - xsVectorGetZ(v0)*xsVectorGetX(v1));
}

vector movePointToPoint(vector v0= cInvalidVector, vector v1 = cInvalidVector, float percentage = -1.0)
{
    float x = xsVectorGetX(v0);
    float z = xsVectorGetZ(v0);
    return(xsVectorSet(x + percentage*(xsVectorGetX(v1)-x),0.0,z + percentage*(xsVectorGetZ(v1)-z)));
}

bool pointInRangeOfPoint(vector v0 = cInvalidVector, vector v1 = cInvalidVector, float range = -1.0)
{
    return(vec2LenSq(v0-v1)<=range*range);
}

bool vec2Equal(vector v0 = cInvalidVector, vector v1 = cInvalidVector)
{
    if(xsVectorGetX(v0)!=xsVectorGetX(v1))
    {
        return(false);
    }
    if(xsVectorGetZ(v0)!=xsVectorGetZ(v1))
    {
        return(false);
    }
    return(true);
}


// // Ignores height
// bool arraySortVectorClosestToPoint(int array=-1,vector center = cInvalidVector)
// {
//     int size               = arrayGetSize(array);
//     float shortestDistance = 999999999;
//     for (i = 0; < size) 
//     {
//         int k = i;
//         for (j=i + 1; < size) 
//         {
//             if (vec2LenSq(arrayGetVector(array,j)-center)<vec2LenSq(arrayGetVector(array,k)-center))
//             {
//                 k = j;
//             }
//         }
//         vector temp = arrayGetVector(array,i);
//         arraySetVector(array,i,arrayGetVector(array,k));
//         arraySetVector(array,k,temp);
//     }
// }
