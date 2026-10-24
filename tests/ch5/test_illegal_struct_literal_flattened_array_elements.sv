/*
:name: test_illegal_struct_literal_flattened_array_elements
:description: A literal for an array of structures that lists all member values without braces for each element is rejected (IEEE 1800-2023 Section 5.10)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.10 10.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the literal for the array of two structures lists four member values without braces for each structure
:expected_stderr_regex: test_illegal_struct_literal_flattened_array_elements\.sv:29:
*/
// IEEE 1800-2023 §5.10: when an array of structures is initialized, the
// nested braces shall reflect both the array and the structure; the C-like
// flat list of all member values is not allowed. The array has two
// elements of a structure with two members. The literal with a pair of
// braces per element is legal; the flat literal on the marked line gives
// four items for the two elements, an error. The test of a nested
// structure member checks the same rule inside one structure.

module test_illegal_struct_literal_flattened_array_elements;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } ab_t;
  ab_t good [1:0];
  ab_t bad [1:0];

  initial begin
    good = '{'{8'd1, 8'd2}, '{8'd3, 8'd4}};
    bad = '{8'd1, 8'd2, 8'd3, 8'd4};   // illegal: no braces for the structures
    $display("%h %h", good[1], good[0]);
  end
endmodule
