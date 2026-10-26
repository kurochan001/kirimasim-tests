/*
:name: test_illegal_cg_extends_missing_base
:description: covergroup extends names a covergroup that a base class does not define (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extends declaration names no_such_base, which no base class defines
:expected_stderr_regex: test_illegal_cg_extends_missing_base\.sv:30:
*/
// A derived embedded covergroup is written with covergroup extends and
// takes the name of the base covergroup. It is an error when no base
// class of the enclosing class defines that name.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_extends_missing_base;
  class base;
    covergroup g1(input int a);
      coverpoint a;
    endgroup
  endclass
  class derived extends base;
    covergroup extends no_such_base;   // illegal: no base covergroup
      coverpoint 1;
    endgroup : no_such_base
  endclass
endmodule
