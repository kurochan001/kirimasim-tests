/*
:name: test_illegal_dynamic_array_to_dpi_open_output
:description: a dynamic array cannot be the actual argument of a DPI import formal argument that has an unsized dimension and the direction output (IEEE 1800-2023 Section 7.7)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the dynamic array d is passed to the output formal a of fill, an open array with an unsized dimension
:expected_stderr_regex: test_illegal_dynamic_array_to_dpi_open_output\.sv:37:
*/
// IEEE 1800-2023 §7.7: the unpacked dimensions of DPI open array formal
// arguments follow the rules of dynamic array formals, so an open array takes
// fixed-size and dynamic arrays and queues, but a dynamic array or queue shall
// not be passed as the actual argument of a DPI formal argument with unsized
// dimensions and the direction output.
// The imported function show has the input open array formal a and fill the
// output open array formal a. The calls show(d) with the dynamic array d and
// fill(f) with the fixed-size array f are legal; the call fill(d) passes the
// dynamic array d to the output open array. The design is illegal and never
// runs, so the imports have no C implementation.
// Icarus Verilog 13.0 does not support DPI and reports syntax errors on the
// imports, which do not count. The 5.052 release stops with an internal error
// on the legal call show(d), as it does not support a dynamic array as the
// actual argument of any DPI open array, which does not count.

module test_illegal_dynamic_array_to_dpi_open_output;
  import "DPI-C" function void show(input int a []);
  import "DPI-C" function void fill(output int a []);
  int d [] = '{1, 2, 3};
  int f [4];
  initial begin
    show(d);
    fill(f);
    fill(d);   // illegal: dynamic array for an output open array formal
  end
endmodule
