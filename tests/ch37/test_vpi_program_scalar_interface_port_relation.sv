/*
:name: test_vpi_program_scalar_interface_port_relation
:description: Traverse a program's scalar interface port under the diagram interpretation
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.9 37.10 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_program_interface_port_relations.c
:expected_stdout: @test_vpi_program_scalar_interface_port_relation.expected
*/
interface scalar_port_link;
  logic bit_value;
endinterface

program scalar_port_program(scalar_port_link port_link);
  initial begin
    #1;
    $display("scalar interface data=%b", port_link.bit_value);
    $vt_program_interface_ports(0);
  end
endprogram

module test_vpi_program_scalar_interface_port_relation;
  scalar_port_link physical();
  scalar_port_program subject(physical);
  initial physical.bit_value = 1'b1;
endmodule
