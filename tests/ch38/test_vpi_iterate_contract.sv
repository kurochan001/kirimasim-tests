/*
:name: test_vpi_iterate_contract
:description: vpi_iterate returns an iterator handle of type vpiIterator for a one-to-many relationship, NULL when there is no such object, and vpi_scan returns each object once and then NULL (IEEE 1800-2023 Section 38.23)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.23
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_iterate_contract.c
:expected_stdout: @test_vpi_iterate_contract.expected
*/
// IEEE 1800-2023 §38.23: vpi_iterate() returns a handle to an iterator whose
// type is vpiIterator for a relationship drawn with a double arrow, and NULL
// when the reference object has no object of the requested type. vpi_scan()
// then returns each of those objects and finally NULL. The application asks
// the module for its nets and checks the type of the returned handle, then
// scans every net and prints the count and the sorted names, so the order in
// which the objects come, which the clause does not fix, does not affect the
// output. It then asks for UDP definitions and module paths, which the module
// has none of, and both calls return NULL. The names are copied because
// vpi_get_str() reuses one buffer for every string it returns (38.11).

module test_vpi_iterate_contract;
  logic a = 1'b1;
  logic b = 1'b0;
  wire y, z;

  and g1 (y, a, b);
  or g2 (z, a, b);

  initial begin
    #1 $vt_iter;
    $finish;
  end
endmodule
