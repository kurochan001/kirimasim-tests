/*
:name: test_vpi_iterator_objects
:description: an iterator is an object of type vpiIterator whose vpiIteratorType is the type it iterates over and whose vpiUse is the reference handle it was created from, or NULL; vpi_iterate returns NULL when there is nothing to iterate over, and vpi_release_handle frees an iterator before its end (IEEE 1800-2023 Sections 37.84, 37.2.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.84 37.2.2 38.21 38.32 38.37
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_iterator_objects.c
:expected_stdout: @test_vpi_iterator_objects.expected
*/
// IEEE 1800-2023 §37.84: vpi_get(vpiType) of an iterator is vpiIterator, and
// vpiIteratorType gives the type of the objects it iterates over;
// vpi_handle(vpiUse, iterator) returns the reference handle used to create it
// (detail 1), or NULL when that was NULL (detail 2). §38.21: vpi_iterate
// returns NULL when there are no objects of the type. §38.37 (vpi_scan) and
// §37.2.2: an iterator is freed when vpi_scan returns NULL, and
// vpi_release_handle (§38.32) frees one that is not used to its end.

module test_vpi_iterator_objects;
  wire a, b, c;
  logic r;

  initial #1 $vt_iterators;
endmodule
