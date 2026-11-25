/*
:name: test_vpi_program_array_interface_port_relation
:description: Traverse a program's interface array port under the diagram interpretation
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.9 37.10 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_program_interface_port_relations.c
:expected_stdout: @test_vpi_program_array_interface_port_relation.expected
*/
interface array_port_link;
  logic bit_value;
endinterface

program array_port_program(array_port_link port_link[2]);
  initial begin
    #1;
    $display("array interface data=%b%b", port_link[0].bit_value, port_link[1].bit_value);
    $vt_program_interface_ports(1);
  end
endprogram

module test_vpi_program_array_interface_port_relation;
  array_port_link physical[2]();
  array_port_program subject(physical);
  initial begin
    physical[0].bit_value = 1'b0;
    physical[1].bit_value = 1'b1;
  end
endmodule
