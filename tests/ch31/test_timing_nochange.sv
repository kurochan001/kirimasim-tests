/*
:name: test_timing_nochange
:description: $nochange reports a data change while the reference signal is at the level after its edge, not at the leading or trailing edge itself, and its offsets move the start of that window earlier and the end of it earlier or later (IEEE 1800-2023 Section 31.4.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.6 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_nochange.expected
*/
// IEEE 1800-2023 §31.4.6: $nochange(posedge en, d, start, end, n) reports a d
// change strictly between (leading edge - start) and (trailing edge + end),
// that is, while en is high when both offsets are zero; changes at the edges
// themselves are not violations. A positive start offset starts the window
// earlier and a negative end offset ends it earlier. §31.6: each violation
// toggles the notifier. Each pulse of en is high for 10, and d changes once
// per pulse: in the middle, with the leading edge, with the trailing edge, 1
// before the trailing edge, and 1 before the leading edge. The test prints how
// many times each notifier changed during each pulse.

`timescale 1ns/1ns

module timing_nochange(input en, input d);
  reg n = 0, n_offsets = 0;
  specify
    $nochange(posedge en, d, 0, 0, n);
    $nochange(posedge en, d, 2, -1, n_offsets);
  endspecify
endmodule

module test_timing_nochange;
  reg en = 0, d = 0;
  int c = 0, c_offsets = 0;

  timing_nochange u(en, d);

  always @(u.n) c++;
  always @(u.n_offsets) c_offsets++;

  // A pulse of en from 10 to 20 after the call, with d changing at d_at.
  task automatic pulse(string name, int d_at);
    fork
      begin #10 en = 1; #10 en = 0; end
      begin #(d_at) d = ~d; end
    join
    #10;
    $display("%s: offsets 0 and 0: %0d, offsets 2 and -1: %0d", name, c, c_offsets);
    c = 0;
    c_offsets = 0;
  endtask

  initial begin
    pulse("d inside", 15);
    pulse("d with the leading edge", 10);
    pulse("d with the trailing edge", 20);
    pulse("d 1 before the trailing edge", 19);
    pulse("d 1 before the leading edge", 9);
    $finish;
  end
endmodule
