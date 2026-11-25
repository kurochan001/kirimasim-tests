/*
:name: test_selected_defaults_set_time_unit_and_precision
:description: Observe time unit and precision using two configured defaults and no source time declaration
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: default timing exercised
*/

module test_selected_defaults_set_time_unit_and_precision;
  localparam realtime ABSOLUTE_DELAY = 1ns;
  localparam realtime FRACTIONAL_DELAY = 0.263;
  realtime after_unit, after_literal, after_fraction;
  initial begin
    #1 after_unit = $realtime;
    #ABSOLUTE_DELAY after_literal = $realtime;
    #FRACTIONAL_DELAY after_fraction = $realtime;
    if ($test$plusargs("report_default_steps"))
      $display("unit=%.3f absolute=%.3f fraction=%.3f",
               after_unit, after_literal - after_unit, after_fraction - after_literal);
    $display("default timing exercised");
  end
endmodule
