/*
:name: test_vpi_diagram_definition_symbols
:description: Exercise scalar and vector net declarations from the object definition diagram
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.4.1 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_diagram_definition_symbols.expected
:files: vpi_diagram_key/definition.expected
*/
module diagram_definition_nets(input wire drive, output wire scalar_value,
                               output wire [3:0] vector_value);
  assign scalar_value = drive;
  assign vector_value = {2'b10, drive, ~drive};
endmodule

module test_vpi_diagram_definition_symbols;
  wire scalar_net;
  wire [3:0] vector_net;
  logic drive = 0;
  diagram_definition_nets child(drive, scalar_net, vector_net);

  initial begin
    #1 $display("definitions widths=%0d/%0d values=%b/%b",
                $bits(child.scalar_value), $bits(child.vector_value), scalar_net, vector_net);
    drive = 1;
    #1 $display("definitions changed=%b/%b", scalar_net, vector_net);
    $finish(0);
  end
endmodule
