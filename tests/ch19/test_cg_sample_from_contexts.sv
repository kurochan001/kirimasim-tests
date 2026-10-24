/*
:name: test_cg_sample_from_contexts
:description: An overridden sample method with an argument takes data from a local variable of an automatic function, from automatic variables of forked processes and from a local variable of a sequence through a match item, which holds the sampled value of what it stores (IEEE 1800-2023 Section 19.8.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8.1 16.10 16.11 16.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_sample_from_contexts.expected
*/
// IEEE 1800-2023 §19.8.1: a sample method with arguments lets data be passed
// to a covergroup from contexts other than its enclosing scope: from an
// automatic function or task, from a particular instance of a process, or from
// a sequence or property of a concurrent assertion, whose values are sampled
// as assertions sample them, in the Preponed region (16.5.1). Here
// from_function passes its local variable j + 1 = 1, and two forked processes
// pass their own automatic k, 2 and 3. The sequence s_pass stores d in its
// local variable lv (16.10) at a rising edge of clk and calls g.sample(lv) as
// a match item (16.11) at the next one. d is 2 until a nonblocking assignment
// at the edge at 5 makes it 6, and another one at the edge at 15 makes it 7;
// the sampled values at the edges at 5 and 15 are 2 and 6, so the sequence
// passes 2 at 15, a bin already covered, and 6 at 25. Values read after the
// nonblocking assignments, 6 and 7, would cover one bin more.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

`timescale 1ns/1ns

module test_cg_sample_from_contexts;
  bit clk = 0;
  int d = 2;

  covergroup cg with function sample(int x);
    cp: coverpoint x { bins b[] = {[0:7]}; }
  endgroup

  cg g = new;

  function automatic void from_function(int j);
    int local_v = j + 1;
    g.sample(local_v);
  endfunction

  sequence s_pass;
    int lv;
    (1, lv = d) ##1 (1, g.sample(lv));
  endsequence

  cover property (@(posedge clk) s_pass);

  always #5 clk = ~clk;

  task automatic show(string what);
    int c, t;
    void'(g.cp.get_inst_coverage(c, t));
    $display("%s: %0d/%0d", what, c, t);
  endtask

  initial begin
    from_function(0);
    show("automatic function");
    fork
      begin
        automatic int k = 2;
        g.sample(k);
      end
      begin
        automatic int k = 3;
        g.sample(k);
      end
    join
    show("forked processes");
    @(posedge clk) d <= 6;
    @(posedge clk) d <= 7;
    #12 show("sequence match items");
    $finish;
  end
endmodule
