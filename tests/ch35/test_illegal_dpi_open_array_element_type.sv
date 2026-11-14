/*
:name: test_illegal_dpi_open_array_element_type
:description: An open array formal of an imported function matches an actual of any size in its open dimension but not one whose element type differs, so passing a shortint array to an int open array is an error (IEEE 1800-2023 Section 35.5.6.1)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an unpacked array of shortint is passed to an imported open array formal of int elements
:expected_stderr_regex: test_illegal_dpi_open_array_element_type\.sv:38:
*/
// IEEE 1800-2023 §35.5.6.1: an unsized dimension [] of a formal of an
// imported function only relaxes the matching of that dimension, which then
// accepts an actual dimension of any range. The other requirements stay:
// unpacked dimensions are matched as for any array argument (7.7), so the
// element types have to be equivalent (7.6).
//
// c_count has the open array formal int a[]. The actuals four, an int array
// of four elements, and two, an int array with the range [1:2], differ from
// each other only in their ranges and are legal. three is an array of
// shortint, whose element type is not equivalent to int, so its call is an
// error. Without that call the design is legal.
//
// Icarus Verilog 13.0 has no DPI and rejects the import declaration. The
// 5.054 release of Verilator accepts the design.

module test_illegal_dpi_open_array_element_type;
  import "DPI-C" function int c_count(input int a[]);

  initial begin
    int four [4];
    int two [1:2];
    shortint three [3];
    $display("%0d", c_count(four));
    $display("%0d", c_count(two));
    $display("%0d", c_count(three));   // illegal: shortint elements
  end
endmodule
