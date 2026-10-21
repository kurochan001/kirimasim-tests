/*
:name: test_illegal_width_notifier_without_threshold
:description: A $width check with a notifier has to give its threshold (IEEE 1800-2023 Section 31.4.4)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.4.4 31.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the $width check has a notifier but leaves the threshold empty
:expected_stderr_regex: test_illegal_width_notifier_without_threshold\.sv:24:
*/
// IEEE 1800-2023 §31.4.4: the threshold of $width can be left out together
// with the notifier, but if the notifier is present, a non-null threshold
// shall be present too; 0 gives the default threshold explicitly.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

`timescale 1ns/1ns

module timing_width_empty_threshold(input clk);
  reg n = 0;
  specify
    $width(posedge clk, 5, , n);   // illegal: notifier without a threshold
  endspecify
endmodule

module test_illegal_width_notifier_without_threshold;
  reg clk = 0;
  timing_width_empty_threshold u(clk);
  initial #10 clk = 1;
endmodule
