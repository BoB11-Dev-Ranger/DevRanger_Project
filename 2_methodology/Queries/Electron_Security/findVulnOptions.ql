/**
 * @name Empty block
 * @kind problem
 * @id javascript/example/empty-block
 * @problem.severity warning
 * @precision high
 */

 import javascript

 from ObjectExpr objectExpr
 , Property objectExprProperty
 , Token nodeIntegration
 , Token trueORflase
 where
     objectExprProperty = objectExpr.getAProperty()
     and nodeIntegration = objectExprProperty.getFirstToken()
     and trueORflase = objectExprProperty.getLastToken()
     and ((nodeIntegration.toString() = "nodeIntegration" and trueORflase.toString()="true")
     or (nodeIntegration.toString() = "contextIsolation" and trueORflase.toString()="false")
     or (nodeIntegration.toString() = "sandbox" and trueORflase.toString()="false")
     or (nodeIntegration.toString() = "nodeIntegrationSubFrames" and trueORflase.toString()="true")
     )
 select ">",nodeIntegration, trueORflase
