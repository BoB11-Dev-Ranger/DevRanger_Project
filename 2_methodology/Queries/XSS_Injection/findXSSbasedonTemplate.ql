/**
 * @kind problem
 * @id js/findXSSbasedonTemplate
 * @name findXSSbasedonTemplate
 * @description 템플릿구문에 필터링 없이 데이터 삽입
 * @problem.severity error
 * @precision high
 */

import javascript

// Template Literal 중에서 HTML Entity 로 시작하는 구문 탐색
predicate isStartsWithHTMLTagTemplate(Expr exp){
  exp.toString().regexpMatch("^<[a-zA-Z]+(((\\s)[a-zA-Z]+=[a-zA-Z0-9()'\"_-]*)*|[a-zA-Z]*)(\\s)*>*$")
}
predicate isStartsWithShortenHTMLTagTemplate(Expr exp){
  exp.toString().regexpMatch("^<[a-zA-Z]+ [a-zA-Z.(\\s)'\"_-]*>*$")
}

// 내부에 DotExpr 과 HTML Template Element 가 Direct 로 연결된 부분 탐색
predicate isPlainDotTemplate(DotExpr dotexpr, TemplateElement telem){
  dotexpr.getASuccessor().toString().regexpMatch("^(</[a-zA-Z]+>)*$")
  and
  dotexpr.getFirstToken().toString() = telem.getASuccessor().toString()
}

from TemplateLiteral tl, DotExpr dotexpr, TemplateElement telem
where (
  isStartsWithHTMLTagTemplate(tl.getChild(0)) and 
  isPlainDotTemplate(dotexpr, telem)) or 
  (
    isStartsWithShortenHTMLTagTemplate(tl.getChild(0)) and 
    isPlainDotTemplate(dotexpr, telem))
select tl, "Template Injection"
