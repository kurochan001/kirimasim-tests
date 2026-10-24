/*
:name: test_vpi_handle_by_name_scope_index
:description: vpi_handle_by_name finds simple and hierarchical names from the top level when the scope is NULL and only within the scope given otherwise, and vpi_handle_by_index returns NULL for a scalar or a real, whose bit-selects are illegal, but a handle to a bit of a vector (IEEE 1800-2023 Sections 38.21 and 38.19)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.21 38.19 11.5.1 38.36.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_by_name_scope_index.c
:expected_stdout: @test_vpi_handle_by_name_scope_index.expected
*/
// IEEE 1800-2023 §38.21: vpi_handle_by_name takes a simple or hierarchical
// name of an object that has a full name. With a NULL scope the name is
// looked up from the top level of the hierarchy; with a scope it is looked up
// within that scope only. §38.19: vpi_handle_by_index returns NULL when the
// index does not give a legal index select; a bit-select of a scalar or of a
// real variable is illegal (11.5.1). The top module and its instance u1 both
// have a variable named shared; t_only is in the top module only and s_only
// in u1 only; blk is a named block of u1. At the start of the simulation
// (38.36.3) the application prints, for each lookup, the full name of the
// object found or NULL.
// Icarus Verilog 13.0 returns a handle s[0] for index 0 of the scalar s.

module name_scope_sub;
  int shared, s_only;
  initial begin : blk
    int in_blk;
    in_blk = 1;
    shared = 3;
    s_only = 4;
  end
endmodule

module test_vpi_handle_by_name_scope_index;
  int shared, t_only;
  logic s;
  real r;
  logic [3:0] vec;

  name_scope_sub u1();

  initial begin
    s = 1'b1;
    r = 1.5;
    vec = 4'b1010;
    shared = 1;
    t_only = 2;
  end
endmodule
