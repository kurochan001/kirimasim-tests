/*
:name: test_illegal_display_hex_format_unpacked_array
:description: an integer format specifier cannot be used with an unpacked array argument (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the %h specification of the last $display corresponds to arr, an unpacked array of int
:expected_stderr_regex: test_illegal_display_hex_format_unpacked_array\.sv:36:
*/
// IEEE 1800-2023 §21.2.1.1: the integer format specifiers (h, x, d, o, b, c,
// u and z) may be used with any integral type, including enumerations,
// packed structures and types defined by typedef as one of them, but not
// with an unpacked aggregate type. The first $display uses %d with an
// enumeration, %h with a packed structure and %b with a typedef of int,
// which is legal. The last one uses %h with the unpacked array arr, which is
// the error.
// Icarus Verilog 13.0 accepts the design and reports an error only when the
// task runs, and release 5.052 of the Verilator tool accepts it and prints
// arr as an assignment pattern, so neither rejects the design.

module test_illegal_display_hex_format_unpacked_array;
  typedef enum {RED, GREEN} color_t;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } pair_t;
  typedef int my_int_t;
  color_t c = GREEN;
  pair_t p = '{4'h5, 4'ha};
  my_int_t m = 6;
  int arr [2] = '{1, 2};

  initial begin
    $display("%d %h %b", c, p, m);
    $display("%h", arr);   // illegal: %h with an unpacked array
  end
endmodule
