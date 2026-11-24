/*
:name: test_elaboration_error_continues_across_parameter_instances
:description: Elaboration continues after an error to evaluate the same error call in another instance without starting simulation
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1 22.12 22.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_error_continues_across_parameter_instances.expected
:expected_stderr_regex: (?im)\A(?![\s\S]*^SIMULATION_STARTED$)(?=[\s\S]*^(?=[^\n]*logical_elab_error\.sv:313(?::|\b))(?=[^\n]*\berror\b)[^\n]*INSTANCE=1 LINE=313)(?=[\s\S]*^(?=[^\n]*logical_elab_error\.sv:313(?::|\b))(?=[^\n]*\berror\b)[^\n]*INSTANCE=2 LINE=313)
*/
module repeated_elaboration_error #(parameter int ID = 0);
  `line 313 "logical_elab_error.sv" 0
  $error("INSTANCE=%0d LINE=%0d", ID, `__LINE__);
  `line 20 "test_elaboration_error_continues_across_parameter_instances.sv" 0
endmodule

module test_elaboration_error_continues_across_parameter_instances;
  repeated_elaboration_error #(.ID(1)) first();
  repeated_elaboration_error #(.ID(2)) second();
  initial $display("SIMULATION_STARTED");
endmodule
