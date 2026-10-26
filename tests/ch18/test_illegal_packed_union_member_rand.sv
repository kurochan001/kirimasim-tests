/*
:name: test_illegal_packed_union_member_rand
:description: A packed untagged union may be rand or randc as a whole, but its members shall not have a rand or randc modifier (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member a of the packed union pu_t has a rand modifier
:expected_stderr_regex: test_illegal_packed_union_member_rand\.sv:22:
*/
// IEEE 1800-2023 §18.4: a packed untagged union declared rand is treated as
// an integral type, so its members cannot be randomized separately and shall
// not carry rand or randc. The rand on member a of pu_t is illegal. Icarus
// Verilog 13.0 rejects the member with an error in the struct/union member.
// The 5.052 release of Verilator accepts the design.

class c_packed_union_member;
  typedef union packed {
    rand bit [7:0] a;   // illegal: member of a packed union
    bit [7:0] b;
  } pu_t;
  rand pu_t u;
endclass

module test_illegal_packed_union_member_rand;
  c_packed_union_member o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
