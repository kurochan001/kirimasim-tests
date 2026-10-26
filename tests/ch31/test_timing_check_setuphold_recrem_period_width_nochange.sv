/*
:name: test_timing_check_setuphold_recrem_period_width_nochange
:description: $setuphold and $recrem take two limits, $period takes a controlled reference event, $width adds a threshold after its limit, and $nochange takes start and end edge offsets; their windows and toggles follow Sections 31.3.3, 31.3.6, 31.4.4, 31.4.5 and 31.4.6 (IEEE 1800-2023 Sections 31.3.3, 31.3.6, 31.4.4, 31.4.5, 31.4.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.3.6 31.4.4 31.4.5 31.4.6 31.6 A.7.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_setuphold_recrem_period_width_nochange.expected
*/
// IEEE 1800-2023 A.7.5.1, Syntax 31-1: $setuphold and $recrem take a
// reference event, a data event and two limits; $period takes a controlled
// reference event and a limit; $width takes a controlled reference event, a
// limit and a threshold; $nochange takes a reference event, a data event, a
// start edge offset and an end edge offset. Each takes an optional notifier.
// §31.3.3: $setuphold is a $setup with its first limit and a $hold with its
// second, so the data must not change inside either window. §31.3.6: $recrem
// does the same for $removal and $recovery. §31.4.4: $width violates when the
// pulse width is greater than the threshold and less than the limit.
// §31.4.5: $period violates when two edges of the reference event are less
// than the limit apart. §31.4.6: $nochange violates when the data changes
// strictly inside the high level of the reference signal, with offsets that
// extend or shrink the region; both offsets are 0 here. §31.6: each violation
// toggles the notifier, and the test prints all notifiers at each change.
//
// The stimulus makes one violation of each check and then a second one, at
// times 13, 15, 18, 20, 31, 35, 36, 41, 42 and 52, so every printed line
// changes exactly one notifier.

`timescale 1ns/1ns

module tc_setuphold (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $setuphold(posedge clk, d, 3, 2, n);
  endspecify
endmodule

module tc_recrem (input wire rst, input wire clk);
  reg n = 1'b0;
  specify
    $recrem(posedge rst, posedge clk, 3, 2, n);
  endspecify
endmodule

module tc_period (input wire clk);
  reg n = 1'b0;
  specify
    $period(posedge clk, 10, n);
  endspecify
endmodule

module tc_width (input wire clk);
  reg n = 1'b0;
  specify
    $width(posedge clk, 5, 1, n);
  endspecify
endmodule

module tc_nochange (input wire clk, input wire d);
  reg n = 1'b0;
  specify
    $nochange(posedge clk, d, 0, 0, n);
  endspecify
endmodule

module test_timing_check_setuphold_recrem_period_width_nochange;
  reg c_sh = 1'b0, d_sh = 1'b0;
  reg r_rc = 1'b0, c_rc = 1'b0;
  reg c_p = 1'b0, c_w = 1'b0;
  reg c_n = 1'b0, d_n = 1'b0;

  tc_setuphold u_sh (c_sh, d_sh);
  tc_recrem u_rc (r_rc, c_rc);
  tc_period u_p (c_p);
  tc_width u_w (c_w);
  tc_nochange u_n (c_n, d_n);

  always @(u_sh.n or u_rc.n or u_p.n or u_w.n or u_n.n)
    if ($time > 0)
      $display("%0d: setuphold=%b recrem=%b period=%b width=%b nochange=%b",
               $time, u_sh.n, u_rc.n, u_p.n, u_w.n, u_n.n);

  initial begin
    #10 c_sh = 1'b1;
    #2  c_sh = 1'b0;
    #6  d_sh = 1'b1;
    #2  c_sh = 1'b1;
    #2  c_sh = 1'b0;
    #2  d_sh = 1'b0;
    #6  c_sh = 1'b1;
    #1  d_sh = 1'b1;
    #2  c_sh = 1'b0;
  end

  initial begin
    #40 c_rc = 1'b1;
    #1  r_rc = 1'b1;
    #4  c_rc = 1'b0;
    #4  r_rc = 1'b0;
    #1  r_rc = 1'b1;
    #2  c_rc = 1'b1;
    #4  c_rc = 1'b0;
  end

  initial begin
    #10 c_p = 1'b1;
    #4  c_p = 1'b0;
    #4  c_p = 1'b1;
    #4  c_p = 1'b0;
    #6  c_p = 1'b1;
    #4  c_p = 1'b0;
    #4  c_p = 1'b1;
    #4  c_p = 1'b0;
  end

  initial begin
    #10 c_w = 1'b1;
    #3  c_w = 1'b0;
    #7  c_w = 1'b1;
    #5  c_w = 1'b0;
    #5  c_w = 1'b1;
    #1  c_w = 1'b0;
    #9  c_w = 1'b1;
    #2  c_w = 1'b0;
  end

  initial begin
    #10 c_n = 1'b1;
    #5  d_n = 1'b1;
    #5  c_n = 1'b0;
    #10 c_n = 1'b1;
    #5  d_n = 1'b0;
    #5  c_n = 1'b0;
  end

  initial #100 $finish;
endmodule
