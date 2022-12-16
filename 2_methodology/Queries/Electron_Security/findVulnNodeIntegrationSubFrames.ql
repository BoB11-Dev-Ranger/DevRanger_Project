/**
 * @kind problem
 * @id js/findVulnNodeIntegrationSubFrames
 * @name findVulnNodeIntegrationSubFrames
 * @description 앱 내 iframe 상에서 Node JS API 사용가능
 * @problem.severity error
 * @precision high
 */

import javascript

//nodeIntegration: 0!
predicate isVulnNodeIntegrationSubFrames(Property props, Label label, UnaryExpr unexpr){
    // label 이 동일하고
    label.getName()="nodeIntegrationSubFrames" and props.getAChild() = label 
    and
    // 속성이 취약한 Prop 이면 true
    unexpr.toString()="!0" and props.getAChild()=unexpr
}
from Property props, Label label, UnaryExpr unexpr
where isVulnNodeIntegrationSubFrames(props, label, unexpr)
select props, "NodeIntegrationSubframe is enabled"
