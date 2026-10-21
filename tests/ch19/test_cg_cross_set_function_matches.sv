/*
:name: test_cg_cross_set_function_matches
:description: A function declared in a cross builds a CrossQueueType from CrossValType elements whose members are named after the coverpoints, and a cross bin set from it selects a bin tuple when the number of its value tuples in the queue reaches the matches count, one by default (IEEE 1800-2023 Section 19.6.1.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.4 19.6.1.3 19.6.1.2 19.6.1 19.11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_set_function_matches.expected
*/
// IEEE 1800-2023 §19.6.1.3: in a cross, CrossValType is a struct with a member
// of the name and type of each crossed coverpoint, and CrossQueueType a queue
// of them. §19.6.1.4: a cross bin can be given by any expression of type
// CrossQueueType, here a call of the function swapped, declared in the cross,
// with the covergroup argument lim, 3, which gives the value tuples <0,1>,
// <1,0> and <2,3>. A bin tuple is selected when at least the matches count of
// its value tuples is in the queue, one by default (19.6.1.2). <lo,lo> holds
// two of them and <hi,hi> one, so two is <lo,lo> and any is <lo,lo> and
// <hi,hi>. The cross has these 2 user bins and the 2 automatic bins <lo,hi>
// and <hi,lo> of the products no user bin selects (19.6.1, 19.11.2).

module test_cg_cross_set_function_matches;
  bit [1:0] a, b;

  covergroup cg (int lim);
    ca: coverpoint a { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    cb: coverpoint b { bins lo = {[0:1]}; bins hi = {[2:3]}; }
    X: cross ca, cb {
      function automatic CrossQueueType swapped(int n);
        CrossQueueType q;
        CrossValType t;
        for (int i = 0; i < n; i++) begin
          t.ca = i;
          t.cb = i ^ 1;
          q.push_back(t);
        end
        return q;
      endfunction
      bins two = swapped(lim) matches 2;
      bins any = swapped(lim);
    }
  endgroup

  cg g = new(3);

  task automatic put(bit [1:0] va, bit [1:0] vb);
    int c, t;
    a = va;
    b = vb;
    g.sample();
    void'(g.X.get_inst_coverage(c, t));
    $display("a=%0d b=%0d: cross %0d/%0d %.2f", va, vb, c, t, g.X.get_inst_coverage());
  endtask

  initial begin
    put(2, 3);
    put(1, 0);
    put(0, 3);
    put(3, 1);
  end
endmodule
