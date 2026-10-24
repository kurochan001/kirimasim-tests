/*
:name: test_illegal_named_binding_omits_argument_without_default
:description: a call that binds arguments by name has to give every argument without a default (IEEE 1800-2023 Section 13.5.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call f(.b(3)) does not give the argument a, which has no default value
:expected_stderr_regex: test_illegal_named_binding_omits_argument_without_default\.sv:25:
*/
// IEEE 1800-2023 §13.5.4: with arguments bound by name, an argument with a
// default may be left out, but one without a default shall be given, or the
// compiler shall issue an error. a of f has no default and b has one. f(.a(1))
// leaves out only b and is legal; f(.b(3)) leaves out a.

module test_illegal_named_binding_omits_argument_without_default;
  function int f(input int a, input int b = 2);
    return 10 * a + b;
  endfunction
  initial begin
    $display("%0d", f(.a(1)));
    $display("%0d", f(.b(3)));   // illegal
  end
endmodule
