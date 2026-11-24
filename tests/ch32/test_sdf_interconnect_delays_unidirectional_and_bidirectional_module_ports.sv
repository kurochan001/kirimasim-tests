/*
:name: test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports
:description: SDF annotates paths between independent module ports without specify declarations
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports.expected
*/
`timescale 1ns/1ns
module sdf_port_routes_source(input wire stimulus, output wire drive_out, inout wire drive_io);
  assign drive_out = stimulus;
  assign drive_io = stimulus;
endmodule

module sdf_port_routes_load(input wire take_in, inout wire take_io,
                            output wire observed_in, observed_io);
  assign observed_in = take_in;
  assign observed_io = take_io;
endmodule

module test_sdf_interconnect_delays_unidirectional_and_bidirectional_module_ports;
  bit stimulus;
  wire line_regular, line_inout, observed_regular, observed_inout;
  time t_regular, t_inout;
  sdf_port_routes_source source(stimulus, line_regular, line_inout);
  sdf_port_routes_load destination(line_regular, line_inout, observed_regular, observed_inout);

  always @(posedge observed_regular) t_regular = $time;
  always @(posedge observed_inout) t_inout = $time;

  initial begin
    int sdf;
    sdf = $fopen("port_routes.sdf", "w");
    if (sdf == 0)
      $fatal(1, "could not create interconnect annotation");
    $fdisplay(sdf, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(sdf, "(CELL (CELLTYPE \"%m\") (INSTANCE)");
    $fdisplay(sdf, "(DELAY (ABSOLUTE");
    $fdisplay(sdf, "(INTERCONNECT source.drive_out destination.take_in (4))");
    $fdisplay(sdf, "(INTERCONNECT source.drive_io destination.take_io (7))))))");
    $fclose(sdf);

    $sdf_annotate("port_routes.sdf");
    #20 stimulus = 1;
    #10 $display("output to input=%0d inout to inout=%0d", t_regular - 20, t_inout - 20);
  end
endmodule
