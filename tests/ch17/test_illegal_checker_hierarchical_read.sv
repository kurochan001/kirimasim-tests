/*
:name: test_illegal_checker_hierarchical_read
:description: a module may not read a checker variable through its hierarchical name as the right-hand side of an assignment, just as it may not write one (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a module reads a checker variable by hierarchical name in an assignment
:expected_stderr_regex: test_illegal_checker_hierarchical_read\.sv:31:
*/
// IEEE 1800-2023 17.7.1: a checker variable shall not be referenced by its
// hierarchical name in an assignment, including a read of the variable as an
// assignment operand. The module reads armed, a checker variable, in the
// assignment to x; only the checker itself may read and assign armed. The
// rest of the design is legal.

checker hierarchical_read_chk(logic clk);
  bit armed = 1'b1;
endchecker : hierarchical_read_chk

module test_illegal_checker_hierarchical_read;
  logic clk = 1'b0;
  logic x;

  hierarchical_read_chk c(clk);

  initial begin
    #1 x = c.armed;   // illegal: reading a checker variable by hierarchical name
  end
endmodule
