package tests;

class ServerMain
{
    public var debugData : List<Dynamic>;

    static function main() : Void
    {
        // var server = new debug.net.socket.AsyncDebugServer();
        // server.onBreakPoint = function (context) {
        //     debugData.push(context);
        // }
        // server.onException = function (context) {
        //     trace("Exception thrown!");
        //     trace(context.error);
        //     trace(context.context.pos);

        //     Sys.stdin().readLine();
        //     server.doContinue();
        // }

        // server.listen();

        // var r = new haxe.unit.TestRunner();
        // r.add(new tests.BreakPointTest(server));
        
        // r.run();

        // server.stop();
        new ServerMain();
    }

    function new()
    {
        debugData = new List<Dynamic>();
        var connections = 0;
        var expectedConnections = 2;

        var server = new debug.net.socket.DebugServer();
        server.onBreakPoint = function (context) {
            debugData.add(context);
            server.doContinue();
        }
        server.onException = function (context) {
            debugData.add(context);
            server.doContinue();
        }

        server.onClientDisconnected = function () {
            connections++;
            if (connections == expectedConnections)
                server.stop();
        }

        server.listen();

        trace(debugData.length);

        var r = new haxe.unit.TestRunner();
        r.add(new tests.BreakPointTest(this));
        r.add(new tests.ExceptionTest(this));
        
        r.run();
    }
}
