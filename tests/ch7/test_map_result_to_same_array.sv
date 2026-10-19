/*
:name: test_map_result_to_same_array
:description: The result of map() can be assigned back to the array it is called on, a dynamic array or a queue (IEEE 1800-2023 Section 7.12.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_map_result_to_same_array.expected
*/
// IEEE 1800-2023 §7.12.5: map() returns a new array with one element for
// each element of the array, computed by the with clause; the array itself
// is not changed by the call. The result can be assigned to another array or
// back to the same one: A = A.map() with (item + 1) leaves A with the
// incremented elements, as the example of 7.12.5 does.

module test_map_result_to_same_array;
  int A[] = '{1, 2, 3};
  int D[];
  int Q[$] = '{5, 6};

  initial begin
    D = A.map() with (item + 1);
    $display("D: size %0d, %0d %0d %0d; A unchanged: %0d %0d %0d", D.size(), D[0], D[1],
             D[2], A[0], A[1], A[2]);
    A = A.map() with (item + 1);
    $display("A: size %0d, %0d %0d %0d", A.size(), A[0], A[1], A[2]);
    Q = Q.map() with (item * 2);
    $display("Q: size %0d, %0d %0d", Q.size(), Q[0], Q[1]);
  end
endmodule
