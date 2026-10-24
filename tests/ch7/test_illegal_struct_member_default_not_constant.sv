/*
:name: test_illegal_struct_member_default_not_constant
:description: the default value of a structure member has to be a constant expression; a variable is an error (IEEE 1800-2023 Section 7.2.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default value of the member a of the structure of bad is the variable x, which is not a constant expression
:expected_stderr_regex: test_illegal_struct_member_default_not_constant\.sv:33:
*/
// IEEE 1800-2023 §7.2.2: the members of an unpacked structure type can be given
// default values with an initial assignment in their declaration, and the
// assigned expression shall be a constant expression.
// The structure type ok_t gives its member a the default W * 2, a constant
// expression of the local parameter W = 3, and b the default 1; the legal
// design prints the members of a variable of ok_t without an initializer: 6 1.
// The structure of the variable bad gives its member a the default x, an int
// variable.
// Icarus Verilog 13.0 reports unpacked structures as not supported (a message
// that is not an error).
// The 5.052 release stops with an internal fault on the design, which does not
// count.

module test_illegal_struct_member_default_not_constant;
  localparam int W = 3;
  int x = 4;
  typedef struct { int a = W * 2; int b = 1; } ok_t;
  ok_t o;
  initial $display("%0d %0d", o.a, o.b);
  struct { int a = x; int b; } bad;   // illegal: a variable as a member default
endmodule
