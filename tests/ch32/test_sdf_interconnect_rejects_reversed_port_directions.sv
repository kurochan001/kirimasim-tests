/*
:name: test_sdf_interconnect_rejects_reversed_port_directions
:description: SDF INTERCONNECT cannot use an input-only source or an output-only load
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_rejects_reversed_port_directions.expected
:expected_stderr_regex: \A(?=[\s\S]*(?im:^[^\n]*(?:warn|error)[^\n]*input_as_source\.pin[^\n]*(?:direction|output|inout)))(?=[\s\S]*(?im:^[^\n]*(?:warn|error)[^\n]*output_as_load\.pin[^\n]*(?:direction|input|inout)))
*/
`timescale 1ns/1ns

module directed_sdf_driver(input value, output pin);
  assign pin = value;
endmodule

module directed_sdf_load(input pin, output value);
  assign value = pin;
endmodule

module directed_sdf_input(input pin);
endmodule

module directed_sdf_output(output pin);
endmodule

module test_sdf_interconnect_rejects_reversed_port_directions;
  logic stimulus = 0;
  wire legal_net, reverse_source_net, reverse_load_net;
  wire legal_value, other_value;
  string legal_changes = "";
  integer sdf_file_handle;

  directed_sdf_driver valid_source(stimulus, legal_net);
  directed_sdf_driver isolated_driver(stimulus, reverse_source_net);
  directed_sdf_driver other_source(stimulus, reverse_load_net);
  directed_sdf_load valid_load(legal_net, legal_value);
  directed_sdf_load alternate_load(reverse_source_net, other_value);
  directed_sdf_input input_as_source(reverse_source_net);
  directed_sdf_output output_as_load(reverse_load_net);

  always @(valid_load.pin) if ($time >= 10)
    legal_changes = {legal_changes, $sformatf(" %0d:%b", $time, valid_load.pin)};

  initial begin
    sdf_file_handle = $fopen("direction_checks.sdf", "w");
    if (!sdf_file_handle) $fatal(1, "cannot create SDF fixture");
    $fdisplay(sdf_file_handle, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(sdf_file_handle, "  (CELL (CELLTYPE \"%m\") (INSTANCE)");
    $fdisplay(sdf_file_handle, "    (DELAY (ABSOLUTE");
    $fdisplay(sdf_file_handle, "      (INTERCONNECT valid_source.pin valid_load.pin (3))");
    $fdisplay(sdf_file_handle, "      (INTERCONNECT input_as_source.pin alternate_load.pin (5))");
    $fdisplay(sdf_file_handle, "      (INTERCONNECT other_source.pin output_as_load.pin (7))");
    $fdisplay(sdf_file_handle, "  ))))");
    $fclose(sdf_file_handle);
    $sdf_annotate("direction_checks.sdf");
    #10 stimulus = 1;
    #20 stimulus = 0;
    #10;
    $display("valid output to input:%s", legal_changes);
    $finish;
  end
endmodule
