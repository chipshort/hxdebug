package debug;

typedef Position = {
    pos : Int,
    file : String
}

typedef Var = {
    name : String,
    type : String,
    value : Dynamic
}

typedef ContextData = {
    localVars : Array<Var>,
    typeVars : Array<Var>,
    pos : Position,
    callStack : String
}

typedef ExceptionData = {
    context : ContextData,
    error : String
}
