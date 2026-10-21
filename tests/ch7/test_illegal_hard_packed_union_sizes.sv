/*
:name: test_illegal_hard_packed_union_sizes
:description: The members of a packed union without soft have to be of the same size (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a packed union without soft has members of different sizes
:expected_stderr_regex: test_illegal_hard_packed_union_sizes\.sv:(19|20|21):
*/
// IEEE 1800-2023 §7.3.1: a packed union without the soft qualifier is hard
// packed, and its members shall all be of the same size. A tool can report the
// union or one of its members.

module test_illegal_hard_packed_union_sizes;
  typedef union packed {   // error here
    logic [7:0] a;   // error here
    logic [3:0] b;   // illegal: 4 bits in a hard packed union of 8
  } u_t;
  u_t u;
  initial begin
    u.a = 8'h12;
    $display("a=%h", u.a);
  end
endmodule
