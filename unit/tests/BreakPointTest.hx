package tests;

import debug.Data;

class BreakPointTest extends ServerTest
{
    public function testBreak() : Void
    {
        var data : ContextData = main.debugData.pop();
        
        var expectedLocals : Array<Var> = [{
            name: "b",
            type: "Dynamic",
            value: [{
                name: "test",
                type: "Int",
                value: 2
            }, {
                name:"cls",
                type:"Class<tests.ClientMain>",
                value:"tests.ClientMain"
            }]
        }, {
            name: "i",
            type: "Class<tests.ClientMain>",
            value: "tests.ClientMain"
        }];

        var expectedTypes : Array<Var> = [{
            name: "reader",
            type: "String", //String instead of haxe.io.Input because of Exception
            value: "exception"
        }];

        assertDeepEq(expectedLocals, data.localVars);
        assertDeepEq(expectedTypes, data.typeVars);
    }
}