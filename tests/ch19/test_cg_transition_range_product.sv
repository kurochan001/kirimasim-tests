/*
:name: test_cg_transition_range_product
:description: A transition between two range lists stands for the transition from every value of the first to every value of the second, one bin each in a bin array and all in one bin otherwise (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_transition_range_product.expected
*/
// IEEE 1800-2023 §19.5.2: range_list1 => range_list2 expands to the transitions
// from each value of range_list1 to each value of range_list2. In arr[],
// ([1:2], 5 => 3, [6:7]) is the 3 x 3 = 9 transitions 1 => 3, ..., 5 => 7, each
// a bin of the array; one = ([1:2] => [6:7]) is one bin for its 4 transitions.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8). The
// samples 2, 7, 5, 3, 1, 6, 4 have the transitions 2 => 7, 7 => 5, 5 => 3,
// 3 => 1, 1 => 6 and 6 => 4, of which 2 => 7, 5 => 3 and 1 => 6 are in arr[],
// and 2 => 7 and 1 => 6 in one.

module test_cg_transition_range_product;
  bit [2:0] v;

  covergroup cg;
    arr: coverpoint v { bins t[] = ([1:2], 5 => 3, [6:7]); }
    one: coverpoint v { bins s = ([1:2] => [6:7]); }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] x);
    int ac, at, oc, ot;
    v = x;
    g.sample();
    void'(g.arr.get_inst_coverage(ac, at));
    void'(g.one.get_inst_coverage(oc, ot));
    $display("v=%0d: arr %0d/%0d, one %0d/%0d", x, ac, at, oc, ot);
  endtask

  initial begin
    put(2);
    put(7);
    put(5);
    put(3);
    put(1);
    put(6);
    put(4);
  end
endmodule
