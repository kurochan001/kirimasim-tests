/*
:name: test_sdf_log_file_records_each_annotated_path
:description: Two distinct specify paths receive different SDF delays using a requested annotation log
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_log_file_records_each_annotated_path.expected
*/
`timescale 1ns/1ns
module sdf_logged_paths(input wire source, output wire destination_a, destination_b);
  assign destination_a = source;
  assign destination_b = source;
  specify
    (source => destination_a) = 1;
    (source => destination_b) = 1;
  endspecify
endmodule
module test_sdf_log_file_records_each_annotated_path;
  bit source;
  wire destination_a, destination_b;
  time at_a, at_b;

  sdf_logged_paths observed(source, destination_a, destination_b);
  always @(posedge destination_a) at_a = $time;
  always @(posedge destination_b) at_b = $time;

  initial begin
    int f;
    f = $fopen("paths.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "(CELL (CELLTYPE \"sdf_logged_paths\") (INSTANCE observed)");
    $fdisplay(f, "(DELAY (ABSOLUTE (IOPATH source destination_a (3))");
    $fdisplay(f, "                  (IOPATH source destination_b (7))))))");
    $fclose(f);
    $sdf_annotate("paths.sdf", , , "selected_annotation.log");
    #20 source = 1;
    #10 $display("a=%0d b=%0d", at_a - 20, at_b - 20);
  end
endmodule
