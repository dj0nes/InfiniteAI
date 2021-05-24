bool haveCheckedInfiniteMode = false;
extern bool infinitePopMode = false;

bool initInfinitePopModeCheck(void) {
    infinitePopMode = kbGetPop() == 0;
}

void echo(string msg="") {
    if(ShowAIDebug) {
        aiEcho(msg);
    }
}
