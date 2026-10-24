/*
:name: test_illegal_enum_name_range_negative_last
:description: the second bound M of an enum name range name[N:M] has to be a nonnegative integral number (IEEE 1800-2023 Section 6.19.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the enum name range s[1:-1] has a negative second bound
:expected_stderr_regex: test_illegal_enum_name_range_negative_last\.sv:23:
*/
// IEEE 1800-2023 §6.19.2 (Table 6-10): in name[N:M], with or without a
// value, N and M shall be nonnegative integral numbers. The first enum uses
// zero as either bound, which is the smallest legal value, and counts up and
// down; the second enum has -1 as the second bound, after a legal first one.

module test_illegal_enum_name_range_negative_last;
  typedef enum {a[0:2], b[3:0] = 10} ok_t;
  ok_t v = b0;
  initial $display("%0d", v);
  typedef enum {s[1:-1] = 4} bad_t;   // illegal: M is negative
endmodule
