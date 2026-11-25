/*
:name: test_vpi_control_requires_an_interactive_scope_handle
:description: Interactive scope changes accept scope handles and reject a variable
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_control_requires_an_interactive_scope_handle.c
:expected_stdout: @test_vpi_control_requires_an_interactive_scope_handle.expected
*/
module interactive_scope_leaf;
  reg marker = 1;
endmodule

module test_vpi_control_requires_an_interactive_scope_handle;
  interactive_scope_leaf first();
  interactive_scope_leaf second();

  initial begin
    $check_interactive_scope(0);
    if ($test$plusargs("observe_bad_scope"))
      $check_interactive_scope(1);
    $check_interactive_scope(2);
    $finish(0);
  end
endmodule
