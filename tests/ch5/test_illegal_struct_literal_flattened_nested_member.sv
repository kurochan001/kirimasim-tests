/*
:name: test_illegal_struct_literal_flattened_nested_member
:description: A structure literal that lists the members of a nested structure without their own braces is rejected (IEEE 1800-2023 Section 5.10)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.10 10.9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure literal flattens the members of the nested structure s instead of giving them in nested braces
:expected_stderr_regex: test_illegal_struct_literal_flattened_nested_member\.sv:29:
*/
// IEEE 1800-2023 §5.10: the braces of a structure literal shall reflect the
// structure, so a member that is itself a structure gets its own pair of
// braces; the C-like flat list of all leaf values is not allowed. outer_t
// has two members, a and the structure s. The literal with nested braces
// is legal; the flat literal on the marked line gives three items for the
// two members, an error. The test of an array of structures checks the
// same rule for array elements.

module test_illegal_struct_literal_flattened_nested_member;
  typedef struct packed { logic [7:0] b; logic [7:0] c; } inner_t;
  typedef struct packed { logic [7:0] a; inner_t s; } outer_t;
  outer_t v, w;

  initial begin
    v = '{8'd1, '{8'd2, 8'd3}};
    w = '{8'd1, 8'd2, 8'd3};   // illegal: the nested structure has no braces
    $display("%0d %0d %0d", v.a, v.s.b, v.s.c);
  end
endmodule
