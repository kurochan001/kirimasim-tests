/*
:name: test_checker_port_connections
:description: Checker arguments connect by position, by explicit names and by the .* wildcard, and an output argument passes the checker's value to the actual variable (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.2 17.5 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_port_connections.expected
*/
// IEEE 1800-2023 §17.3: the actual arguments of a checker instance may be
// given in order, by name, or by .* for the formals whose names match
// variables in the instantiating scope, here a, b and both. The output both
// starts at its initial value 0 (17.2) and counts the clock ticks at which
// the sampled values of the two inputs are 1 (17.5, 17.7.1). c_pos counts a
// and x, the other two a and b. a is 1 from 12 to 42, b from 22 to 52, x from
// 32 to 42; the rising edges come at 5, 15, ..., 55.

checker count_both (logic a, logic b, event clock, output int both = 0);
  always_ff @clock
    if (a && b) both <= both + 1;
endchecker

module test_checker_port_connections;
  logic clk = 0, a = 0, b = 0, x = 0;
  int n_pos, n_named, both;

  always #5 clk = ~clk;

  count_both c_pos (a, x, posedge clk, n_pos);
  count_both c_named (.b(b), .clock(posedge clk), .a(a), .both(n_named));
  count_both c_wild (.clock(posedge clk), .*);

  initial begin
    #12 a = 1;
    #10 b = 1;
    #10 x = 1;
    #10 a = 0;
    x = 0;
    #10 b = 0;
    #8 $display("by position: %0d, by name: %0d, by .*: %0d", n_pos, n_named, both);
    $finish;
  end
endmodule
