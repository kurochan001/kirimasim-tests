/*
:name: test_vpi_nettype_declarations
:description: A nettype declaration gives its resolution function through vpiWith, NULL when it has none, and the nettype it renames through vpiNetTypedefAlias (IEEE 1800-2023 Section 37.23)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.23 37.10 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_nettype_declarations.c
:expected_stdout: @test_vpi_nettype_declarations.expected
*/
// IEEE 1800-2023 §37.23: vpiWith of a nettype declaration returns its
// resolution function, or NULL if it has none, and vpiNetTypedefAlias returns
// the nettype that an alias declaration renames. The instance iterates the
// nettypes declared in it (37.10). plain_t has no resolution function, summed_t
// is resolved by total, and alias_t is another name for plain_t (6.6.7). The
// lines are sorted by name.

`timescale 1ns/1ns

module test_vpi_nettype_declarations;
  function automatic real total(input real d[]);
    real t = 0.0;
    foreach (d[i]) t += d[i];
    return t;
  endfunction

  nettype real plain_t;
  nettype real summed_t with total;
  nettype plain_t alias_t;

  initial #1 $vt_nettypes;
endmodule
