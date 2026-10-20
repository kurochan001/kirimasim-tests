/*
:name: test_cg_cross_with_expression
:description: A cross bin defined with a with clause on the cross collects the bin tuples whose values satisfy the expression, and ignore_bins with a with clause removes the other tuples (IEEE 1800-2023 Section 19.6.1.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.2 19.6.1 19.6.2 19.11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_with_expression.expected
*/
// IEEE 1800-2023 §19.6.1.2: in X with (expression), the names of the crossed
// coverpoints stand for the values of a bin tuple, so diag holds the four
// tuples with ca == cb and anti the four with ca + cb == 3. ignore_bins rest
// (19.6.2) removes all other tuples, so no automatically generated bins are
// left (19.6.1) and the cross has two bins (19.11.2). Sampling the ignored
// tuple <3, 1> changes nothing, <2, 2> hits diag and <1, 2> hits anti.

module test_cg_cross_with_expression;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:3]}; }
    cb: coverpoint b { bins v[] = {[0:3]}; }
    X: cross ca, cb {
      bins diag = X with (ca == cb);
      bins anti = X with (ca + cb == 3);
      ignore_bins rest = X with (ca != cb && ca + cb != 3);
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
    put(3, 1);
    put(2, 2);
    put(1, 2);
  end
endmodule
