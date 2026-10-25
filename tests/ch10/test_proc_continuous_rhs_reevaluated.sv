/*
:name: test_proc_continuous_rhs_reevaluated
:description: while a procedural assign or force is in effect, its right-hand side is evaluated again whenever a variable it reads changes, including the argument of a function it calls (IEEE 1800-2023 Section 10.6)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_proc_continuous_rhs_reevaluated.expected
*/
// IEEE 1800-2023 §10.6: the right-hand side of an assign or a force
// procedural continuous assignment is treated like a continuous assignment:
// while it is in effect, it is evaluated again whenever a variable on the
// right-hand side changes, also a variable that is only passed to a function
// called there.
//
// r = a + b (assign to a variable), f = a + twice(c) (force on a variable)
// and w = a & c (force on a net) are printed one time unit after each change:
// a changes first, then b and c. Each printed value is the right-hand side
// computed from the current a, b and c.
//
// Icarus Verilog 13.0 says that it evaluates the right-hand side of these
// statements only once, when they are executed, and prints the first values
// throughout. Release 5.052 of Verilator does not evaluate f again when only
// c, the function argument, changes.

module test_proc_continuous_rhs_reevaluated;
  int a = 1, b = 2, c = 3;
  int r, f;
  wire [7:0] w = 8'h00;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  initial begin
    assign r = a + b;
    force f = a + twice(c);
    force w = a & c;
    #1 $display("start:    r=%0d f=%0d w=%0d", r, f, w);
    a = 10;
    #1 $display("a=10:     r=%0d f=%0d w=%0d", r, f, w);
    b = 20;
    c = 6;
    #1 $display("b=20 c=6: r=%0d f=%0d w=%0d", r, f, w);
  end
endmodule
