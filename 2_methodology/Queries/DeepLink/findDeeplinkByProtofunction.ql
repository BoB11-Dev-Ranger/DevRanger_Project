/**
 * @name Empty block
 * @kind problem
 * @problem.severity warning
 * @id javascript/example/empty-block
 */

import javascript

from DataFlow::MethodCallNode deeplink, DataFlow::Node source
where
    deeplink.getMethodName() = "setAsDefaultProtocolClient" and
    source.getASuccessor*() = deeplink.getArgument(0)
    
select source
