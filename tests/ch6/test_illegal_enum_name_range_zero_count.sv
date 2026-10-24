/*
:name: test_illegal_enum_name_range_zero_count
:description: the count N of an enum name range name[N] has to be a positive integral number; [0] is illegal (IEEE 1800-2023 Section 6.19.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the enum name range dead[0] has a count of zero
:expected_stderr_regex: test_illegal_enum_name_range_zero_count\.sv:24:
*/
// IEEE 1800-2023 §6.19.2 (Table 6-10): name[N] generates N named constants,
// and N shall be a positive integral number, also when a value is assigned
// to the first constant. The first enum uses the smallest legal count, [1],
// with and without a value; the second gives a count of zero.
// The 5.052 release accepts the zero count.

module test_illegal_enum_name_range_zero_count;
  typedef enum {one[1], two[1] = 5, three[2:2]} ok_t;
  ok_t v = two0;
  initial $display("%0d", v);
  typedef enum {alive, dead[0]} bad_t;   // illegal: count zero
endmodule
