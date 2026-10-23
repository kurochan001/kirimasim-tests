/*
:name: test_vpi_net_array_elements_indices
:description: An array net iterates its nets, which are array members with the array net as parent and give their indices from the rightmost outward; their bits give their bit index first and then the array indices, with the element net as parent; a net outside any array is not an array member and has no index iteration and no parent (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 38.19 38.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_array_elements_indices.c
:expected_stdout: @test_vpi_net_array_elements_indices.expected
*/
// IEEE 1800-2023 §37.16: vpi_iterate(vpiNet) of an array net gives its nets,
// each of which has vpiArrayMember TRUE (detail 2). vpiParent of an element of
// an array net is the largest unpacked array net that contains it, and that of
// a net bit is the largest packed prefix that contains it, here the element
// net (detail 31); a net that is not a select of anything has no parent. For
// an element, vpi_iterate(vpiIndex) gives its indices from its own, the
// rightmost, outward, and NULL for a net that is not an array member
// (detail 25). For a net bit, vpi_handle(vpiIndex) gives its bit index and
// vpi_iterate(vpiIndex) the bit index followed by the array indices outward
// (detail 10). Names and full names of indexed elements include the indices
// (detail 34). The element ma[2][1] is taken with vpi_handle_by_multi_index
// (38.20) and its bit 3 with vpi_handle_by_index (38.19).

module test_vpi_net_array_elements_indices;
  wire [3:0] ma [1:2][0:1];
  wire [3:0] lone;

  initial #1 $vt_elements;
endmodule
