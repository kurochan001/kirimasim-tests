/*
:name: test_illegal_display_unpacked_struct_no_format
:description: an unpacked structure without a format specification is an illegal argument of $display (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked structure st is given to $display without a format specification
:expected_stderr_regex: test_illegal_display_unpacked_struct_no_format\.sv:35:
*/
// IEEE 1800-2023 §21.2.1.1: an argument of a display task that has no format
// specification is shown in the default radix of the task. An argument of the
// string type or an unpacked array of byte is shown as a character string, and
// any other unpacked type without a format specification is illegal. The
// $display gives the unpacked structure st without a format, which is the
// error. Icarus Verilog 13.0 rejects the declaration of the unpacked structure
// before it reaches the task, and release 5.052 of the Verilator tool accepts
// the design and prints st as an assignment pattern, so neither rejection is
// evidence for this rule.

module test_illegal_display_unpacked_struct_no_format;
  typedef struct {
    int a;
    int b;
  } pair_t;

  pair_t st;

  initial begin
    st.a = 1;
    st.b = 2;
    $display(st);   // illegal: an unpacked structure without a format
  end
endmodule
