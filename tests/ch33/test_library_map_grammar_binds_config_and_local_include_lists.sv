/*
:name: test_library_map_grammar_binds_config_and_local_include_lists
:description: Map configurations, includes, comments, empty statements and per-library path lists coexist
:tags: ch33
:type: simulation
:lrm: 1800-2023 33.3.1 33.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: grammar_config
:expected_exit: 0
:expected_stdout: @test_library_map_grammar_binds_config_and_local_include_lists.expected
:files: libmap_grammar/maps/main.map libmap_grammar/maps/vendor/beta.map libmap_grammar/maps/alpha/first.sv libmap_grammar/maps/alpha/second.sv libmap_grammar/maps/vendor/source/third.sv
*/
`timescale 1ns/1ns
module grammar_top;
  wire [7:0] first_value, second_value, third_value;
  alpha_first first_binding(first_value);
  alpha_second second_binding(second_value);
  beta_third third_binding(third_value);

  initial #1 $display("alpha=%0d,%0d beta=%0d", first_value, second_value, third_value);
endmodule
