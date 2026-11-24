/*
:name: test_sdf_task_arguments_override_configuration_scaling
:description: SDF scale-factor and scale-type task arguments independently override the selected configuration file
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_task_arguments_override_configuration_scaling.expected
*/
// Uses the SCALE_FACTORS and SCALE_TYPE directives in VCS configuration
// files.
`timescale 1ns/1ns
module sdf_scaling_leaf(input wire a, output wire y);
  assign y = a;
  specify
    (a => y) = 1;
  endspecify
endmodule
module sdf_scaling_scope(input wire a, output wire y);
  sdf_scaling_leaf cell_a(a, y);
endmodule
module test_sdf_task_arguments_override_configuration_scaling;
  bit trigger;
  wire [5:0] out;
  time edges[6];

  sdf_scaling_scope unconfigured(trigger, out[0]);
  sdf_scaling_scope configured(trigger, out[1]);
  sdf_scaling_scope factors_override(trigger, out[2]);
  sdf_scaling_scope type_override(trigger, out[3]);
  sdf_scaling_scope both_override(trigger, out[4]);
  sdf_scaling_scope other_config(trigger, out[5]);

  for (genvar i = 0; i < 6; i++) begin : g_edges
    always @(posedge out[i]) edges[i] = $time;
  end

  initial begin
    int f;
    f = $fopen("scaling.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "(CELL (CELLTYPE \"sdf_scaling_leaf\") (INSTANCE cell_a)");
    $fdisplay(f, "(DELAY (ABSOLUTE (IOPATH a y (2:5:11))))))");
    $fclose(f);

    f = $fopen("minimum.cfg", "w");
    $fdisplay(f, "SCALE_FACTORS = 2.0:3.0:4.0;");
    $fdisplay(f, "SCALE_TYPE = FROM_MINIMUM;");
    $fclose(f);
    f = $fopen("by_member.cfg", "w");
    $fdisplay(f, "SCALE_FACTORS = 1.0:2.0:3.0;");
    $fdisplay(f, "SCALE_TYPE = FROM_MTM;");
    $fclose(f);

    $sdf_annotate("scaling.sdf", unconfigured, , , "TYPICAL");
    $sdf_annotate("scaling.sdf", configured, "minimum.cfg", , "TYPICAL");
    $sdf_annotate("scaling.sdf", factors_override, "minimum.cfg", , "TYPICAL", "5.0:7.0:9.0");
    $sdf_annotate("scaling.sdf", type_override, "minimum.cfg", , "TYPICAL", , "FROM_MAXIMUM");
    $sdf_annotate("scaling.sdf", both_override, "minimum.cfg", , "TYPICAL",
                  "5.0:7.0:9.0", "FROM_MAXIMUM");
    $sdf_annotate("scaling.sdf", other_config, "by_member.cfg", , "TYPICAL");

    #100 trigger = 1;
    #100;
    $display("default=%0d config=%0d other=%0d",
             edges[0] - 100, edges[1] - 100, edges[5] - 100);
    $display("factor=%0d type=%0d both=%0d", edges[2] - 100, edges[3] - 100, edges[4] - 100);
  end
endmodule
