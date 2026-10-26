/*
:name: test_illegal_interface_param_conflict
:description: a parameter inherited from two different interface classes conflicts even when the two parameters match and are never used
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: PutGetIntf inherits the parameter T from two distinct interface classes and does not override it
:expected_stderr_regex: test_illegal_interface_param_conflict\.sv:30:
*/
// IEEE 1800-2023 8.26.6.2: a name collision occurs when the same name is
// inherited from different interface classes, and the subclass shall provide
// parameter and/or type declarations that override all such collisions. The
// conflict remains even when the inherited parameters match and are never
// used: T is logic in both PutImp and GetImp, and PutGetIntf never refers to
// it, but the declaration of PutGetIntf does not resolve the collision. It is
// therefore illegal. Verilator 5.052 accepts the design.

interface class PutImp #(type T = logic);
  pure virtual function void put(T a);
endclass

interface class GetImp #(type T = logic);
  pure virtual function T get();
endclass

interface class PutGetIntf extends PutImp#(logic), GetImp#(logic);
endclass

module test_illegal_interface_param_conflict;
endmodule
