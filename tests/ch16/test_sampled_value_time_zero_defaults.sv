/*
:name: test_sampled_value_time_zero_defaults
:description: at a clock tick at time 0 a concurrent assertion sees the default sampled values, the initializer of a static variable or else the default of its type, also inside compound expressions and function arguments, while at later ticks it sees the Preponed values; a function is called on the sampled arguments when the expression is evaluated (IEEE 1800-2023 Section 16.5.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.1 16.9.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_value_time_zero_defaults.expected
*/
// IEEE 1800-2023 §16.5.1: in the time slot of time 0 the sampled value of a
// variable is its default sampled value: for a static variable the value of
// its declaration assignment, else the default value of its type (0 for
// int). In a later time slot it is the value in the Preponed region, from
// before any change in that time step. The sampled value of an expression
// with several operands is built from the sampled values of the operands, and
// a function in it is called, when the expression is evaluated, with the
// sampled values of its arguments; k, read inside scaled() but not passed to
// it, has the value of that moment. The procedure changes a, b and k and then
// raises clk in the same time step, at 0 and at 10; at 20 clk rises again
// with no change. a_zero holds only with the default sampled values, so it
// passes at 0 and fails later. Its action block (§16.14.1) prints the
// $sampled values (§16.9.3), which follow the same rules, the $past values,
// which are the sampled values of the previous tick (the default sampled
// values at the first tick), and the current values. Verilator 5.052 uses
// the current values 9 and 7 at the tick at time 0.

`timescale 1ns/1ns

module test_sampled_value_time_zero_defaults;
  logic clk = 0;
  logic [7:0] a = 8'd5;
  int b;
  bit [7:0] d = 8'd2;
  int k = 1;

  function automatic int scaled(int v);
    return v * 10 + k;
  endfunction

  a_zero: assert property (@(posedge clk) a == 8'd5 && b == 0 && a + d == 8'd7 && scaled(a) == 52)
    $display("t=%0t pass: a=%0d b=%0d a+d=%0d scaled(a)=%0d past a=%0d b=%0d; now a=%0d b=%0d",
             $time, $sampled(a), $sampled(b), $sampled(a + d), $sampled(scaled(a)), $past(a),
             $past(b), a, b);
    else $display("t=%0t fail: a=%0d b=%0d a+d=%0d scaled(a)=%0d past a=%0d b=%0d; now a=%0d b=%0d",
                  $time, $sampled(a), $sampled(b), $sampled(a + d), $sampled(scaled(a)),
                  $past(a), $past(b), a, b);

  initial begin
    a = 9;
    b = 7;
    k = 2;
    clk = 1;
    #5 clk = 0;
    #5 a = 13;
    b = 9;
    k = 3;
    clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #5 $finish;
  end
endmodule
