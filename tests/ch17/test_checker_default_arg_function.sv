/*
:name: test_checker_default_arg_function
:description: A checker input argument with a default value, and a function called on the right-hand side of a checker variable assignment (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.8 17.2 17.3 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_default_arg_function.expected
*/
// IEEE 1800-2023 §17.2, §17.3: an input argument of a checker may have a default
// value, used by an instance that leaves the argument out, and an output
// argument may have an initial value. §17.8: the right-hand side of a checker
// variable assignment may call an automatic function without side effects. Two
// instances count the clock edges at which the sampled value is above their
// limit, one with the default limit of 100 and one with a limit of 10, and pass
// the counts out through an output argument.

`timescale 1ns/1ns

checker count_above(input logic [7:0] v, input event clk, input int lim = 100, output int n = 0);
  function automatic bit above(logic [7:0] x, int l);
    return x > l;
  endfunction
  always_ff @(clk) n <= n + above(v, lim);
endchecker

module test_checker_default_arg_function;
  logic clk = 0;
  logic [7:0] v = 0;
  int n_default, n_ten;

  count_above c_default(.v(v), .clk(posedge clk), .n(n_default));
  count_above c_ten(.v(v), .clk(posedge clk), .lim(10), .n(n_ten));

  initial begin
    #1 v = 8'd50;
    #4 clk = 1;     // 5: 50
    #5 clk = 0;
    v = 8'd150;
    #5 clk = 1;     // 15: 150
    #5 clk = 0;
    v = 8'd5;
    #5 clk = 1;     // 25: 5
    #5 clk = 0;
    $display("limit 100 (default): %0d edges above it", n_default);
    $display("limit 10: %0d edges above it", n_ten);
  end
endmodule
