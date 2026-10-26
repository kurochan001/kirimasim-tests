/*
:name: test_reverse_order
:description: reverse reverses the element order of a fixed array and of a queue in place
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reverse_order.expected
*/
// IEEE 1800-2023 7.12.2: reverse() reverses the order of the elements of an
// array in place. The fixed array 1,2,3,4,5 becomes 5,4,3,2,1 and the queue
// 10,20,30 becomes 30,20,10. The clause also makes a with clause on reverse a
// compilation error; a legal test cannot contain that error, so the several
// existing tests of the normal form and this one cover the reversal only.
// Icarus Verilog 13.0 does not implement reverse().

module test_reverse_order;
  int a[5] = '{1, 2, 3, 4, 5};
  int q[$];

  initial begin
    q.push_back(10);
    q.push_back(20);
    q.push_back(30);
    a.reverse();
    q.reverse();
    $display("a=%0d %0d %0d %0d %0d", a[0], a[1], a[2], a[3], a[4]);
    $display("q=%0d %0d %0d", q[0], q[1], q[2]);
  end
endmodule
