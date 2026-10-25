/*
:name: test_for_unknown_condition_exits
:description: A for loop whose condition evaluates to x or z treats it as zero and exits without running the body again, at the first test or after some iterations (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1 12.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_for_unknown_condition_exits.expected
*/
// IEEE 1800-2023 §12.7.1: when the condition of a for loop evaluates to an
// unknown or high-impedance value, it is treated as zero, so the loop exits
// as it does for a false condition (12.4).
//
// The loops count their iterations. Their conditions are a 1-bit variable
// that the step sets to x or z after the first iteration, a comparison with
// a limit that is x or z from the start, and a comparison with a limit that
// the body changes from 10 to x or z in the second iteration. A loop whose
// step sets the variable to 1 again would run until its break, so the
// counts show where each loop stopped.

module test_for_unknown_condition_exits;
  logic c;
  logic [3:0] lim;
  int count;

  initial begin
    count = 0;
    for (c = 1'b1; c; c = 1'bx) count++;
    $display("1-bit condition set to x by the step: %0d iteration(s), c=%b", count, c);
    count = 0;
    for (c = 1'b1; c; c = 1'bz) count++;
    $display("1-bit condition set to z by the step: %0d iteration(s), c=%b", count, c);
    count = 0;
    for (c = 1'b1; c; c = 1'b1) begin
      count++;
      if (count == 4) break;
    end
    $display("1-bit condition kept at 1: %0d iteration(s) until break", count);

    count = 0;
    lim = 4'bxxxx;
    for (int k = 0; k < lim; k++) count++;
    $display("k < 4'bxxxx: %0d iteration(s)", count);
    count = 0;
    lim = 4'bzzzz;
    for (int k = 0; k < lim; k++) count++;
    $display("k < 4'bzzzz: %0d iteration(s)", count);

    count = 0;
    lim = 4'd10;
    for (int k = 0; k < lim; k++) begin
      count++;
      if (k == 1) lim = 4'bx;
    end
    $display("limit 10 changed to x in iteration 2: %0d iteration(s)", count);
    count = 0;
    lim = 4'd10;
    for (int k = 0; k < lim; k++) begin
      count++;
      if (k == 1) lim = 4'bz;
    end
    $display("limit 10 changed to z in iteration 2: %0d iteration(s)", count);
  end
endmodule
