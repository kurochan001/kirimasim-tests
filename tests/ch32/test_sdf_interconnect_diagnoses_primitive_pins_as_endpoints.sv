/*
:name: test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints
:description: SDF INTERCONNECT does not accept named primitive input or output pins as endpoints
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^(?=[^\n]*(?:error|warning))(?=[^\n]*primitive_source\.pin_out)(?=[^\n]*(?:primitive|port|endpoint)))(?=[\s\S]*^(?=[^\n]*(?:error|warning))(?=[^\n]*primitive_load\.pin_in)(?=[^\n]*(?:primitive|port|endpoint)))[\s\S]*\Z
*/
`timescale 1ns/1ns
primitive interconnect_primitive(pin_out, pin_in);
  output pin_out;
  input pin_in;
  table
    0 : 0;
    1 : 1;
    x : x;
  endtable
endprimitive

module interconnect_endpoint_source(input wire stimulus, output wire drive_out);
  assign drive_out = stimulus;
endmodule

module interconnect_endpoint_load(input wire take_in, output wire observed);
  assign observed = take_in;
endmodule

module test_sdf_interconnect_diagnoses_primitive_pins_as_endpoints;
  bit stimulus;
  wire normal_line, first_line, second_line;
  wire regular_signal, from_primitive_signal, into_primitive_signal;
  time regular_time, primitive_load_time;
  interconnect_endpoint_source regular_source(stimulus, normal_line);
  interconnect_endpoint_load regular_load(normal_line, regular_signal);
  interconnect_primitive primitive_source(first_line, stimulus);
  interconnect_endpoint_load real_load(first_line, from_primitive_signal);
  interconnect_endpoint_source real_source(stimulus, second_line);
  interconnect_primitive primitive_load(into_primitive_signal, second_line);

  always @(posedge regular_signal) regular_time = $time;
  always @(posedge into_primitive_signal) primitive_load_time = $time;

  initial begin
    int sdf;
    sdf = $fopen("primitive_routes.sdf", "w");
    if (sdf == 0)
      $fatal(1, "could not create interconnect annotation");
    $fdisplay(sdf, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(sdf, "(CELL (CELLTYPE \"%m\") (INSTANCE)");
    $fdisplay(sdf, "(DELAY (ABSOLUTE");
    $fdisplay(sdf, "(INTERCONNECT regular_source.drive_out regular_load.take_in (3))");
    $fdisplay(sdf, "(INTERCONNECT primitive_source.pin_out real_load.take_in (5))");
    $fdisplay(sdf, "(INTERCONNECT real_source.drive_out primitive_load.pin_in (8))))))");
    $fclose(sdf);

    $display("annotating one module route and two primitive endpoints");
    $sdf_annotate("primitive_routes.sdf");
    #20 stimulus = 1;
    #10 $display("regular route=%0d primitive load path=%0d",
                 regular_time - 20, primitive_load_time - 20);
  end
endmodule
