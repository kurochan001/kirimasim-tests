/*
:name: test_illegal_rand_member_in_packed_struct
:description: a member of a packed structure cannot have the rand qualifier, which only members of unpacked structures can have (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member a of the packed structure of the variable bad has the rand qualifier
:expected_stderr_regex: test_illegal_rand_member_in_packed_struct\.sv:33:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1, footnote 20): a random_qualifier (rand or
// randc) is legal on a structure or union member only within unpacked
// structures.
// The unpacked structure type ok_t has the member a declared rand, which is
// legal; the legal design assigns the members of the variable ok and prints
// them: 5 9. The packed structure of the variable bad has the same member
// declared rand.
// Icarus Verilog 13.0 does not support the rand qualifier on structure members
// and reports syntax errors on both structures, which do not count. The 5.052
// release accepts the declaration of bad.

module test_illegal_rand_member_in_packed_struct;
  typedef struct { rand bit [3:0] a; int b; } ok_t;
  ok_t ok;
  initial begin
    ok.a = 4'd5;
    ok.b = 9;
    $display("%0d %0d", ok.a, ok.b);
  end
  struct packed { rand bit [3:0] a; bit [3:0] b; } bad;   // illegal: rand in a packed struct
endmodule
