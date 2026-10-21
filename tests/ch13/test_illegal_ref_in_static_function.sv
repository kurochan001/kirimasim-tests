/*
:name: test_illegal_ref_in_static_function
:description: A static function cannot have an argument passed by reference (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2 13.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a ref argument is declared in a function with static lifetime
:expected_stderr_regex: test_illegal_ref_in_static_function\.sv:23:
*/
// IEEE 1800-2023 §13.5.2: it shall be illegal to pass arguments by reference to
// subroutines with a static lifetime. A function in a module is static unless
// declared automatic (§13.4.2).
// Icarus Verilog 13.0 does not support ref arguments, so the error it reports
// on that line does not count. The design is accepted by Verilator 5.052
// (docs/simulator-differences.md).

module test_illegal_ref_in_static_function;
  int x = 5;
  function int twice(ref int v);   // illegal: ref argument of a static function
    return 2 * v;
  endfunction
  initial $display("twice=%0d", twice(x));
endmodule
