/**
 * @kind problem
 * @id js/selectNodeIntegration
 * @name selectNodeIntegration
 * @description 앱 내에서 NodeJS API 사용가능
 * @problem.severity error
 * @precision high
 */

import javascript

//nodeIntegration: 0!
predicate isVulnNodeIntegration(Property props, Label label, UnaryExpr unexpr){
    // label 이 동일하고
    label.getName()="nodeIntegration" and props.getAChild() = label 
    and
    // 속성이 취약한 Prop 이면 true
    unexpr.toString()="!0" and props.getAChild()=unexpr
}
from Property props, Label label, UnaryExpr unexpr
where isVulnNodeIntegration(props, label, unexpr)
select props, "NodeIntegration is enabled"
