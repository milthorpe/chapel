use IO;

enum cleaningSupplies {MrClean, Windex, SoftScrub, mop, broom};
var item1: cleaningSupplies;
var item2: cleaningSupplies;

var f = open("freadEnum.txt", ioMode.r).reader(locking=false);

f.read(item1, item2);
writeln(item1, " ", item2);
