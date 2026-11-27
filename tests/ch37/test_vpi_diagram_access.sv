/*
:name: test_vpi_diagram_access
:description: Traverse the instance group and check typed scalar and vector net properties
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3 37.4.1 37.10 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_diagram_access.c
:expected_stdout: @test_vpi_diagram_access.expected
:files: vpi_diagram_key/notation.expected
*/
`timescale 1ns/1ns

package diagram_group_package;
  int sample_value = 11;
endpackage

interface diagram_group_interface;
  int sample_value = 22;
endinterface

program diagram_group_program;
  int sample_value = 33;
  initial #3;
endprogram

module diagram_group_module;
  int sample_value = 44;
  wire scalar_net = 0;
  wire [3:0] vector_net = 4'b1010;
endmodule

module test_vpi_diagram_access;
  diagram_group_interface local_if();
  diagram_group_program local_program();
  diagram_group_module local_module();

  initial begin
    #1 $vt_diagram_access;
    $finish(0);
  end
endmodule
