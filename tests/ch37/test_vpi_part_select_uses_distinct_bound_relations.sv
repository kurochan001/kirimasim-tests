/*
:name: test_vpi_part_select_uses_distinct_bound_relations
:description: VPI part-selects expose distinct left and right bounds and reject the ambiguous expression tag
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.1 37.59 38.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_part_select_uses_distinct_bound_relations.expected
:vpi_c: @test_vpi_part_select_uses_distinct_bound_relations.c
*/
module test_vpi_part_select_uses_distinct_bound_relations;
  function automatic void apply();
    bit [11:4] nibble = '0;
    $vt_bounds(nibble[10:7]);
  endfunction

  initial apply();
endmodule
