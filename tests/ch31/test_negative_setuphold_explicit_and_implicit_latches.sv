/*
:name: test_negative_setuphold_explicit_and_implicit_latches
:description: compare functional data from explicit negative timing copies with data latched on the original clock
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.3 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_setuphold_explicit_and_implicit_latches.expected
*/
// Enable negative timing checks as specified in §31.9.4.
`timescale 1ns/1ns
module negative_latch_explicit(input wire clock, data);
  wire delayed_clock, delayed_data;
  reg notice = 0, latched = 0;
  time clock_edge = 0, notice_edge = 0;
  int notices = 0;

  specify
    $setuphold(posedge clock, data, -10, 20, notice, , , delayed_clock, delayed_data);
  endspecify

  always @(posedge delayed_clock) begin
    clock_edge = $time;
    latched <= delayed_data;
  end
  always @(notice) if ($time != 0) begin
    notice_edge = $time;
    notices++;
  end
endmodule

module negative_latch_implicit(input wire clock, data);
  reg notice = 0, latched = 0;
  time notice_edge = 0;
  int notices = 0;

  specify
    $setuphold(posedge clock, data, -10, 20, notice);
  endspecify

  always @(posedge clock) latched <= data;
  always @(notice) if ($time != 0) begin
    notice_edge = $time;
    notices++;
  end
endmodule

module test_negative_setuphold_explicit_and_implicit_latches;
  bit clock, data;
  negative_latch_explicit explicit_copy(clock, data);
  negative_latch_implicit implicit_copy(clock, data);

  initial begin
    // Open violation interval (40, 50). The data settles before it.
    #30 clock = 1;
    #5 data = 1;
    #16;
    $display("stable: delayed edge=%0d latched=%b raw=%b notices=%0d,%0d",
             explicit_copy.clock_edge, explicit_copy.latched, implicit_copy.latched,
             explicit_copy.notices, implicit_copy.notices);
    #4 clock = 0;
    #5 data = 0;

    // Open violation interval (100, 110). This time the data changes inside.
    #30 clock = 1;
    #15 data = 1;
    #6;
    $display("violation: delayed edge=%0d notices=%0d,%0d at=%0d,%0d",
             explicit_copy.clock_edge, explicit_copy.notices, implicit_copy.notices,
             explicit_copy.notice_edge, implicit_copy.notice_edge);
    $finish;
  end
endmodule
