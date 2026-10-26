/*
:name: test_illegal_cg_point_name_in_method
:description: a class method uses a coverpoint name outside the allowed contexts (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method write uses the coverpoint identifier cp without a covergroup variable prefix
:expected_stderr_regex: test_illegal_cg_point_name_in_method\.sv:29:
*/
// A coverpoint name is visible only in a cross item list, in a
// hierarchical name whose prefix is a covergroup variable, or after ::
// with a covergroup scope. The method here uses cp alone.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_point_name_in_method;
  class c;
    covergroup cg(input int v);
      cp: coverpoint v;
    endgroup
    function void write();
      cp.option.weight = 2;   // illegal: cp is not visible here
    endfunction
  endclass
endmodule
