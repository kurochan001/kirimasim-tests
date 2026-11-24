/*
:name: test_setuphold_uses_explicit_delayed_reference_for_both_checks
:description: Two setuphold checks of the same reference share one delayed clock signal
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_setuphold_uses_explicit_delayed_reference_for_both_checks.expected
*/
`timescale 1ns/1ns
module test_setuphold_uses_explicit_delayed_reference_for_both_checks;
  bit clock, early_data, late_data;
  wire delayed_clock, delayed_early;
  reg early_notify = 0, late_notify = 0;
  specify
    $setuphold(posedge clock, posedge early_data, -2, 12, early_notify, , ,
               delayed_clock, delayed_early);
    $setuphold(posedge clock, posedge late_data, -5, 13, late_notify);
  endspecify

  initial begin
    #20 clock = 1;
    #3 early_data = 1;
    #1 $display("at24 reference=%b delayed=%b early=%b", clock, delayed_clock, early_notify);
    #3 $display("at27 reference=%b delayed=%b early=%b", clock, delayed_clock, early_notify);
    #1 late_data = 1;
    #7 $display("early=%b late=%b", early_notify, late_notify);
  end
endmodule
