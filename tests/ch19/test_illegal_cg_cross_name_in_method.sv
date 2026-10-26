/*
:name: test_illegal_cg_cross_name_in_method
:description: a class method uses a cross name outside the allowed contexts (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method write uses the cross identifier cr without a covergroup variable prefix
:expected_stderr_regex: test_illegal_cg_cross_name_in_method\.sv:31:
*/
// A cross name, like a coverpoint name, is visible only after a
// covergroup variable hierarchical prefix or after :: with a covergroup
// scope. The method here uses cr alone.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_cross_name_in_method;
  class c;
    covergroup cg(input int a, input int b);
      pa: coverpoint a;
      pb: coverpoint b;
      cr: cross pa, pb;
    endgroup
    function void write();
      cr.option.weight = 2;   // illegal: cr is not visible here
    endfunction
  endclass
endmodule
