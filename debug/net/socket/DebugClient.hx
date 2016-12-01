package debug.net.socket;

import debug.Data;
import debug.net.Message;

class DebugClient
{
    public static var the = new DebugClient();
    
    var s : sys.net.Socket;
    var run = true;
    
    function new()
    {
    }
    
    public function breakPoint(data : ContextData) : Void
    {
        connect();
        
        sendMessage("BREAKPOINT", data);
        
        loop();
    }
    
    public function exception(data : ExceptionData) : Void
    {
        connect();
        
        sendMessage("EXCEPTION", data);
        
        loop();
    }
    
    function loop() : Void
    {
        try {
            while (run) {
                var l = s.input.readLine();
                var msg = l.split(" ");
                
                var message : Message = haxe.Json.parse(l);
                onMessage(message.kind, message.data);
            }
        }
        catch (e : Dynamic) {
        }
        
        run = true; //reset for next time
    }
    
    function sendMessage(message : String, data : Dynamic) : Void
    {
        var msg : Message = {
            kind: message,
            data: data
        };
        s.write(haxe.Json.stringify(msg) + "\n");
    }
    
    function onMessage(message : String, data : Dynamic) : Void
    {
        switch (message) {
            case "CONTINUE":
                s.close();
                run = false;
            case "SET":
                
        }
    }
    
    inline function connect() : Void
    {
        try {
            s = new sys.net.Socket();
            s.connect(new sys.net.Host(DebugServer.host), DebugServer.port);
        }
        catch (e : Dynamic) {
            throw "Could not connect to debugger on port " + DebugServer.port;
        }
        
    }
}
