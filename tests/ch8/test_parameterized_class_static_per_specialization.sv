/*
:name: test_parameterized_class_static_per_specialization
:description: Each specialization of a parameterized class has its own static properties, also when the constructor updates them (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameterized_class_static_per_specialization.expected
*/
// IEEE 1800-2023 §8.25: each specialization of a parameterized class, each
// unique set of parameter values, is a class of its own, so each has its
// own copy of the static properties (8.9). A constructor that counts objects
// in a static property counts them per specialization: box #(1) and the
// default box, which is box #(1) too, share one count, box #(2) has another.

class box #(int W = 1);
  static int count = 0;
  int self_id;
  function new();
    count++;
    self_id = count;
  endfunction
endclass

module test_parameterized_class_static_per_specialization;
  box #(1) a, b;
  box #(2) c;
  box d;

  initial begin
    a = new;
    b = new;
    c = new;
    d = new;
    $display("ids: a=%0d b=%0d c=%0d d=%0d", a.self_id, b.self_id, c.self_id, d.self_id);
    $display("box#(1)::count=%0d box#(2)::count=%0d", box#(1)::count, box#(2)::count);
  end
endmodule
