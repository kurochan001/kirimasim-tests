/*
:name: test_illegal_recursive_class_function_call_without_parentheses
:description: a directly recursive call of a nonvoid class function method cannot leave out its parentheses (IEEE 1800-2023 Section 13.5.5)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.5 13.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the nonvoid method down calls itself, without a hierarchical qualifier, without parentheses
:expected_stderr_regex: test_illegal_recursive_class_function_call_without_parentheses\.sv:31:
*/
// IEEE 1800-2023 §13.5.5 and §13.5 (footnote 42 of Syntax 13-3): the
// parentheses of a call of a class method without arguments may be left out,
// except in a directly recursive call of a nonvoid class function method that
// is not hierarchically qualified. down calls itself once with parentheses,
// which is legal (13.4.1 allows a nonvoid call as a statement with a warning,
// and void' discards the value without one), and once without them as a
// statement, which is illegal. The module calls down and peek on an object
// without parentheses, which is legal as these calls are not recursive.
// Icarus Verilog 13.0 rejects the legal calls without parentheses in the
// module, and Verilator 5.052 accepts the design with a warning.

module test_illegal_recursive_class_function_call_without_parentheses;
  class C;
    int depth;
    function int down();
      depth++;
      if (depth < 2) void'(down());
      if (depth < 3) down;   // illegal
      return depth;
    endfunction
    function int peek();
      return depth;
    endfunction
  endclass
  C c;
  initial begin
    c = new;
    $display("%0d %0d", c.down, c.peek);
  end
endmodule
