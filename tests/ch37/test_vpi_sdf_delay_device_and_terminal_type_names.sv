/*
:name: test_vpi_sdf_delay_device_and_terminal_type_names
:description: An SDF interconnect gives its delay device and terminals the intermodule subtype and name
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.2 37.3.1 37.45 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_sdf_delay_device_and_terminal_type_names.c
:expected_stdout: @test_vpi_sdf_delay_device_and_terminal_type_names.expected
*/
`timescale 1ns/1ns
module subtype_delay_driver(input wire d, output wire q);
  assign q = d;
endmodule

module subtype_delay_receiver(input wire d, output wire q);
  assign q = d;
endmodule

module test_vpi_sdf_delay_device_and_terminal_type_names;
  reg drive = 0;
  wire branch, received;
  subtype_delay_driver source(drive, branch);
  subtype_delay_receiver sink(branch, received);

  initial begin
    integer file;
    file = $fopen("subtype_interconnect.sdf", "w");
    $fdisplay(file, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(file, "  (CELL (CELLTYPE \"test_vpi_sdf_delay_device_and_terminal_type_names\")");
    $fdisplay(file, "    (INSTANCE)");
    $fdisplay(file, "    (DELAY (ABSOLUTE (INTERCONNECT source.q sink.d (5))))))");
    $fclose(file);
    $sdf_annotate("subtype_interconnect.sdf", test_vpi_sdf_delay_device_and_terminal_type_names);
    #7;
    $vt_delay_type_names;
    drive = 1;
    #1 $display("interconnect source=%b sink=%b", branch, sink.d);
    #5 $display("interconnect source=%b sink=%b", branch, sink.d);
  end
endmodule
