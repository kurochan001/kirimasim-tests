/*
:name: test_timing_window_endpoints_zero_limits
:description: $setup excludes both ends of its window, $hold and $recovery include the beginning and exclude the end of theirs, and none of the three reports a violation when its limit is zero (IEEE 1800-2023 Section 31.3.1)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.1 31.3.2 31.3.5 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_window_endpoints_zero_limits.expected
*/
// IEEE 1800-2023 §31.3.1: $setup(data, reference, limit) has the window from
// (timecheck - limit) to the timecheck, the reference event, and reports a
// data event (the timestamp) strictly inside it; neither end is part of it.
// §31.3.2: $hold(reference, data, limit) has the window from the reference
// event (the timestamp) to (timestamp + limit) and reports a data event (the
// timecheck) at the beginning or inside, not at the end. §31.3.5: $recovery
// has the same window and rule as $hold. With a zero limit none of the three
// ever reports a violation. §31.6: a violation toggles the notifier, which
// starts at 0. Each pair of checks has its own signals; the times at which
// each notifier changes are printed at the end.
//   $setup, limit 3 (and 0): sclk rises at 10, 20 and 30; sd changes at 7
//   (exactly 3 before), at 20 (with the edge) and at 28 (2 before): only 28.
//   $hold, limit 2 (and 0): hclk rises at 10, 20 and 30; hd changes at 10
//   (with the edge), 22 (exactly 2 after) and 31 (1 after): 10 and 31.
//   $recovery, limit 4 (and 0): rclr rises at 10, 30 and 50; rclk rises at
//   10 (together), 34 (exactly 4 after) and 53 (3 after): 10 and 53.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module twz_checks (input sclk, sd, hclk, hd, rclr, rclk);
  reg ns = 0, ns0 = 0, nh = 0, nh0 = 0, nr = 0, nr0 = 0;
  specify
    $setup(sd, posedge sclk, 3, ns);
    $setup(sd, posedge sclk, 0, ns0);
    $hold(posedge hclk, hd, 2, nh);
    $hold(posedge hclk, hd, 0, nh0);
    $recovery(posedge rclr, posedge rclk, 4, nr);
    $recovery(posedge rclr, posedge rclk, 0, nr0);
  endspecify
endmodule

module test_timing_window_endpoints_zero_limits;
  reg sclk = 0, sd = 0, hclk = 0, hd = 0, rclr = 0, rclk = 0;
  string ls = "", ls0 = "", lh = "", lh0 = "", lr = "", lr0 = "";

  twz_checks u (sclk, sd, hclk, hd, rclr, rclk);

  always @(u.ns) ls = {ls, $sformatf(" %0d", $time)};
  always @(u.ns0) ls0 = {ls0, $sformatf(" %0d", $time)};
  always @(u.nh) lh = {lh, $sformatf(" %0d", $time)};
  always @(u.nh0) lh0 = {lh0, $sformatf(" %0d", $time)};
  always @(u.nr) lr = {lr, $sformatf(" %0d", $time)};
  always @(u.nr0) lr0 = {lr0, $sformatf(" %0d", $time)};

  initial begin
    #7 sd = 1;              // 7: exactly 3 before the edge at 10
    #3 sclk = 1;            // 10
    #5 sclk = 0;
    #5 sclk = 1; sd = 0;    // 20: data with the edge
    #5 sclk = 0;
    #3 sd = 1;              // 28: 2 before the edge at 30
    #2 sclk = 1;            // 30
    #5 sclk = 0;
  end

  initial begin
    #10 hclk = 1; hd = 1;   // 10: data with the edge
    #5 hclk = 0;
    #5 hclk = 1;            // 20
    #2 hd = 0;              // 22: exactly 2 after the edge
    #3 hclk = 0;
    #5 hclk = 1;            // 30
    #1 hd = 1;              // 31: 1 after the edge
    #4 hclk = 0;
  end

  initial begin
    #10 rclr = 1; rclk = 1; // 10: together
    #5 rclr = 0; rclk = 0;
    #15 rclr = 1;           // 30
    #4 rclk = 1;            // 34: exactly 4 after
    #3 rclr = 0; rclk = 0;
    #13 rclr = 1;           // 50
    #3 rclk = 1;            // 53: 3 after
    #3 rclr = 0; rclk = 0;
  end

  initial begin
    #70 $display("$setup limit 3:%s", ls);
    $display("$setup limit 0:%s", ls0);
    $display("$hold limit 2:%s", lh);
    $display("$hold limit 0:%s", lh0);
    $display("$recovery limit 4:%s", lr);
    $display("$recovery limit 0:%s", lr0);
  end
endmodule
