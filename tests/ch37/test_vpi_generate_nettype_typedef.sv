/*
:name: test_vpi_generate_nettype_typedef
:description: A nettype declaration inside a generate scope reaches that scope with vpiGenScope and gives its typespec, and vpiTypedef iterates the typedefs declared in a generate scope and in the instance (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 37.23 37.25 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_generate_nettype_typedef.c
:expected_stdout: @test_vpi_generate_nettype_typedef.expected
*/
// IEEE 1800-2023 §37.85 detail 5: the vpiTypedef iteration returns the
// user-defined typespecs whose typedefs are declared explicitly in the
// instance, and for a generate scope the same iteration returns the typedefs
// declared in that scope. The nettype declaration gnt in the generate scope g
// reaches g with vpiGenScope and its typespec with vpiTypespec (§37.23). The
// application prints the scope comparison, the typespec name and the typedef
// names of the generate scope and of the top instance, sorted. vpi_get_str()
// returns each string in the same buffer (§38.11), so the application copies
// the strings it prints together. A nettype declaration has no full name
// (§37.23), which vpi_handle_by_name() needs (§38.21), so gnt is found with
// the vpiNetTypedef iteration of g (§37.85 detail 6); Annex M defines no
// constant for that tag, so without one the object type vpiNettypeDecl is
// used.

module test_vpi_generate_nettype_typedef;
  typedef logic [7:0] top_byte_t;

  if (1) begin : g
    typedef logic [15:0] gen_word_t;
    nettype gen_word_t gnt;
  end

  initial #1 $vt_gen;
endmodule
