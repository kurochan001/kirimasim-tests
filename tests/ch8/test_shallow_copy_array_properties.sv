/*
:name: test_shallow_copy_array_properties
:description: A shallow copy with new copies the elements of dynamic array, queue and fixed-size array properties (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12 7.5 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shallow_copy_array_properties.expected
*/
// IEEE 1800-2023 §8.12: "b = new a" makes a new object whose properties are
// copies of those of a; only the objects that handle properties point to are
// shared. A dynamic array (7.5), a queue (7.10) or a fixed-size array is a
// variable, not a handle, so the copy gets its own elements: writing them in
// b leaves a unchanged.

class holder;
  int d[];
  int q[$];
  int fixed[2];
endclass

module test_shallow_copy_array_properties;
  holder a, b;

  initial begin
    a = new;
    a.d = new[2];
    a.d[0] = 1;
    a.q.push_back(5);
    a.fixed[0] = 3;
    b = new a;
    b.d[0] = 99;
    b.q[0] = 98;
    b.fixed[0] = 97;
    b.q.push_back(6);
    $display("a: d[0]=%0d q[0]=%0d q.size=%0d fixed[0]=%0d", a.d[0], a.q[0], a.q.size(),
             a.fixed[0]);
    $display("b: d[0]=%0d q[0]=%0d q.size=%0d fixed[0]=%0d", b.d[0], b.q[0], b.q.size(),
             b.fixed[0]);
  end
endmodule
