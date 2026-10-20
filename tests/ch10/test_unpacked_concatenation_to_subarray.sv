/*
:name: test_unpacked_concatenation_to_subarray
:description: An unpacked array concatenation can be assigned to a sub-array of a multidimensional unpacked array (IEEE 1800-2023 Section 10.10)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.10 7.4.4 10.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_concatenation_to_subarray.expected
*/
// IEEE 1800-2023 §10.10: an unpacked array concatenation, {a, b}, can be
// assigned to an unpacked array; its items fill the elements from the left
// bound. §7.4.4: selecting the leading dimensions of a multidimensional
// unpacked array, m[1] or arr[5][2], gives such an array, so it can be the
// target too: m[1] = {3, 4} sets m[1][1] to 3 and m[1][0] to 4. An array
// assignment pattern (10.9.1) does the same.

module test_unpacked_concatenation_to_subarray;
  integer arr[7:0][3:0][1:0];
  int m[1:0][1:0];
  int s[1:0];

  initial begin
    arr[5][2] = {32'sd7, 32'sd9};
    m[1] = {3, 4};
    m[0] = '{1, 2};
    s = {5, 6};
    $display("arr[5][2]: %0d %0d", arr[5][2][1], arr[5][2][0]);
    $display("m[1]: %0d %0d, m[0]: %0d %0d", m[1][1], m[1][0], m[0][1], m[0][0]);
    $display("s: %0d %0d", s[1], s[0]);
  end
endmodule
