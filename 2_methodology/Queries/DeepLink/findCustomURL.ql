/**
 * @name Empty block
 * @kind problem
 * @problem.severity warning
 * @id javascript/example/empty-block
 */

import javascript



from DataFlow::MethodCallNode startFunc
, string arg1StartFunc
, ExprStmt expr
, string scheme
where
    startFunc.getMethodName() = "startsWith"
    and arg1StartFunc = startFunc.getArgument(0).getStringValue()
    and arg1StartFunc.regexpMatch("^.*://.*$")

    and scheme = expr.getAToken().toString()
    and not scheme.regexpMatch("^.*"+arg1StartFunc+".*$")
    and scheme.regexpMatch("^.*://.*$")

select startFunc.getArgument(0), "to" , scheme
