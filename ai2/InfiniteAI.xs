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
include "InfiniteAIglobals.xs";
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
include "InfiniteAIEconEscrow.xs";

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


include "InfiniteAIInit.xs";
include "InfiniteAIAgeHandlers.xs";


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
