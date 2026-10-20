/*
:name: test_dollar_parameter_unbounded
:description: $ can be the value of a parameter, which $isunbounded then reports, also through another parameter, and $ stands for the open end of a value range and the last element of a queue (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.7 20.6.3 11.4.13 7.10.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dollar_parameter_unbounded.expected
*/
// IEEE 1800-2023 §6.20.7: $ may be assigned to a parameter, and such a
// parameter may be assigned to another; $isunbounded (20.6.3) is 1 for both,
// and 0 for a parameter with a number. In a value range, [lo:$] means every
// value from lo up and [$:hi] every value up to hi (11.4.13); in a queue
// select, $ is the last element (7.10.1).

module test_dollar_parameter_unbounded;
  parameter P = $;
  parameter Q = P;
  parameter R = 5;

  int q[$] = '{4, 7, 9};

  initial begin
    $display("unbounded: P=%0d Q=%0d R=%0d", $isunbounded(P), $isunbounded(Q),
             $isunbounded(R));
    $display("7 inside [5:$]: %0d, 7 inside [$:6]: %0d", 7 inside {[5:$]}, 7 inside {[$:6]});
    $display("q[$]=%0d", q[$]);
  end
endmodule
