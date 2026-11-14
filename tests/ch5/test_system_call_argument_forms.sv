/*
:name: test_system_call_argument_forms
:description: System tasks and functions are called with the three argument forms of their syntax: an optional list of arguments, which may have empty arguments; a data type, alone or followed by an expression; and expressions with omitted positions followed by a clocking event (IEEE 1800-2023 Section 5.6.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.3 21.2.1 20.6.2 20.7 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_call_argument_forms.expected
*/
// IEEE 1800-2023 §5.6.3: a system task or function call is the name alone or
// with a list of arguments, the name with a data type and an optional
// expression, or the name with expressions, some of them omitted, and an
// optional clocking event. Each form is used where the routine takes it:
// - a list of arguments: §21.2.1, an empty argument of $display prints one
//   space, so "[", , "]" prints "[ ]"; $time is called with no list at all;
// - a data type: §20.6.2, $bits of the type six_t is 6 and of logic [9:0] is
//   10; §20.7, $unpacked_dimensions of the type grid_t is 2 and $size of
//   its second dimension is 5;
// - expressions and a clocking event: §16.9.3, $past(d, 2, , @(posedge clk))
//   leaves the gating expression out, so it is 1'b1, and gives the value of
//   d sampled two ticks of posedge clk earlier, or the declared value 0
//   before there are two such ticks; $rose(b, @(posedge clk)) compares the
//   value of b sampled at this tick with the one sampled at the previous
//   tick, or with the declared value 0 at the first tick.
// d is 1, 2, 3, 4 and b is 0, 1, 0, 1 at the ticks at 10, 20, 30 and 40,
// each set 5 time units before its tick, so $past gives 0, 0, 1, 2 and $rose
// 0, 1, 0, 1.
// Neither release runs the test: Icarus Verilog 13.0 stops with a syntax
// error at the call of $past, and the 5.054 release of Verilator does not
// support the clocking event argument of $past.

`timescale 1ns/1ns

module test_system_call_argument_forms;
  typedef logic [5:0] six_t;
  typedef int grid_t [0:2][0:4];

  logic clk = 1'b0;
  logic [3:0] d = 4'd0;
  logic b = 1'b0;

  always @(posedge clk)
    $display("tick at %0d: past2=%0d rose=%b", $time, $past(d, 2, , @(posedge clk)),
             $rose(b, @(posedge clk)));

  initial begin
    $display("[", , "]");
    $display("bits: %0d %0d", $bits(six_t), $bits(logic [9:0]));
    $display("array: %0d %0d", $unpacked_dimensions(grid_t), $size(grid_t, 2));
    #5 d = 4'd1;
    #5 clk = 1'b1;
    #5 begin clk = 1'b0; d = 4'd2; b = 1'b1; end
    #5 clk = 1'b1;
    #5 begin clk = 1'b0; d = 4'd3; b = 1'b0; end
    #5 clk = 1'b1;
    #5 begin clk = 1'b0; d = 4'd4; b = 1'b1; end
    #5 clk = 1'b1;
    #5 $finish;
  end
endmodule
