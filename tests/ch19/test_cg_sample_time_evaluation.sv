/*
:name: test_cg_sample_time_evaluation
:description: The expression of a coverpoint and its iff condition are evaluated when the covergroup is sampled, and they may read signals through a virtual interface (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 25.9 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_sample_time_evaluation.expected
*/
// IEEE 1800-2023 §19.5: the coverpoint expression and its iff condition are
// evaluated when the covergroup is sampled, in a procedural context, so they
// may access signals through a virtual interface (25.9). The covergroup of
// the class mon covers vif.d and vif.d + 1 with the guard vif.en; the class
// gets the virtual interface in its constructor. Each sample uses the values
// the interface holds at that call: d = 1 with en = 1 is covered, d = 2 with
// en = 0 is not, d = 3 with en = 1 is. get_inst_coverage(c, t) gives the
// covered bins and the bins of a coverpoint (19.8).

interface data_if;
  int d;
  bit en;
endinterface

class mon;
  virtual data_if vif;

  covergroup cg;
    cp: coverpoint vif.d iff (vif.en) { bins b[] = {[1:3]}; }
    cq: coverpoint (vif.d + 1) iff (vif.en) { bins b[] = {[2:4]}; }
  endgroup

  function new(virtual data_if v);
    vif = v;
    cg = new;
  endfunction

  task show(string what);
    int pc, pt, qc, qt;
    void'(cg.cp.get_inst_coverage(pc, pt));
    void'(cg.cq.get_inst_coverage(qc, qt));
    $display("%s: cp %0d/%0d, cq %0d/%0d", what, pc, pt, qc, qt);
  endtask
endclass

module test_cg_sample_time_evaluation;
  data_if bus();
  mon m;

  initial begin
    m = new(bus);
    bus.d = 1;
    bus.en = 1;
    m.cg.sample();
    m.show("d=1 en=1");
    bus.d = 2;
    bus.en = 0;
    m.cg.sample();
    m.show("d=2 en=0");
    bus.d = 3;
    bus.en = 1;
    m.cg.sample();
    m.show("d=3 en=1");
  end
endmodule
