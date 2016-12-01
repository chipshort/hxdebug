package debug;

import debug.Data;

class DebugUtil
{
    public static function getContextData(localVars : Map<String, Dynamic>, typeVars : Map<String, Dynamic>, pos : Position, callStack : Array<haxe.CallStack.StackItem>) : ContextData
    {
        return {
            localVars: createVarArray(localVars),
            typeVars: createVarArray(typeVars),
            pos: pos,
            callStack: haxe.CallStack.toString(callStack) //TODO: test callstack on platforms other than neko
        };
    }
    
    
    public static function createVarArray(vars : Map<String, Dynamic>) : Array<Var>
    {
        var array = [];
        for (varName in vars.keys()) {
            var value = vars[varName];
            
            array.push({
                name: varName,
                type: getTypeName(value),
                value: getValue(value)
            });
        }
        
        return array;
    }
    
    public static function getTypeName(value : Dynamic) : String
    {
        switch(Type.typeof(value)) {
    		case TUnknown:
    			return null;
    		case TObject:
                try {
                    var cls : Class<Dynamic> = value;
        			return "Class<" + Type.getClassName(cls) + ">";
                }
                catch(e : Dynamic) {
                }
    			return "Dynamic";
    		case TInt:
    			return "Int";
    		case TFloat:
    			return "Float";
    		case TFunction:
    			return "FUNCTION";
    		case TClass(c):
    			return Type.getClassName(c);
    		case TEnum(e):
    			return "Enum";
    		case TBool:
    			return "Bool";
    		case TNull:
    			return "null";
        }
    }
    
    public static function getValue(value : Dynamic) : Dynamic
    {
        switch(Type.typeof(value)) {
    		case TUnknown:
    			return Std.string(value);
    		case TObject:
                try {
                    var cls : Class<Dynamic> = value; //TODO: parse classes
        			return Type.getClassName(cls);
                }
                catch(e : Dynamic) {
                }
                
                var fields = Reflect.fields(value);
                var vars = new Map<String, Dynamic>();
                
                for (field in fields) {
                    var val = Reflect.getProperty(value, field);
                    vars.set(field, val);
                }

                return createVarArray(vars);
    		case TInt:
    			return value;
    		case TFloat:
    			return value;
    		case TFunction:
    			return "FUNCTION";
    		case TClass(c):
    			return value;
    		case TEnum(e):
    			return Std.string(e);
    		case TBool:
    			return value;
    		case TNull:
    			return null;
        }
    }
}
