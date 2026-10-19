/*
:name: test_nested_default_assignment_pattern
:description: Nested default assignment patterns on a two-dimensional array, and an assignment pattern that initializes a dynamic array of fixed-size arrays (IEEE 1800-2023 Section 10.9.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.1 7.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_default_assignment_pattern.expected
*/
// IEEE 1800-2023 §10.9.1: in an array assignment pattern, default: gives the
// value of every element not otherwise listed. The value can itself be an
// assignment pattern, so '{default: '{default: 7}} sets every element of a
// two-dimensional array; '{default: 9} on such an array also reaches every
// element, since 9 is assignable to an element and not to a row. An
// assignment pattern of rows also initializes a dynamic array of fixed-size
// arrays (7.5), giving it as many elements as rows.

module test_nested_default_assignment_pattern;
  int a[4][4] = '{default: '{default: 7}};
  int b[2][3] = '{default: 9};
  int data[][2] = '{'{1, 2}, '{3, 4}};

  initial begin
    $display("a: %0d %0d %0d", a[0][0], a[2][1], a[3][3]);
    $display("b: %0d %0d", b[0][0], b[1][2]);
    $display("data: size %0d, %0d %0d %0d %0d", data.size(), data[0][0], data[0][1],
             data[1][0], data[1][1]);
  end
endmodule
