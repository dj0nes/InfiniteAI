// the main AI file, can be used as a target for scenarios
// select a personality-specific file instead to avoid random selection

include "InfiniteAIglobals.xs"; // global and const declarations
include "InfiniteUtils.xs";
include "InfiniteAIBasics.xs"; // utilities
include "InfiniteAIExtra.xs"; // Reth rules
include "InfiniteAIBuild.xs"; // BuildRules
include "InfiniteAIEcon.xs";
include "InfiniteAIEconForecastUtils.xs";
include "InfiniteAIEconEscrow.xs";
include "InfiniteAIGPs.xs"; // God Powers
include "InfiniteAIMapSpec.xs"; // Map Specifics
include "InfiniteAIMil.xs"; // Military
include "InfiniteAINaval.xs"; // naval
include "InfiniteAIPers.xs"; // personality
include "InfiniteAIProgr.xs"; // Progress
include "InfiniteAITechs.xs"; //TechRules Include
include "InfiniteAITrain.xs"; // trainRules Include
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


rule initAfterDelay // init ai setup after this number of seconds, used to check population
inactive
        minInterval 1
{
    echo("initAfterDelay at time " + xsGetTime());
    initInfinitePopModeCheck(); // can use infinitePopMode variable after this
    init();
    xsDisableSelf();
}
