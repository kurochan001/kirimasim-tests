/*
:name: test_illegal_display_decimal_format_unpacked_struct
:description: an integer format specifier cannot be used with an unpacked structure argument (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the %d specification of the last $display corresponds to us, a variable of an unpacked structure type
:expected_stderr_regex: test_illegal_display_decimal_format_unpacked_struct\.sv:32:
*/
// IEEE 1800-2023 §21.2.1.1: the integer format specifiers (h, x, d, o, b, c,
// u and z) may be used with integral types, including packed structures,
// but not with an unpacked aggregate type such as an unpacked structure. The
// first $display uses %d with a packed structure of the same members, which
// is legal. The last one uses %d with the unpacked structure us, which is
// the error.
// Icarus Verilog 13.0 does not support unpacked structures, so its error
// does not count, and release 5.052 of the Verilator tool accepts the design
// and prints us as an assignment pattern.

module test_illegal_display_decimal_format_unpacked_struct;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } packed_t;
  typedef struct { bit [3:0] a; bit [3:0] b; } unpacked_t;
  packed_t ps = '{4'd1, 4'd2};
  unpacked_t us = '{4'd1, 4'd2};

  initial begin
    $display("%d", ps);
    $display("%d", us);   // illegal: %d with an unpacked structure
  end
endmodule
