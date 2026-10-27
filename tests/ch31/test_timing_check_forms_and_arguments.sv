/*
:name: test_timing_check_forms_and_arguments
:description: All twelve timing checks are accepted in a specify block with their events and limits in order and with their optional notifier, condition, delayed-signal and flag arguments given, left empty or left out (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.2 31.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_forms_and_arguments.expected
*/
// IEEE 1800-2023 §31.2, Syntax 31-1: the system timing checks are $setup,
// $hold, $setuphold, $recovery, $removal, $recrem, $skew, $timeskew,
// $fullskew, $period, $width and $nochange. Each takes its events and limits
// in a fixed order, and some optional arguments after them: a notifier, the
// timestamp and timecheck conditions and the delayed reference and data
// signals of $setuphold and $recrem, the event-based and remain-active flags
// of $timeskew and $fullskew. An optional argument can be left empty between
// commas, or left out with the arguments after it. The cell has every check,
// with the optional arguments in each of these forms; the inputs do not
// change, so no check reports a violation and the notifiers keep their
// initial values.

`timescale 1ns/1ns

module tcf_cell(input wire clk, input wire clk2, input wire d, input wire rst,
                input wire en);
  reg n1 = 1'b0, n2 = 1'b0;
  wire dclk, dd, drst, dclk2;
  specify
    specparam tsu = 2, th = 1, trec = 3, tw = 5, tp = 10;
    $setup(d, posedge clk, tsu);
    $setup(d, posedge clk, tsu, n1);
    $hold(posedge clk, d, th, );
    $setuphold(posedge clk, d, tsu, th, n1, en, en, dclk, dd);
    $setuphold(posedge clk, d, tsu, th, , , , , );
    $recovery(posedge rst, posedge clk, trec, n2);
    $removal(posedge rst, posedge clk, trec);
    $recrem(posedge rst, posedge clk, trec, trec, n2, , , drst, dclk2);
    $skew(posedge clk, posedge clk2, 2, n2);
    $timeskew(posedge clk, posedge clk2, 2, n2, 1, 0);
    $timeskew(posedge clk, posedge clk2, 2);
    $fullskew(posedge clk, negedge clk2, 2, 3, n2, 0, 1);
    $period(posedge clk, tp, n1);
    $width(posedge clk, tw, 0, n1);
    $width(negedge clk, tw, 1);
    $nochange(posedge clk, d, 0, 0, n2);
  endspecify
endmodule

module test_timing_check_forms_and_arguments;
  logic clk = 1'b0, clk2 = 1'b0, d = 1'b0, rst = 1'b0, en = 1'b1;
  tcf_cell u (.clk(clk), .clk2(clk2), .d(d), .rst(rst), .en(en));
  initial #1 $display("notifiers %b %b", u.n1, u.n2);
endmodule
