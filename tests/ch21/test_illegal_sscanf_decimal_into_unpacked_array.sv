/*
:name: test_illegal_sscanf_decimal_into_unpacked_array
:description: an integer scan specifier cannot read into an unpacked array (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the %d conversion of the last $sscanf reads into arr, an unpacked array of int
:expected_stderr_regex: test_illegal_sscanf_decimal_into_unpacked_array\.sv:36:
*/
// IEEE 1800-2023 §21.3.4.3: the integer conversions (h, d, o, b, c, u and z)
// may read into any integral type, including enumerations, packed
// structures and types defined by typedef as one of them, but not into an
// unpacked aggregate type. The first $sscanf reads with %d into an
// enumeration, with %h into a packed structure and with %b into a typedef
// of int, which is legal. The last one reads with %d into the unpacked array
// arr, which is the error.
// Icarus Verilog 13.0 accepts the design and reports an error only when the
// task runs, and release 5.052 of the Verilator tool accepts it.

module test_illegal_sscanf_decimal_into_unpacked_array;
  typedef enum {RED, GREEN} color_t;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } pair_t;
  typedef int my_int_t;
  color_t c;
  pair_t p;
  my_int_t m;
  int arr [2];
  int n;

  initial begin
    n = $sscanf("1 5a 101", "%d %h %b", c, p, m);
    n = $sscanf("3", "%d", arr);   // illegal: %d into an unpacked array
  end
endmodule
