/*
:name: test_illegal_function_inout_arg_in_force
:description: a function with an inout formal cannot be called in the expression of a procedural continuous assignment, while one with only a const ref formal can (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement for v_bad calls bump, which has the inout formal k
:expected_stderr_regex: test_illegal_function_inout_arg_in_force\.sv:39:
*/
// IEEE 1800-2023 13.4: it shall be illegal to call a function with output,
// inout or ref formals in an expression within a procedural continuous
// assignment, such as force (10.6.2); a const ref formal is allowed there.
// look has a single const ref formal, and force v_ok = look(c) is legal.
// bump has the inout formal k, and force v_bad = bump(c) is illegal. Without
// that statement the design prints v_ok=1, then v_ok=6 after c changes to 5.
// Icarus Verilog 13.0 does not parse const ref formals. The 5.054 release
// of Verilator only warns of side effects on both force lines and accepts
// the design (5.052 stopped with an internal error on the marked line).

module test_illegal_function_inout_arg_in_force;
  int c = 0;
  int v_ok, v_bad;

  function int bump(inout int k);
    k = k + 1;
    return k;
  endfunction

  function automatic int look(const ref int k);
    return k + 1;
  endfunction

  initial begin
    force v_ok = look(c);
    force v_bad = bump(c);   // illegal: inout formal
    #1 $display("v_ok=%0d", v_ok);
    c = 5;
    #1 $display("v_ok=%0d", v_ok);
  end
endmodule
