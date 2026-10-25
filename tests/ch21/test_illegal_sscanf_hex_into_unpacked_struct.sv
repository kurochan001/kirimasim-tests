/*
:name: test_illegal_sscanf_hex_into_unpacked_struct
:description: an integer scan specifier cannot read into an unpacked structure (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.3.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the %h conversion of the last $sscanf reads into us, a variable of an unpacked structure type
:expected_stderr_regex: test_illegal_sscanf_hex_into_unpacked_struct\.sv:32:
*/
// IEEE 1800-2023 §21.3.4.3: the integer conversions (h, d, o, b, c, u and z)
// may read into integral types, including packed structures, but not into
// an unpacked aggregate type such as an unpacked structure. The first
// $sscanf reads with %h into a packed structure of the same members, which
// is legal. The last one reads with %h into the unpacked structure us, which
// is the error.
// Icarus Verilog 13.0 does not support unpacked structures, so its error
// does not count, and release 5.052 of the Verilator tool accepts the design.

module test_illegal_sscanf_hex_into_unpacked_struct;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } packed_t;
  typedef struct { bit [3:0] a; bit [3:0] b; } unpacked_t;
  packed_t ps;
  unpacked_t us;
  int n;

  initial begin
    n = $sscanf("5a", "%h", ps);
    n = $sscanf("5a", "%h", us);   // illegal: %h into an unpacked structure
  end
endmodule
