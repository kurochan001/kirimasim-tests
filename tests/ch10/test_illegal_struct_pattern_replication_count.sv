/*
:name: test_illegal_struct_pattern_replication_count
:description: a replication in a structure assignment pattern has to give exactly as many values as the structure has members (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the replication '{2{7}} gives two values for a structure of three members
:expected_stderr_regex: test_illegal_struct_pattern_replication_count\.sv:30:
*/
// IEEE 1800-2023 §10.9.2: replication can be used in a structure assignment
// pattern to set the values of the exact number of members. '{3{7}} for the
// three members is legal; '{2{7}} is not.
// Icarus Verilog 13.0 does not support unpacked structures, so its errors do
// not count.

module test_illegal_struct_pattern_replication_count;
  typedef struct {
    int a;
    int b;
    int c;
  } abc_t;
  abc_t s;

  initial begin
    s = '{3{7}};
    s = '{2{7}};   // illegal: two values for three members
    $display("%p", s);
  end
endmodule
