/*
:name: test_vpi_static_part_select_rejects_ambiguous_expression
:description: A static net part-select exposes both bound tags and rejects the ambiguous expression tag
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.1 37.59 38.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_static_part_select_rejects_ambiguous_expression.expected
:expected_exit: 0
:vpi_c: @test_vpi_static_part_select_rejects_ambiguous_expression.c
:expected_stderr_regex: (?m)^VPI rejected the ambiguous part-select relation for ascending and descending$
*/
module test_vpi_static_part_select_rejects_ambiguous_expression;
  wire [3:12] ascending_net = 10'b1011100110;
  wire [12:3] descending_net = 10'b0100101101;

  initial #1 $probe_static_parts(ascending_net[5:8], descending_net[10:7]);
endmodule
