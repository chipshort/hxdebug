package tests;

import debug.net.socket.AsyncDebugServer;
import haxe.PosInfos;

class ServerTest extends haxe.unit.TestCase
{
    var main : ServerMain;
    
    public function new(m : ServerMain)
    {
        super();
        main = m;
    }

    function assertDeepEq<T>(expected: T , actual: T,  ?c : PosInfos) : Void
    {
        currentTest.done = true;
		if (!deepEquals(actual, expected)) {
			currentTest.success = false;
			currentTest.error   = "expected '" + expected + "' but was '" + actual + "'";
			currentTest.posInfos = c;
			throw currentTest;
		}
    }

    function deepEquals<T>(v1 : T, v2 : T) : Bool
    {
        return haxe.Serializer.run(v1) == haxe.Serializer.run(v2);
    }
}