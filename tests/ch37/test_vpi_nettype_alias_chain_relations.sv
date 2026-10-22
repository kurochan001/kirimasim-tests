/*
:name: test_vpi_nettype_alias_chain_relations
:description: VPI alias relations preserve both links of a nettype alias chain and the original resolver (IEEE 1800-2023 Section 37.23)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.23 6.22.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_nettype_alias_chain_relations.c
:expected_stdout: @test_vpi_nettype_alias_chain_relations.expected
*/
// IEEE 1800-2023 37.23 6.22.6: Handles are compared as objects instead of
// retaining borrowed string pointers; a chain must point to its immediate
// aliased declaration and the original nettype to its function.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_vpi_nettype_alias_chain_relations;
  function automatic real total(input real values[]);
    real result = 0.0;
    foreach (values[i]) result += values[i];
    return result;
  endfunction
  nettype real root_type with total;
  nettype root_type first_alias;
  nettype first_alias second_alias;
  initial #1 $depth_aliases;
endmodule
