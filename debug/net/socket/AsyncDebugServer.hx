package debug.net.socket;

import debug.Data;

#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#end

//TODO: This needs to be tested more thoroughly, but it seems to work
class AsyncDebugServer extends DebugServer
{
    var thread : Thread;
    
    function asyncListen() : Void
    {
        s = new sys.net.Socket();
        s.bind(new sys.net.Host(DebugServer.host), DebugServer.port);
        s.listen(1);
        
        while (running) {
            c = s.accept();
            c.setBlocking(false);
            onClientConnected();

            try {
                while (true) {
                    var message = Thread.readMessage(false);
                    switch (message) {
                        case "stop":
                            running = false;
                            return;
                        case "doContinue":
                            super.doContinue();
                            break;
                        case "setVariable":
                            var name = Thread.readMessage(true);
                            var value = Thread.readMessage(true);
                            super.setVariable(name, value);
                    }
                    
                    try {
                        var l = c.input.readLine();

                        var message : Message = haxe.Json.parse(l);
                        onMessage(message.kind, message.data);
                    }
                    catch (e : Dynamic) {
                    }
                }
            }
            catch (e : Dynamic) {
            }
            onClientDisconnected();
        }
    }
    
    override public function stop() : Void
    {
        thread.sendMessage("stop");
    }
    
    override public function doContinue() : Void
    {
        thread.sendMessage("doContinue");
    }
    
    override public function setVariable(name : String, value : String) : Void
    {
        thread.sendMessage("setVariable");
        thread.sendMessage(name);
        thread.sendMessage(value);
    }
    
    override public function listen() : Void
    {
        thread = Thread.create(asyncListen);
    }
}
