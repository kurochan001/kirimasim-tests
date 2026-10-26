/*
:name: test_always_forms_repeat
:description: always, always_comb, always_latch and always_ff repeat with their own triggers, and the language sets no limit on the number of procedures (IEEE 1800-2023 9.2, 9.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2 9.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_forms_repeat.expected
*/
// IEEE 1800-2023 §9.2: the always variants require a statement, and the
// language sets no limit on the number of procedures. §9.2.2: always repeats
// its statement, always_comb repeats on its implicit sensitivity, always_latch
// on its implicit sensitivity while holding its output, and always_ff on its
// event control.
// The test runs one process of each form and eight initial processes that each
// set one bit of a vector. A clock toggles every 5 ns; at 21 ns the always and
// always_ff processes have each run twice and the latch holds the value it
// took when enabled; at 26 ns, after the third posedge, they have each run
// three times. A form that does not repeat, or a latch that follows its data
// while disabled, prints a different line.

`timescale 1ns/1ps

module test_always_forms_repeat;
  bit clk = 0;
  int n_always = 0;
  int n_ff = 0;
  logic d = 1'b1;
  logic q;
  logic a = 1'b1;
  bit y;
  logic en = 1'b1;
  logic dl = 1'b1;
  logic ql;
  logic [7:0] bits;

  initial bits[0] = 1'b1;
  initial bits[1] = 1'b1;
  initial bits[2] = 1'b1;
  initial bits[3] = 1'b1;
  initial bits[4] = 1'b1;
  initial bits[5] = 1'b1;
  initial bits[6] = 1'b1;
  initial bits[7] = 1'b1;

  always #5 clk = ~clk;
  always @(posedge clk) n_always++;
  always_ff @(posedge clk) begin
    n_ff++;
    q <= d;
  end
  always_comb y = a;
  always_latch if (en) ql = dl;

  initial begin
    #21;
    $display("t21 always=%0d ff=%0d q=%0d y=%0d ql=%0d bits=%h",
             n_always, n_ff, q, y, ql, bits);
    en = 1'b0;
    dl = 1'b0;
    #5;
    $display("t26 always=%0d ff=%0d q=%0d y=%0d ql=%0d",
             n_always, n_ff, q, y, ql);
    $finish;
  end
endmodule
