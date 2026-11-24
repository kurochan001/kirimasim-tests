/*
:name: test_time_literal_parameter_overrides_use_instantiating_scope_units
:description: A module parameter default and two instance overrides scale the same time literal in their respective scopes
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8 23.10.2 3.14.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_parameter_overrides_use_instantiating_scope_units.expected
*/
module literal_parameter_cell #(parameter realtime VALUE = 125ps) ();
  timeunit 10ns;
  timeprecision 1ns;
  localparam realtime CALIBRATION = 125ps;
endmodule

module literal_parameter_parent;
  timeunit 1ns;
  timeprecision 100ps;
  literal_parameter_cell #(.VALUE(125ps)) middle();
endmodule

module test_time_literal_parameter_overrides_use_instantiating_scope_units;
  timeunit 1ps;
  timeprecision 1ps;
  literal_parameter_cell with_default();
  literal_parameter_parent parent_scope();
  literal_parameter_cell #(.VALUE(125ps)) direct();

  initial #1 begin
    $display("values=%0.4f/%0.4f/%0.4f", with_default.VALUE,
             parent_scope.middle.VALUE, direct.VALUE);
    $display("local=%0.4f/%0.4f/%0.4f", with_default.CALIBRATION, parent_scope.middle.CALIBRATION,
             direct.CALIBRATION);
    $finish(0);
  end
endmodule
