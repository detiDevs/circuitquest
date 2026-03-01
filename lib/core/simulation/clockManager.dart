class Clockmanager {
  int _currentTick = 0;
  late final int ticksPerClockCycle;

  Clockmanager({this.ticksPerClockCycle = 0});

  bool tickAndCheckClock(){
    _currentTick++;
    if (ticksPerClockCycle > 0 && _currentTick >= ticksPerClockCycle){
      _currentTick = 0;
      // trigger components with return
      return true;
    }
    return false;
  }
}