/*
:name: test_timing_check_condition_forms
:description: A timing check condition can be a scalar expression, its inversion, or its comparison with ==, ===, != or !== against each legal spelling of a 0 or 1 constant, with or without parentheses, and a delayed signal can be a terminal or a bit-select of one (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_condition_forms.expected
*/
// IEEE 1800-2023 §31.2, Syntax 31-2: a timing_check_condition is a
// scalar_timing_check_condition, optionally in parentheses, which is an
// expression, ~ expression, or an expression compared by ==, ===, != or !==
// with a scalar constant: 1'b0, 1'b1, 1'B0, 1'B1, 'b0, 'b1, 'B0, 'B1, 1 or 0.
// The delayed reference and data signals of $setuphold and $recrem are a
// terminal identifier or one with a constant select. The cell conditions its
// checks with each of these forms and gives $setuphold a delayed data signal
// that is a bit of the vector dd. The inputs do not change, so no check
// reports a violation and the notifier keeps its value.

`timescale 1ns/1ns

module tcc_cell(input wire clk, input wire d, input wire en, input wire rst);
  reg n = 1'b0;
  wire dclk, drst, dclk2;
  wire [1:0] dd;
  specify
    $setup(d &&& en, posedge clk, 2, n);
    $setup(d &&& ~rst, posedge clk, 2, n);
    $setup(d &&& (en == 1'b1), posedge clk, 2, n);
    $setup(d, posedge clk &&& en === 1'B1, 2, n);
    $hold(posedge clk &&& rst != 1'b0, d, 1, n);
    $hold(posedge clk &&& (rst !== 1'B0), d, 1, n);
    $hold(posedge clk, d &&& en == 'b1, 1, n);
    $hold(posedge clk, d &&& en != 'B0, 1, n);
    $width(posedge clk &&& (en === 'B1), 5, 0, n);
    $width(negedge clk &&& rst !== 'b0, 5, 0, n);
    $period(posedge clk &&& en == 1, 10, n);
    $period(negedge clk &&& (rst == 0), 10, n);
    $setuphold(posedge clk, d, 2, 1, n, en, ~rst, dclk, dd[0]);
    $recrem(posedge rst, posedge clk, 3, 3, n, (en), en == 1'b1, drst, dclk2);
  endspecify
endmodule

module test_timing_check_condition_forms;
  logic clk = 1'b0, d = 1'b0, en = 1'b1, rst = 1'b0;
  tcc_cell u (.clk(clk), .d(d), .en(en), .rst(rst));
  initial #1 $display("notifier %b", u.n);
endmodule
