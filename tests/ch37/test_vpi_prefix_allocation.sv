/*
:name: test_vpi_prefix_allocation
:description: An object whose prefix is a class variable or a virtual interface variable has the same vpiAllocScheme as that prefix (IEEE 1800-2023 Section 37.61)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.61 37.3.7 25.9 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_prefix_allocation.c
:expected_stdout: @test_vpi_prefix_allocation.expected
*/
// IEEE 1800-2023 §37.61 detail 2: the memory allocation scheme of an object
// for which a class variable or virtual interface variable prefix is non-NULL
// shall be the same as for the prefix. §37.3.7 gives the three schemes. The
// test passes the non-static class property c.m and the interface variable
// vi.d to a system task; the application reads vpiPrefix of each argument,
// compares the allocation scheme of the argument with that of its prefix with
// vpi_get(vpiAllocScheme), and prints the prefix kind and name and whether the
// two schemes are equal. The prefixes c and vi are static variables of the
// module, not allocated in dynamic memory, so their scheme is vpiOtherScheme
// (§37.3.7), and by detail 2 so is the scheme of c.m and vi.d. §37.3.7 alone
// would call c.m, a part of a class object, dynamic; the test follows the
// more specific rule of §37.61 for an object with a prefix. vpi_get_str()
// returns each string in the same buffer (§38.11), so the application copies
// the strings it prints together.

interface pfx_ifc;
  logic [3:0] d;
endinterface

module test_vpi_prefix_allocation;
  class C;
    int m;
  endclass

  C c;
  pfx_ifc b ();
  virtual pfx_ifc vi;

  initial begin
    c = new;
    c.m = 5;
    vi = b;
    #1 $vt_prefix(c.m, vi.d);
  end
endmodule
