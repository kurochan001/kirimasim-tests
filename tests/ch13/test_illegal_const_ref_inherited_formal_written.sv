/*
:name: test_illegal_const_ref_inherited_formal_written
:description: A task formal with no direction after a const ref formal is const ref too, so assigning it in the task is an error (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the task assigns its formal b, which has no direction of its own and inherits const ref from the formal a before it
:expected_stderr_regex: test_illegal_const_ref_inherited_formal_written\.sv:35:
*/
// IEEE 1800-2023 §13.3: a formal with no direction takes the direction of the
// formal before it, and the const qualifier of const ref is part of that
// direction. §13.5.2: a subroutine cannot alter a const ref formal, and an
// attempt to do so is a compile error.
//
// In add_pair(const ref int a, b), b has no direction, so it is const ref
// like a (and an int, the type of a). The task reads both formals, which is
// legal, and then assigns b, which is the error. A tool that let b fall back
// to input, or that kept ref but dropped const, would accept the assignment.
// Without that assignment the design is legal and prints 7.
// The 5.054 release of Verilator reports the assignment to the const ref
// formal b. Icarus Verilog 13.0 stops earlier, with a syntax error at the
// task header (it does not support const ref), which does not count.

module test_illegal_const_ref_inherited_formal_written;
  int x;
  int y;
  int total;

  task automatic add_pair(const ref int a, b);
    total = a + b;
    b = 0;   // illegal: b inherits const ref from a
  endtask

  initial begin
    x = 3;
    y = 4;
    add_pair(x, y);
    $display("%0d", total);
  end
endmodule
