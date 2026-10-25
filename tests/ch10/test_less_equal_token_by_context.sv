/*
:name: test_less_equal_token_by_context
:description: the token <= is a nonblocking assignment at the start of an assignment statement and the less-than-or-equal operator inside an expression, also on the right-hand side of that nonblocking assignment (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 11.4.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_less_equal_token_by_context.expected
*/
// IEEE 1800-2023 §10.4.2: the nonblocking assignment operator is the same
// token as the relational operator "less than or equal to"; inside an
// expression <= is the relational operator (11.4.4), and in a nonblocking
// assignment statement it is the assignment.
//
// "r <= x <= y;" is a nonblocking assignment of the comparison x <= y:
// with x = 3 and y = 5 it gives 1, and r changes only after the time step
// (it is still 0 right after the statement); with x = 6 it gives 0. In
// "if (x <= y)" and "q = (x <= y);" the token is the comparison.

module test_less_equal_token_by_context;
  int x = 3, y = 5, r = 0, q = 0;

  initial begin
    r <= x <= y;
    $display("right after r <= x <= y: r=%0d", r);
    #1 $display("next step: r=%0d", r);
    x = 6;
    r <= x <= y;
    q = (x <= y);
    #1 $display("x=6: r=%0d q=%0d", r, q);
    if (x <= y) $display("if: 6 <= 5 taken");
    else $display("if: 6 <= 5 not taken");
  end
endmodule
