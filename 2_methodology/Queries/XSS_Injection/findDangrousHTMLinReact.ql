/**
 * @kind problem
 * @id js/selectDangrousHTMLinReact
 * @name selectDangrousHTMLinReact
 * @description React 에서 DangerousHTML 옵션을 이용하여 강제로 HTML 삽입
 * @problem.severity error
 * @precision high
 */

import javascript

// dangerouslySetInnerHTML:{{__html:variable}}
// dangerouslySetInnerHTML:{__html:variable}
// dangerouslySetInnerHTML:{getHTML()}
// 위와 같이 React 내에서 Direct HTML setting 하는 구문을 스캔함.
from Label label, ObjectExpr objExp
where label.getName().regexpMatch("^.*dangerouslySetInnerHTML.*$")
and objExp.getAPredecessor() = label
select label, "dangerousHTML in React"
