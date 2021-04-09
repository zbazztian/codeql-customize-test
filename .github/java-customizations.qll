import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.FlowSteps

/////////////////////////// CUSTOMIZE HERE ////////////////////////////////////////////////////
string taintedCalls() {
  result = "org.apache.commons.io.output.ClosedOutputStream.write"
}

string taintedParams() {
  result = "org.apache.commons.io.output.ClosedOutputStream.write.0"
}

string paramsWhichPassTaintThroughToTheReturnValue() {
  result = "org.apache.commons.io.output.ClosedOutputStream.write.-1"
}
///////////////////////////////////////////////////////////////////////////////////////////////

string callableSignature(Callable c) {
  result = c.getDeclaringType().getQualifiedName() + "." + c.getName()
}

string paramSignature(Parameter p) {
  result = callableSignature(p.getCallable()) + "." + p.getPosition()
}

string qualifierSignature(Callable c) {
  result = c.getDeclaringType().getQualifiedName() + "." + c.getName() + ".-1"
}

class TaintedParameters extends RemoteFlowSource {
  TaintedParameters() { paramSignature(this.asParameter()).matches(taintedParams()) }

  override string getSourceType() { result = "Custom tainted parameter" }
}

class TaintedCalls extends RemoteFlowSource {
  TaintedCalls() { callableSignature(this.asExpr().(Call).getCallee()).matches(taintedCalls()) }

  override string getSourceType() { result = "Custom tainted call" }
}

class CallablesWhichReturnTaintFromParams extends TaintPreservingCallable {
  int paramIdx;

  CallablesWhichReturnTaintFromParams() {
    paramSignature(this.getParameter(paramIdx))
        .matches(paramsWhichPassTaintThroughToTheReturnValue())
    or
    qualifierSignature(this).matches(paramsWhichPassTaintThroughToTheReturnValue()) and
    paramIdx = -1
  }

  override predicate returnsTaintFrom(int arg) { arg = paramIdx }
}
