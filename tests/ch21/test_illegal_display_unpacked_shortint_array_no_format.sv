/*
:name: test_illegal_display_unpacked_shortint_array_no_format
:description: an unpacked array of shortint without a format specification is an illegal argument of $display (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked shortint array arr is given to $display without a format specification
:expected_stderr_regex: test_illegal_display_unpacked_shortint_array_no_format\.sv:29:
*/
// IEEE 1800-2023 §21.2.1.1: an argument of a display task that has no format
// specification is shown in the default radix of the task. Only an argument of
// the string type or an unpacked array of byte is shown as a character string;
// any other unpacked type without a format specification is illegal. The
// $display gives the unpacked shortint array arr without a format, which is
// the error. Icarus Verilog 13.0 takes the argument and reports an error only
// when the task runs, and release 5.052 of the Verilator tool accepts the
// design, so neither rejects it at elaboration.

module test_illegal_display_unpacked_shortint_array_no_format;
  shortint arr[2];

  initial begin
    arr[0] = 1;
    arr[1] = 2;
    $display(arr);   // illegal: an unpacked shortint array without a format
  end
endmodule
