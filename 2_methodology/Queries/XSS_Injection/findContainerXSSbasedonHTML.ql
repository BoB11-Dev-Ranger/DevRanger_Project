/**
 * @kind problem
 * @id js/findContainerXSSbasedonHTML
 * @name findContainerXSSbasedonHTML
 * @description HTML컨테이너에 필터링 없이 구문 삽입
 * @problem.severity error
 * @precision high
 */

import javascript

/*
  앞 뒤로 완성된 HTML 코드가 주어졌는지 판단.
  ex) '<div class="body">' + props.content + '</div>'
*/
predicate matchBeginTokenCompletedHTML(BinaryExpr expr) {
  expr.getFirstToken().toString().regexpMatch("^(`|')<[a-zA-Z]+(\\s)*([a-zA-Z]+=\"([a-zA-Z.*-_+@$])*\" *)*>(`|')$")
}
predicate matchEndTokenCompletedHTML(BinaryExpr expr){
  expr.getLastToken().toString().regexpMatch("^(`|')</[a-zA-Z]*>(`|')$")
}

/*
  앞 뒤로 미완성된 HTML 코드가 주어졌는지 판단.
  ex) '<img src="' + props.content + '" />'
*/
predicate matchBeginTokenHalfHTML(BinaryExpr expr) {
  expr.getFirstToken().toString().regexpMatch("^'<[a-zA-Z]+ src=\"*'$")
}
predicate matchEndTokenHalfHTML(BinaryExpr expr){
  expr.getLastToken().toString().regexpMatch("^'\"*( [a-zA-Z]*=(\"+[a-zA-Z.*-_+@$]*\"+))* />'$")
}

predicate matchMiddleHTML(BinaryExpr expr, DotExpr internalExpr){
  expr.getFirstToken() = internalExpr.getParentExpr().getFirstToken() and
  internalExpr.toString().regexpMatch("^([a-zA-Z]*.)*([a-zA-Z]+|text|content|data)$")
}

from BinaryExpr containerExpr, DotExpr internalExpr
where
    (matchBeginTokenCompletedHTML(containerExpr) and
    matchEndTokenCompletedHTML(containerExpr)) or
    (matchBeginTokenHalfHTML(containerExpr) and
    matchEndTokenHalfHTML(containerExpr)) and
    matchMiddleHTML(containerExpr, internalExpr)
select containerExpr, "Stored/Reflected XSS"


