/*
:name: test_illegal_checker_covergroup_constant_actual
:description: A checker covergroup cannot reference a formal whose actual is constant (IEEE 1800-2023 Section 17.6)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a covergroup references a checker formal with a constant actual argument
:expected_stderr_regex: test_illegal_checker_covergroup_constant_actual\.sv:(?:21|27)(?::|\s)
*/
// IEEE 1800-2023 17.6: The covergroup restriction concerns the actual argument
// even though an ordinary checker input can otherwise receive a literal.
// Oracle checks: Icarus Verilog 13.0 rejects at a different error site. The
// 5.052 release accepts the illegal design.

checker constant_cover(input bit clk, input bit data);
  covergroup cg @(posedge clk);
    cp: coverpoint data; // illegal
  endgroup
  cg instance_value = new;
endchecker
module test_illegal_checker_covergroup_constant_actual;
  bit clk;
  constant_cover c(clk, 1'b1); // illegal
endmodule
