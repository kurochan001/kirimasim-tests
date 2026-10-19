/*
:name: test_vpi_get_value_array
:description: vpi_get_value_array reads consecutive elements of a static unpacked array, from a starting index, as integers or as vectors, into memory given by the application or by VPI (IEEE 1800-2023 Section 38.16)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.16 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_array.c
:expected_stdout: @test_vpi_get_value_array.expected
*/
// IEEE 1800-2023 §38.16: vpi_get_value_array reads num elements of a static
// unpacked array starting at the element whose indices are in index_p, in the
// format given in the s_vpi_arrayvalue structure. With vpiUserAllocFlag set
// the values go to the application's buffer; otherwise VPI returns its own
// storage. vpiIntVal gives one integer per element; vpiVectorVal gives
// aval/bval words per element as for vpi_get_value (38.15). The application
// reads mem[1] to mem[3] as integers into its own buffer, ia[3] and ia[4] as
// integers in VPI's storage, and mem[0] and mem[1] as vectors.

module test_vpi_get_value_array;
  logic [7:0] mem [0:3];
  int ia [2:5];

  initial begin
    foreach (mem[k]) mem[k] = 8'h10 + k;
    foreach (ia[k]) ia[k] = k * 100;
    $vt_read;
  end
endmodule
