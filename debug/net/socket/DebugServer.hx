package debug.net.socket;

import debug.Data;
import debug.net.Message;

/**
    Syncronious debug server
**/
class DebugServer
{
    public static inline var host = "localhost";
    public static inline var port = 5000;
    
    public var running(default, null) = true;
    var s : sys.net.Socket;
    var c : sys.net.Socket;
    
    public function new()
    {
    }
    
    public dynamic function onBreakPoint(context : ContextData) : Void
    {
    }
    
    public dynamic function onException(context : ExceptionData) : Void
    {
    }
    
    public dynamic function onClientConnected() : Void
    {
    }
    
    public dynamic function onClientDisconnected() : Void
    {
    }
    
    public function listen() : Void
    {
        s = new sys.net.Socket();
        s.bind(new sys.net.Host(host), port);
        s.listen(1);
        
        while (running) {
            c = s.accept();
            onClientConnected();

            try {
                while (true) {
                    var l = c.input.readLine();
                    
                    var message : Message = haxe.Json.parse(l);
                    onMessage(message.kind, message.data);
                }
            }
            catch (e : Dynamic) {
            }
            onClientDisconnected();
        }
    }

    /**
        Stops the execution of the server
    **/
    public function stop() : Void
    {
        running = false;
    }
    
    /**
        Continues the execution of the client code
        Can be called after a breakpoint or exception
    **/
    public function doContinue() : Void
    {
        sendMessage("CONTINUE", null);
    }
    
    /**
        NOT IMPLEMENTED YET
        Set a variable in the client code.
    **/
    public function setVariable(name : String, value : String) : Void
    {
        //TODO: implement
    }
    
    function sendMessage(message : String, data : Dynamic) : Void
    {
        if (c == null)
            throw "No debugging client connected";
        
        var msg : Message = {
            kind: message,
            data: data
        };
        c.write(haxe.Json.stringify(msg) + "\n");
        c.output.flush();
    }
    
    function onMessage(message : String, data : Dynamic) : Void
    {
        switch (message) {
            case "BREAKPOINT":
                onBreakPoint(data);
            case "EXCEPTION":
                onException(data);
        }
    }
    
    
}
