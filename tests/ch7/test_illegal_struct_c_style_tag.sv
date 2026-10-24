/*
:name: test_illegal_struct_c_style_tag
:description: a structure declaration has no C-style structure tag before its opening brace (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure declaration of bad_t has the tag name point between struct packed and the opening brace
:expected_stderr_regex: test_illegal_struct_c_style_tag\.sv:26:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1): structure declarations follow the C
// syntax but without the optional structure tag before the opening brace;
// the struct keyword, with packed and signing when needed, is followed by
// the brace. The structure type pair_t and the anonymous structure variable
// are declared without a tag, and the legal design prints their members;
// the declaration of bad_t puts the tag point before the brace.

module test_illegal_struct_c_style_tag;
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } pair_t;
  pair_t p = 8'h5a;
  struct packed signed { bit [1:0] a; bit [1:0] b; } anon = 4'b1101;
  initial $display("%h %h %0d", p.hi, p.lo, anon);
  typedef struct packed point { bit [3:0] x; } bad_t;   // illegal: structure tag
endmodule
