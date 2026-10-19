/*
:name: test_timing_skew_checks
:description: $skew reports every data edge more than the limit after the latest reference edge, $timeskew reports once when the limit has elapsed without a data edge and then goes dormant, and $fullskew does the same in both directions with a limit for each (IEEE 1800-2023 Sections 31.4.1, 31.4.2, 31.4.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.1 31.4.2 31.4.3 31.4 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_skew_checks.expected
*/
// IEEE 1800-2023 §31.4.1: $skew(posedge r, posedge d, 5, n) is event-based: at
// each d edge it reports a violation if the latest r edge was more than 5
// before, for every d edge, never for simultaneous edges. §31.4.2: $timeskew
// is timer-based by default: it reports when 5 have passed after an r edge
// without a d edge and then stays dormant until the next r edge; a d edge in
// time makes it dormant without a report, and an r edge exactly when the limit
// expires is no violation but starts a new window. §31.4.3: $fullskew(posedge
// r, posedge d, 5, 8, n) is timer-based too; an r edge waits up to 5 for a d
// edge and a d edge up to 8 for an r edge. §31.6: each violation toggles the
// notifier; the test records when. Each check has its own pair of signals.

`timescale 1ns/1ns

module timing_skews(input r1, d1, r2, d2, r3, d3);
  reg n_skew = 0, n_timeskew = 0, n_fullskew = 0;
  specify
    $skew(posedge r1, posedge d1, 5, n_skew);
    $timeskew(posedge r2, posedge d2, 5, n_timeskew);
    $fullskew(posedge r3, posedge d3, 5, 8, n_fullskew);
  endspecify
endmodule

module test_timing_skew_checks;
  reg r1 = 0, d1 = 0, r2 = 0, d2 = 0, r3 = 0, d3 = 0;
  // Times of the rising edges; each signal falls 1 after it rises.
  int r1_at[] = '{10, 20, 40, 60}, d1_at[] = '{13, 27, 34, 42, 50, 60};
  int r2_at[] = '{10, 30, 50, 55}, d2_at[] = '{13, 20, 38};
  int r3_at[] = '{10, 26, 60}, d3_at[] = '{14, 20, 40};
  int t_skew[$], t_timeskew[$], t_fullskew[$];

  timing_skews u(r1, d1, r2, d2, r3, d3);

  always @(u.n_skew) t_skew.push_back($time);
  always @(u.n_timeskew) t_timeskew.push_back($time);
  always @(u.n_fullskew) t_fullskew.push_back($time);

  initial foreach (r1_at[i]) begin #(r1_at[i] - $time) r1 = 1; #1 r1 = 0; end
  initial foreach (d1_at[i]) begin #(d1_at[i] - $time) d1 = 1; #1 d1 = 0; end
  initial foreach (r2_at[i]) begin #(r2_at[i] - $time) r2 = 1; #1 r2 = 0; end
  initial foreach (d2_at[i]) begin #(d2_at[i] - $time) d2 = 1; #1 d2 = 0; end
  initial foreach (r3_at[i]) begin #(r3_at[i] - $time) r3 = 1; #1 r3 = 0; end
  initial foreach (d3_at[i]) begin #(d3_at[i] - $time) d3 = 1; #1 d3 = 0; end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #80;
    $display("$skew:%s", times(t_skew));
    $display("$timeskew:%s", times(t_timeskew));
    $display("$fullskew:%s", times(t_fullskew));
    $finish;
  end
endmodule
