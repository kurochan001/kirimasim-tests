/*
:name: test_illegal_display_unpacked_int_array_no_format
:description: an unpacked array of int without a format specification is an illegal argument of $display (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked int array arr is given to $display without a format specification
:expected_stderr_regex: test_illegal_display_unpacked_int_array_no_format\.sv:32:
*/
// IEEE 1800-2023 §21.2.1.1: an argument of a display task that has no format
// specification is shown in the default radix of the task. An argument of
// the string type or an unpacked array of byte is shown as a string; an
// argument of any other unpacked type without a format specification is
// illegal. The first two $display statements give an integral value, a
// string and an unpacked byte array without format specifications, which is
// legal. The last one gives the unpacked int array arr, which is the error.
// Icarus Verilog 13.0 accepts the design and reports an error only when the
// task runs, and release 5.052 of the Verilator tool accepts it and prints
// arr as an assignment pattern, so neither rejects the design.

module test_illegal_display_unpacked_int_array_no_format;
  string s = "ab";
  byte bytes [2] = '{8'h63, 8'h64};
  int arr [2] = '{1, 2};

  initial begin
    $display(5, s, bytes);
    $display(arr);   // illegal: an unpacked int array without a format
  end
endmodule
