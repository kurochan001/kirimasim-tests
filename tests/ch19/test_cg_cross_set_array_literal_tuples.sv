/*
:name: test_cg_cross_set_array_literal_tuples
:description: A cross bin defined by an array literal of value tuples, which takes the CrossQueueType of the cross as its type, selects exactly the bin tuples that contain those value tuples (IEEE 1800-2023 Section 19.6.1.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_set_array_literal_tuples.expected
*/
// IEEE 1800-2023 §19.6.1.4: a cross bin can be defined by an expression
// whose value is a queue of the CrossQueueType of the cross; for an array
// literal the cross bin gives the type of the literal, whose elements are
// then CrossValType value tuples (19.6.1.3), with the crossed coverpoints in
// the order of the cross. A bin tuple is selected when one of its value
// tuples is in the queue (19.6.1.2). The products that no user bin selects
// keep automatic bins (19.6.1), and the coverage of a cross is its covered
// bins over those automatic bins plus the user bins (19.11.2);
// get_inst_coverage(c, t) gives these two numbers (19.8).
//
// ca and cb have one bin for each value 0 to 3, so the cross X has 16
// products. pairs holds the value tuples <0,3> and <1,2>, so it selects the
// products <ca 0, cb 3> and <ca 1, cb 2>; the other 14 products are
// automatic bins, 15 bins in all. (0,3) and (1,2) both hit pairs, so the
// second adds nothing; (3,0), (2,1) and (0,0) hit automatic bins. Taking
// each element of the literal as a set of values for each coverpoint would
// give pairs 8 products, and swapping the members of a tuple would give
// <3,0> and <2,1> to pairs; both change the numbers.
// Icarus Verilog 13.0 does not compile covergroups, and the 5.054 release
// of Verilator does not parse an array literal as a cross bin.

module test_cg_cross_set_array_literal_tuples;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:3]}; }
    cb: coverpoint b { bins v[] = {[0:3]}; }
    X: cross ca, cb {
      bins pairs = '{ '{0, 3}, '{1, 2} };
    }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    int c, t;
    a = va;
    b = vb;
    g.sample();
    void'(g.X.get_inst_coverage(c, t));
    $display("(%0d,%0d): X %0d/%0d", va, vb, c, t);
  endtask

  initial begin
    put(0, 3);
    put(1, 2);
    put(3, 0);
    put(2, 1);
    put(0, 0);
  end
endmodule
