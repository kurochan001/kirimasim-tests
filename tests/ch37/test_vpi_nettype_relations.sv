/*
:name: test_vpi_nettype_relations
:description: A nettype declaration gives its name, its instance with vpiInstance, its typespec with vpiTypespec, and its resolution function with vpiWith or NULL when it has none (IEEE 1800-2023 Sections 37.23 and 37.10)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.23 37.10 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_nettype_relations.c
:expected_stdout: @test_vpi_nettype_relations.expected
*/
// IEEE 1800-2023 §37.23: a nettype declaration has vpiName and reaches its
// typespec with vpiTypespec; when it declares a resolution function, vpiWith
// gives that function, and when it has none, vpiWith is NULL (detail 1). A
// net declared with the nettype takes the same typespec. §37.10: a nettype
// declaration reaches the instance that declares it with vpiInstance, which
// is the top module here. The test declares one nettype without a resolution
// function and one with a function, and a net of each, and compares the
// vpiInstance handle with the top module handle (37.3.1).

module test_vpi_nettype_relations;
  typedef logic [3:0] nib_t;

  function logic [3:0] nt_resolve(input logic [3:0] drivers[]);
    return drivers[0];
  endfunction

  nettype nib_t nt_plain;
  nettype nib_t nt_res with nt_resolve;

  nt_plain p;
  nt_res r;

  initial #1 $vt_nettype;
endmodule
