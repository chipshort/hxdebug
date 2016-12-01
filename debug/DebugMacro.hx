package debug;

#if macro
import haxe.macro.PositionTools;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
#end

using StringTools;

class DebugMacro
{
    //TODO: when making this even more general (with stepping, etc.) make sure to exclude DebugClient.hx
    
    //TEST
    macro public static function initialize() : Void
    {
        var main : String;
        var args = Sys.args();

        for (i in 0...args.length) {
            var arg = args[i];

            if (arg == "-main") {
                main = args[i+1];
                break;
            }
        }

        Compiler.addMetadata("@:build(debug.DebugMacro.buildMain())", main);
        //Compiler.addGlobalMetadata(main, "@:build(debug.DebugMacro.buildMain())", false, true);
        
        // if (main != null) {
        //     var type = haxe.macro.Context.getType(main);
        //     var clazz = haxe.macro.TypeTools.getClass(type);
        //     clazz.meta.add(":build", [macro debug.DebugMacro.buildMain()], Context.currentPos());
        // }
        
    }

    macro public static function buildMain() : Array<Field>
    {
        var fields = Context.getBuildFields();

        for (field in fields) {
            if (field.name == "main" && field.access.indexOf(AStatic) != -1) {
                switch(field.kind) {
                    case FFun(f):
                        var old = f.expr;
                        var pos = getLocalPosition(field.pos);
                        var newE = macro {
                            try {
                                @:pos(field.pos) $old; //TODO: capture return value if not Void
                            }
                            catch (__global__Exception : Dynamic) {
                                @:pos(field.pos) debug.DebugMacro.exception(__global__Exception);
                            }
                        }
                        
                        f.expr = newE;
                        //f.expr.pos = old.pos;
                    default:
                }
            }
            
        }

        return fields;
        //return Context.getBuildFields();
    }
    
    macro public static function exception(exception : ExprOf<String>) : Expr
    {
        var pos = getLocalPosition();
        return macro debug.DebugClient.the.exception(${getExceptionData(exception, pos)});
    }
    
    macro public static function breakPoint() : Expr
    {
        var pos = getLocalPosition();
        return macro debug.DebugClient.the.breakPoint(${getContextData(pos)});
    }
    
    #if macro

    static function getLocalPosition(?pos : haxe.macro.Expr.Position) : Data.Position
    {
        if (pos == null)
            pos = haxe.macro.Context.currentPos();
        var p = PositionTools.getInfos(pos);
        var pos = {
            file: p.file,
            pos: p.min
        }
        return pos;
    }

    /**
     * Gets the local variables available at the current execution position
     */
    static function getLocalVars() : ExprOf<Map<String, Dynamic>>
    {
        var vars = new Array<String>();
        var tvars = Context.getLocalTVars();
        for (variable in tvars.keys()) {
            vars.push(variable);
        }
        
        //TODO: think about advanced parsing to get position of local vars???
        
        var assignments = new Array<Expr>();
        for (v in vars) {
            assignments.push(Context.parseInlineString("[\"" + v + "\", " + v + "]", Context.currentPos()));
        }
        
        return macro {
            var map = new Map<String, Dynamic>();
            var data : Array<Array<Dynamic>> = $a{assignments};
            for (v in data) {
                map.set(v[0], v[1]);
            }
            
            map;
        };
    }
    
    /**
     * Gets the variables of the type available at the current execution postition
     */
    static function getTypeVars() : ExprOf<Map<String, Dynamic>>
    {
        var type : BaseType = switch (Context.getLocalType()) {
            case TInst (t, _):
                t.get ();
            case TEnum (t, _):
                t.get ();
            case TType (t, _):
                t.get ();
            case TAbstract (t, _):
                t.get ();
            default:
                null;
        };
        
        var clazz : ClassType = cast type;
        
        if (haxe.macro.TypeTools.findField(clazz, Context.getLocalMethod(), true) == null) {
            return macro {
                var fields = Reflect.fields(this);
                var map : Map<String, Dynamic> = [ for (field in fields) field => try { Reflect.getProperty(this, field); } catch (e : Dynamic) { e; }];
                map;
            };
        }
        
        return macro new Map<String, Dynamic>();
    }

    static function getExceptionData(err : Expr, pos : Data.Position) : ExprOf<Data.ExceptionData>
    {
        var data = getContextData(pos);
        return macro {
            context: {
                localVars: debug.DebugUtil.createVarArray(${getLocalVars()}),
                typeVars: debug.DebugUtil.createVarArray(${getTypeVars()}),
                pos: $v{pos},
                callStack: haxe.CallStack.toString(haxe.CallStack.callStack()) //TODO: test callstack on platforms other than neko
            },
            error: $err
        };
    }
    
    static function getContextData(pos : Data.Position) : ExprOf<Data.ContextData>
    {
        return macro {
            localVars: debug.DebugUtil.createVarArray(${getLocalVars()}),
            typeVars: debug.DebugUtil.createVarArray(${getTypeVars()}),
            pos: $v{pos},
            callStack: haxe.CallStack.toString(haxe.CallStack.callStack()) //TODO: test callstack on platforms other than neko
        };
    }
    
    /**
     * Helper function to get rid of switch case boilerplate
     */
    static function getType(type : Type) : BaseType
    {
        return switch (Context.getLocalType()) {
            case TInst (t, _):
                t.get ();
            case TEnum (t, _):
                t.get ();
            case TType (t, _):
                t.get ();
            case TAbstract (t, _):
                t.get ();
            default:
                null;
        };
    }
    
    /**
     * Helper function that returns the complete type name (including package) as a String
     */
    static function getPackagePath (type : BaseType) : String
	{
		return type.module.endsWith (type.name) ? type.module : type.module + "." + type.name;
    }
    #end
}
