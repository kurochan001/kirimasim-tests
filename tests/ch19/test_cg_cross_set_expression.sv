/*
:name: test_cg_cross_set_expression
:description: A cross bin defined by an array literal of value tuples, of the type CrossQueueType of the cross, collects exactly the bin tuples that contain those values (IEEE 1800-2023 Section 19.6.1.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.4 19.6.1.3 19.6.1.2 19.11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_set_expression.expected
*/
// IEEE 1800-2023 §19.6.1.4, §19.6.1.3: the array literal of bin pairs has the
// type CrossQueueType of the cross, a queue of value tuples, so pairs holds
// <0, 3> and <3, 0>. ones holds the tuples with ca == 1 (19.6.1.2), and
// ignore_bins removes every other tuple, so the cross has two bins (19.11.2).
// <2, 1> is ignored, <3, 0> hits pairs and <1, 3> hits ones.

module test_cg_cross_set_expression;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:3]}; }
    cb: coverpoint b { bins v[] = {[0:3]}; }
    X: cross ca, cb {
      bins pairs = '{ '{0, 3}, '{3, 0} };
      bins ones = X with (ca == 1);
      ignore_bins rest = X with (ca != 1 && !(ca == 0 && cb == 3) && !(ca == 3 && cb == 0));
    }
  endgroup

  cg g = new();

  task automatic put(bit [1:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
    $display("a=%0d b=%0d: cross %0.2f", a, b, g.X.get_inst_coverage());
  endtask

  initial begin
    put(2, 1);
    put(3, 0);
    put(1, 3);
  end
endmodule
