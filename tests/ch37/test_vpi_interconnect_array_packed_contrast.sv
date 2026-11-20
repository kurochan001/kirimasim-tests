/*
:name: test_vpi_interconnect_array_packed_contrast
:description: Packed and unpacked interconnect arrays expose different vpiPacked values while retaining their declared bounds and owning module
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.24 37.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interconnect_array_packed_contrast.c
:expected_stdout: @test_vpi_interconnect_array_packed_contrast.expected
*/
// IEEE 1800-2023 37.24 B002 defines the Boolean packed property of an
// interconnect array. Both arrays below have three elements, so vpiSize alone
// cannot distinguish them. Their declared dimensions give packed TRUE and
// FALSE respectively. The diagram supplies the two bound expressions;
// 37.16 details 12 and 24 identify the interconnect kind and element count.
// The connections obey 6.6.8 and 6.7.1: interconnect occurs only as a net
// connection and has neither a data type nor an assignment expression.

module test_vpi_interconnect_array_packed_contrast_leaf(output wire o);
  assign o = 1'b0;
endmodule

module test_vpi_interconnect_array_packed_contrast;
  interconnect [3:1] packed_link;
  interconnect unpacked_link [-2:0];
  test_vpi_interconnect_array_packed_contrast_leaf p3(packed_link[3]);
  test_vpi_interconnect_array_packed_contrast_leaf p2(packed_link[2]);
  test_vpi_interconnect_array_packed_contrast_leaf p1(packed_link[1]);
  test_vpi_interconnect_array_packed_contrast_leaf u2(unpacked_link[-2]);
  test_vpi_interconnect_array_packed_contrast_leaf u1(unpacked_link[-1]);
  test_vpi_interconnect_array_packed_contrast_leaf u0(unpacked_link[0]);
  initial #1 $vt_packed_contrast;
endmodule
