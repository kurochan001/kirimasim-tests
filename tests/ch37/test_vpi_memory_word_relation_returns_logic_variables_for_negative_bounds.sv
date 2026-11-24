/*
:name: test_vpi_memory_word_relation_returns_logic_variables_for_negative_bounds
:description: Deprecated memory-word traversal preserves the declared indices and returns current logic handles
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.20 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_memory_word_relation_returns_logic_variables_for_negative_bounds.expected
:vpi_c: @test_vpi_memory_word_relation_returns_logic_variables_for_negative_bounds.c
*/
module test_vpi_memory_word_relation_returns_logic_variables_for_negative_bounds;
  logic [7:0] locations[-2:0];

  initial begin
    locations[-2] = 8'h16;
    locations[-1] = 8'h4d;
    locations[0] = 8'hb2;
    $vt_check_words;
    $display("after write=%h/%h/%h", locations[-2], locations[-1], locations[0]);
  end
endmodule
