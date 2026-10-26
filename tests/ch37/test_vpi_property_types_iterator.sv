/*
:name: test_vpi_property_types_iterator
:description: vpi_get returns PLI_INT32 with 1 and 0 for a Boolean property, vpi_get64 returns PLI_INT64 for a 64-bit property, vpi_get_str returns a PLI_BYTE8 pointer, and vpi_iterate creates a vpiIterator that vpi_scan uses to traverse the one-to-many relation exactly (IEEE 1800-2023 Section 37.3.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.1 37.3.2 38.14 38.22 38.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_property_types_iterator.c
:expected_stdout: @test_vpi_property_types_iterator.expected
*/
// IEEE 1800-2023 §37.3.1: vpi_get returns integer and Boolean properties as
// PLI_INT32, with 1 for TRUE and 0 for FALSE; vpi_get64 returns 64-bit
// integer properties as PLI_INT64; vpi_get_str returns a string property as
// PLI_BYTE8 * (B013). vpi_iterate creates an object of type vpiIterator, which
// vpi_scan traverses (B016). The module has two nets, so the iteration gives
// exactly their handles and then NULL; the class variable's vpiObjId is the
// 64-bit identifier of the object it references, which is not zero while the
// object lives (37.33 details 1 and 2). The sizes of the return types are
// printed as a Boolean equality with the type of the standard, and the net
// names are sorted because the order is not fixed.

module test_vpi_property_types_iterator;
  wire [7:0] w1, w2;

  class api_obj;
  endclass

  api_obj co;

  initial begin
    co = new;
    #1 $vt_api;
  end
endmodule
