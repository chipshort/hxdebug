package debug.net;

import debug.Data;

typedef Message = {
    kind : String,
    data : Dynamic
}

class MessageParser
{
    public static function parseClientMessage(message : String, data : Dynamic) : ClientMessage
    {
        switch (message) {
            case "BREAKPOINT":
                return ClientMessage.Breakpoint(data);
            case "EXCEPTION":
                return ClientMessage.Exception(data);
            default:
                return null;
        }
    }
    
    public static function parseServerMessage(message : String, data : Dynamic) : ServerMessage
    {
        switch (message) {
            case "CONTINUE":
                return ServerMessage.Continue;
            case "SET":
                return ServerMessage.Set(data);
            default:
                return null;
        }
    }
}

enum ServerMessage
{
    Continue();
    Set(variable : Data.Var);
}

enum ClientMessage
{
    Breakpoint(context : ContextData);
    Exception(context : ExceptionData);
}
