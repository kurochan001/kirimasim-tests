/*
:name: test_associative_array_query_functions
:description: The array query functions on associative arrays with integral indices give 0, the highest possible index, the lowest and highest allocated indices, -1 and the size (IEEE 1800-2023 Section 20.7)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 7.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_associative_array_query_functions.expected
*/
// IEEE 1800-2023 §20.7: for an associative array (7.8) with an integral
// index type, $left is 0, $right is the highest value the index type can
// hold (15 for bit [3:0], 127 for byte), $low and $high are the lowest and
// highest indices allocated, or x when the array is empty, $increment is -1
// and $size is the number of elements. For a queue, $increment is -1 too.

module test_associative_array_query_functions;
  int a4[bit [3:0]];
  int ab[byte];
  int emp[int];
  int que[$];

  initial begin
    a4[4'd9] = 1;
    a4[4'd2] = 2;
    ab[100] = 1;
    ab[-5] = 2;
    que.push_back(1);
    $display("a4: left=%0d right=%0d low=%0d high=%0d increment=%0d size=%0d", $left(a4),
             $right(a4), $low(a4), $high(a4), $increment(a4), $size(a4));
    $display("ab: left=%0d right=%0d low=%0d high=%0d increment=%0d size=%0d", $left(ab),
             $right(ab), $low(ab), $high(ab), $increment(ab), $size(ab));
    $display("empty: low=%0d high=%0d size=%0d", $low(emp), $high(emp), $size(emp));
    $display("queue: increment=%0d", $increment(que));
  end
endmodule
