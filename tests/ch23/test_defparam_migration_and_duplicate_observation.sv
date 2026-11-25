/*
:name: test_defparam_migration_and_duplicate_observation
:description: Inline parameter overrides preserve the elaborated legacy width
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 C.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_defparam_migration_and_duplicate_observation
:files: defparam_migration/leaves.sv
:expected_stdout: @test_defparam_migration_and_duplicate_observation.expected
*/
`timescale 1ns/1ns
module test_defparam_migration_and_duplicate_observation;
`ifdef CROSS_SOURCE_OVERRIDES
  wire [31:0] observed;
  legacy_width_branch contested(observed);
`ifndef OMIT_OUTER_OVERRIDE
  defparam contested.leaf.WIDTH = 9;
`endif
  initial begin
    #1 $display("cross-source=%0d width=%0d", observed, contested.leaf.WIDTH);
    $finish(0);
  end
`else
  wire [31:0] legacy, named, ordered;
  legacy_width_branch prior(legacy);
  defparam prior.leaf.WIDTH = 9;
  inline_width_branch #(.WIDTH(9)) replaced(named);
  width_leaf #(5, 9) positional(ordered);

`ifdef OBSERVE_SAME_SOURCE
  wire [31:0] same_file;
  width_leaf boundary(same_file);
`ifdef REVERSE_SAME_SOURCE
  defparam boundary.WIDTH = 9;
  defparam boundary.WIDTH = 7;
`else
  defparam boundary.WIDTH = 7;
  defparam boundary.WIDTH = 9;
`endif
`endif

  initial begin
    #1 $display("legacy=%0d named=%0d ordered=%0d", legacy, named, ordered);
`ifdef OBSERVE_SAME_SOURCE
    $display("same-file=%0d", same_file);
`endif
    $finish(0);
  end
`endif
endmodule
