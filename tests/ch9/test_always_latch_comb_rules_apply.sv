/*
:name: test_always_latch_comb_rules_apply
:description: The always_comb rules apply to always_latch: it runs once at time zero, so an enable that is already 1 sets the output without any input change; it is sensitive to a variable read only inside a function it calls; and an element it writes and another element written by a continuous assignment each follow their own source (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_latch_comb_rules_apply.expected
*/
// IEEE 1800-2023 §9.2.2.3: always_latch is the same construct as
// always_comb apart from the checks tools make, and everything §9.2.2.2
// says applies to it. So an always_latch
// - is triggered once at time zero, after all initial and always procedures
//   have started (§9.2.2.2);
// - is sensitive to the variables read inside the functions it calls, not
//   only to their arguments (§9.2.2.2.1, §9.2.2.2.2);
// - may write one element of a variable while another process writes
//   another element, when the longest static prefixes do not overlap
//   (§9.2.2.2, §11.5.3).
// The enable en and the inputs d, k and s get their values from declaration
// initializers, which run before any procedure starts, so nothing changes at
// time zero. q0 and q1 are two-state and start at 0.
// - Line t1: q0 = d = 5 and q1 = 1 + k = 4 come only from the time-zero run;
//   an always_latch that waited for a change, like always @*, would leave
//   both at 0. arr[0] = d + 10 = 15 comes from an always_latch and
//   arr[1] = s = 7 from a continuous assignment.
// - Line t2: k becomes 20. k is read only inside plus_k, whose argument is
//   the constant 1, so only a sensitivity to the function body updates q1 to
//   21; with the sensitivity of always @* q1 would stay 4.
// - Line t3: d becomes 6, so q0 = 6 and arr[0] = 16, while arr[1] stays 7.
// - Line t4: s becomes 9, so arr[1] = 9, while arr[0] stays 16.
// Each change comes 1 time unit before the line that shows it.

module test_always_latch_comb_rules_apply;
  logic en = 1'b1;
  logic [7:0] d = 8'd5, k = 8'd3, s = 8'd7;
  bit [7:0] q0, q1;
  bit [7:0] arr [0:1];

  function automatic bit [7:0] plus_k(bit [7:0] v);
    return v + k;
  endfunction

  always_latch if (en) q0 = d;
  always_latch if (en) q1 = plus_k(8'd1);
  always_latch if (en) arr[0] = d + 8'd10;
  assign arr[1] = s;

  initial begin
    #1 $display("t1 q0=%0d q1=%0d arr=%0d,%0d", q0, q1, arr[0], arr[1]);
    k = 8'd20;
    #1 $display("t2 q0=%0d q1=%0d arr=%0d,%0d", q0, q1, arr[0], arr[1]);
    d = 8'd6;
    #1 $display("t3 q0=%0d q1=%0d arr=%0d,%0d", q0, q1, arr[0], arr[1]);
    s = 8'd9;
    #1 $display("t4 q0=%0d q1=%0d arr=%0d,%0d", q0, q1, arr[0], arr[1]);
  end
endmodule
