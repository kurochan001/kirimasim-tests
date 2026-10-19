/*
:name: test_cg_transition_bins
:description: Transition bins are covered by a sequence of values at successive samples, and a set of transitions forms one bin (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.2 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_transition_bins.expected
*/
// IEEE 1800-2023 §19.5.2: a transition bin such as (4 => 5 => 6) is covered when
// the coverpoint takes those values at successive samples, in that order.
// (0, 1 => 2) stands for the transitions 0 => 2 and 1 => 2, which together form
// the single bin set. The values alone, or the same values in another order or
// with another value in between, do not cover a transition bin.

module test_cg_transition_bins;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins set = (0, 1 => 2);
      bins seq3 = (4 => 5 => 6);
      bins down = (6 => 5);
    }
  endgroup

  cg inst;

  task automatic put(bit [2:0] v);
    a = v;
    inst.sample();
  endtask

  initial begin
    inst = new;
    put(4); put(6); put(4);
    $display("4, 6, 4 (no transition of a bin): %0.2f", inst.get_inst_coverage());
    put(1); put(2);
    $display("then 1, 2: %0.2f", inst.get_inst_coverage());
    put(4); put(5); put(6);
    $display("then 4, 5, 6: %0.2f", inst.get_inst_coverage());
    put(5);
    $display("then 5 (6 => 5): %0.2f", inst.get_inst_coverage());
  end
endmodule
