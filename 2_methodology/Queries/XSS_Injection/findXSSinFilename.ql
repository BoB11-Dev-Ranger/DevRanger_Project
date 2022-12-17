/**
 * @name Empty block
 * @kind problem
 * @id javascript/example/empty-block
 * @problem.severity warning
 * @precision high
 */

 import javascript

 predicate isPathFunc(Expr arg1, DataFlow::FunctionNode funcNode, string expr, string pathfuncName){
     funcNode.asExpr().getParentExpr().getAChild().getAChild().getAChild().getAChild().getAChild().toString().regexpMatch("^.*[Pp][Aa][Tt][Hh]*.$")
     and expr = funcNode.getALocalUse().asExpr().getAChildExpr().toString()
     and expr.regexpMatch("^[A-Za-z._]*$")
     and (if expr.toString().regexpMatch("^this.*$")
         then pathfuncName = expr.toString().substring(5, expr.toString().length())
         else pathfuncName = expr.toString())
     and arg1.toString().regexpMatch("^.*"+pathfuncName+".*$")
 }
 predicate pathIn(Token arg1) { // innerHTML = path
     arg1.toString().regexpMatch("^.*[Pp][Aa][Tt][Hh]*.$")
     or arg1.toString().regexpMatch("^.*[Ff][Ii][Ll][Ee]*.[Nn][Aa][Mm][Ee]*.$")
 }
 
 predicate pathInVariable(Token arg1, VarRef var) { // innerHTML = var, var = path
     arg1.toString().regexpMatch("^[A-Za-z_]*$")
     and var.toString().regexpMatch(arg1.toString())
     and (var.getParentExpr().getAChildExpr().getAChildExpr().toString().regexpMatch("^.*[Pp][Aa][Tt][Hh]*.$")
     or arg1.toString().regexpMatch("^.*[Ff][Ii][Ll][Ee]*.[Nn][Aa][Mm][Ee]*.$"))
 }
 
 predicate pathInFunction(Token arg1, VarRef var, DataFlow::FunctionNode funcNode_ARG, string expr_ARG, string pathfuncName_ARG){ // innerHTML = func, func{return path}
     arg1.toString().regexpMatch("^[A-Za-z_]*$")
     and var.toString().regexpMatch(arg1.toString())
     and isPathFunc(var.getParentExpr().getAChildExpr().getAChildExpr(),funcNode_ARG,expr_ARG,pathfuncName_ARG)
 }
 
 
 predicate validator(Token arg1, VarRef var, DataFlow::FunctionNode funcNode_ARG, string expr_ARG, string pathfuncName_ARG){
     pathfuncName_ARG = "1"// init
     and expr_ARG = "1"// init
     and (pathIn(arg1)
     or pathInVariable(arg1, var)
     or pathInFunction(arg1, var,funcNode_ARG, expr_ARG, pathfuncName_ARG)
     )
 
 }
 
 from DataFlow::MethodCallNode funcFileOpen
 , AstNode funcFileOpenArgChild
 , DataFlow::SourceNode nodeinnerHTML
 , Token nodeinnerHTMLLastToken
 , VarRef var
 , DataFlow::FunctionNode funcNode_ARG
 , string expr_ARG
 , string pathfuncName_ARG
 where
     funcFileOpen.getMethodName() = "showOpenDialogSync"
     and funcFileOpenArgChild = funcFileOpen.getArgument(1).asExpr().getAChild()
     and funcFileOpenArgChild.getAChild().getAChild().toString().regexpMatch("^.*openFile.*$")
 
     and nodeinnerHTML.getAPropertyWrite().toString().regexpMatch("^.*innerHTML$")
     and nodeinnerHTMLLastToken = nodeinnerHTML.asExpr().getParentExpr().getParentExpr().getLastToken()
     and validator(nodeinnerHTMLLastToken, var, funcNode_ARG, expr_ARG, pathfuncName_ARG)
 
 select nodeinnerHTMLLastToken
