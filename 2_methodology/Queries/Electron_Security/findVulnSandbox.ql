/**
 * @kind problem
 * @id js/findVulnSandBox
 * @name findVulnSandBox
 * @description 앱과 Host 리소스의 영역분리
 * @problem.severity warning
 * @precision high
 */

import javascript

//nodeIntegration: 0!
predicate isVulnSandBox(Property props, Label label, UnaryExpr unexpr){
    // label 이 동일하고
    label.getName()="sandbox" and props.getAChild() = label 
    and
    // 속성이 취약한 Prop 이면 true
    unexpr.toString()="!0" and props.getAChild()=unexpr
}
from Property props, Label label, UnaryExpr unexpr
where isVulnSandBox(props, label, unexpr)
select props, "Chrome Sandbox is disabled"
