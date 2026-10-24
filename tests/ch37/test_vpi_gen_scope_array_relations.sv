/*
:name: test_vpi_gen_scope_array_relations
:description: Module, interface and program instances iterate their gen scope arrays; a gen scope array gives its name, full name, module and instance, and its elements by genvar value with vpi_handle_by_index and vpi_handle_by_multi_index; a genvar gives its full name and the gen scope arrays of all loops that use it; a gen scope gives its gen scope array and vpiArray, and a named conditional one its name (IEEE 1800-2023 Section 37.85)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.85 27.4 27.5 37.10 38.19 38.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_gen_scope_array_relations.c
:expected_stdout: @test_vpi_gen_scope_array_relations.expected
*/
// IEEE 1800-2023 §37.85: a module, interface or program instance iterates its
// gen scope arrays (vpiGenScopeArray), and a gen scope array leads to its
// module (vpiModule) and to the instance it is in (vpiInstance; 37.10 detail
// 3: the immediate instance). It has vpiName and vpiFullName and gives its
// elements by index (vpi_handle_by_index, vpi_handle_by_multi_index). A gen
// var has vpiName and vpiFullName and iterates the gen scope arrays of the
// loops it controls. A gen scope leads to its gen scope array, and vpiArray
// (deprecated) tells whether it is an element of one; it has vpiName. §27.4:
// a named loop generate block is an array of block instances whose indices
// are the values of the genvar, so gsp has the elements 0, 2 and 4 only, and
// one genvar can control several loops that are not nested; §27.5: a named
// conditional generate block is a single gen scope. §38.19, §38.20: an index
// that does not form a legal select gives NULL.
//
// The module declares the genvar i and uses it in the loops ga, gb and gsp;
// gc holds a loop gd in each of its gen scopes; the interface and program
// instances u_ifc and u_prog each hold a loop. From a start-of-simulation
// callback the application prints the gen scope arrays of each instance
// (sorted), the properties and relations of some arrays, the gen var of ga,
// the array of some gen scopes, and the elements found by index; NULL is
// printed for a NULL handle.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiGenScopeArray and other constants used
// here, and a run with Verilator 5.052 finds none of these gen scopes and gen
// scope arrays, by iteration or by name.

interface gsa_ifc;
  for (genvar m = 0; m < 2; m++) begin : ig
  end
endinterface

program gsa_prog;
  for (genvar p = 0; p < 2; p++) begin : pg
  end
endprogram

module test_vpi_gen_scope_array_relations;
  genvar i;

  for (i = 0; i < 3; i++) begin : ga
  end

  for (i = 0; i < 2; i++) begin : gb
  end

  for (i = 0; i < 6; i += 2) begin : gsp
  end

  for (genvar j = 0; j < 2; j++) begin : gc
    for (genvar k = 0; k < 2; k++) begin : gd
    end
  end

  if (1) begin : gif
  end

  case (1)
    1: begin : gcase
    end
  endcase

  gsa_ifc u_ifc ();
  gsa_prog u_prog ();
endmodule
