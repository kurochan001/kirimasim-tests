/*
:name: test_elaboration_error_reports_each_instance_at_shared_source_site
:description: Elaboration reports each instantiated occurrence of one error call at the logical source location and prevents simulation
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10.1 22.12 22.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_error_reports_each_instance_at_shared_source_site.expected
:expected_stderr_regex: (?im)\A(?![\s\S]*^SIMULATION_STARTED$)(?=[\s\S]*^(?=[^\n]*logical_elab_error\.sv:313(?::|\b))(?=[^\n]*\berror\b)[^\n]*INSTANCE=1 FILE=logical_elab_error\.sv LINE=313)(?=[\s\S]*^(?=[^\n]*logical_elab_error\.sv:313(?::|\b))(?=[^\n]*\berror\b)[^\n]*INSTANCE=2 FILE=logical_elab_error\.sv LINE=313)(?=[\s\S]*\btest_elaboration_error_reports_each_instance_at_shared_source_site\.first\b)(?=[\s\S]*\btest_elaboration_error_reports_each_instance_at_shared_source_site\.second\b)
*/
module repeated_elaboration_error #(parameter int ID = 0);
  `line 313 "logical_elab_error.sv" 0
  $error("INSTANCE=%0d FILE=%s LINE=%0d", ID, `__FILE__, `__LINE__);
  `line 20 "test_elaboration_error_reports_each_instance_at_shared_source_site.sv" 0
endmodule

module test_elaboration_error_reports_each_instance_at_shared_source_site;
  repeated_elaboration_error #(.ID(1)) first();
  repeated_elaboration_error #(.ID(2)) second();
  initial $display("SIMULATION_STARTED");
endmodule
