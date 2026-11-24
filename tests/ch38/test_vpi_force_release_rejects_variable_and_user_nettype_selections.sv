/*
:name: test_vpi_force_release_rejects_variable_and_user_nettype_selections
:description: VPI force and release reject bit and part selections on variables and user-defined nets, with ordinary net selections as controls
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2 37.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_force_release_rejects_variable_and_user_nettype_selections.c
:expected_stdout: @test_vpi_force_release_rejects_variable_and_user_nettype_selections.expected
*/
module test_vpi_force_release_rejects_variable_and_user_nettype_selections;
  nettype bit [7:0] byte_net;
  logic [7:0] variable_value = 8'h00;
  byte_net custom_value;
  wire [7:0] ordinary_value;
  assign custom_value = 8'h40;
  assign ordinary_value = 8'h20;

  initial begin
    #1;
    $display("bit selections");
    $vt_force_selects(variable_value[1], custom_value[1], ordinary_value[1]);
    #1;
    $display("after force=%h %h %h", variable_value, custom_value, ordinary_value);
    $vt_release_selects(variable_value[1], custom_value[1], ordinary_value[1]);
    #1;
    $display("after release=%h %h %h", variable_value, custom_value, ordinary_value);
    variable_value = 8'h00;
    #1;
    $display("part selections");
    $vt_force_selects(variable_value[3:2], custom_value[3:2], ordinary_value[3:2]);
    #1;
    $display("after force=%h %h %h", variable_value, custom_value, ordinary_value);
    $vt_release_selects(variable_value[3:2], custom_value[3:2], ordinary_value[3:2]);
    #1;
    $display("after release=%h %h %h", variable_value, custom_value, ordinary_value);
  end
endmodule
