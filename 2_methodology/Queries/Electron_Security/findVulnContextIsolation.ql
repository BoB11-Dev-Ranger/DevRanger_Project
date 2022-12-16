/**
 * @kind problem
 * @id js/findVulnContextIsolation
 * @name findVulnContextIsolation
 * @description 앱의 Main Process 와 Renderer Process 의 영역 분리
 * @problem.severity warning
 * @precision high
 */

import javascript

//nodeIntegration: 0!
predicate isVulnContextIsolation(Property props, Label label, UnaryExpr unexpr){
    // label 이 동일하고
    label.getName()="contextIsolation" and props.getAChild() = label 
    and
    // 속성이 취약한 Prop 이면 true
    unexpr.toString()="!1" and props.getAChild()=unexpr
}
from Property props, Label label, UnaryExpr unexpr
where isVulnContextIsolation(props, label, unexpr)
select props, "ContextIsolation is disabled"
