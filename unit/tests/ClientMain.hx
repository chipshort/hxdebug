package tests;

class ClientMain
{
    var reader(get, null) : haxe.io.Input = null;
    
    function get_reader() : haxe.io.Input
    {
        throw "exception";
    }
    
    static function main() : Void
    {
        new ClientMain();
        throw "Error, testing";
    }

    function new()
    {
        testBreakPoint();
    }
    
    public function testBreakPoint() : Void
    {
        var i = ClientMain;
        var b = {
            test: 2,
            cls: i
        }
        debug.DebugMacro.breakPoint();var a = "Client finished";
        
        trace (a);
    }
}
