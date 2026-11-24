/*
:name: test_vpi_control_scope_change_reports_selected_instance
:description: Interactive scope changes report the selected sibling instance
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_control_scope_change_reports_selected_instance.expected
:expected_exit: 0
:vpi_c: @test_vpi_control_scope_change_reports_selected_instance.c
*/
module scope_change_leaf;
endmodule

module test_vpi_control_scope_change_reports_selected_instance;
  scope_change_leaf first_child();
  scope_change_leaf second_child();

  initial begin
    #1 $request_scope_change;
    #1 $report_scope_change;
    $request_scope_change;
    #1 $report_scope_change;
  end
endmodule
