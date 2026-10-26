/*
:name: test_illegal_interface_specialization_conflict
:description: two specializations of one parameterized interface class are distinct types, so their method names conflict when inherited together
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: J inherits method m from I#(int) and from I#(bit), which are different specializations, and does not resolve the conflict
:expected_stderr_regex: test_illegal_interface_specialization_conflict\.sv:25:
*/
// IEEE 1800-2023 8.26.6.3: each unique parameterization of a parameterized
// interface class is a separate interface class specialization, and a
// specialization is a unique interface class type. Therefore, inheriting
// I#(int) and I#(bit) is not a shared-origin diamond, and the method m that
// both bring is a name conflict that J does not resolve, so the declaration of
// J is illegal. Verilator 5.052 accepts the design.

interface class I #(type T = int);
  pure virtual function void m(T a);
endclass

interface class J extends I#(int), I#(bit);
endclass

module test_illegal_interface_specialization_conflict;
endmodule
