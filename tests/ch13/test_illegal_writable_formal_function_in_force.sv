/*
:name: test_illegal_writable_formal_function_in_force
:description: A function with an output formal argument cannot be called in the expression of a procedural continuous assignment (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement for v_bad calls plus_one_copy, which has the output formal argument y
:expected_stderr_regex: test_illegal_writable_formal_function_in_force\.sv:43:
*/
// IEEE 1800-2023 §13.4: it shall be illegal to call a function with output,
// inout or ref formal arguments in an expression within a procedural
// continuous assignment, the assign and force statements of 10.6. plus_one
// has an input formal only, and force v_ok = plus_one(c) is legal;
// plus_one_copy also has the output formal y, and the force statement for
// v_bad calls it. Without that statement the design prints v_ok=4.
// test_illegal_writable_formal_function_in_event_control and
// test_illegal_writable_formal_function_in_continuous_assign check the other
// two places.
// Icarus Verilog 13.0 rejects the declaration of plus_one_copy, since it
// takes only input formals in functions, which does not count, and the
// 5.054 release of Verilator accepts the design.

module test_illegal_writable_formal_function_in_force;
  int c = 3;
  int copy;
  int v_ok, v_bad;

  function int plus_one(input int k);
    return k + 1;
  endfunction

  function int plus_one_copy(input int k, output int y);
    y = k;
    return k + 1;
  endfunction

  initial begin
    force v_ok = plus_one(c);
    force v_bad = plus_one_copy(c, copy);   // illegal: output formal in force
    #1 $display("v_ok=%0d", v_ok);
  end
endmodule
