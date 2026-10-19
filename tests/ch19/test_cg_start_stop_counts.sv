/*
:name: test_cg_start_stop_counts
:description: stop() and start() suspend and resume collection, and get_inst_coverage with two arguments returns the covered and total bins (IEEE 1800-2023 Section 19.8)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.8 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_start_stop_counts.expected
*/
// IEEE 1800-2023 §19.8: after stop(), samples of the covergroup instance are not
// collected until start() is called. get_inst_coverage(covered, total) also
// assigns the number of covered bins and the number of bins to its two ref
// arguments.
//
// Version 5.052 of Verilator keeps collecting samples after stop() and assigns
// 0 to both arguments; Icarus Verilog 13.0 does not compile covergroups.

module test_cg_start_stop_counts;
  bit [1:0] p;
  int covered, total;
  real pct;

  covergroup cg;
    cp: coverpoint p { bins b[] = {[0:3]}; }
  endgroup

  cg inst;

  initial begin
    inst = new;
    inst.stop();
    p = 0; inst.sample();
    p = 1; inst.sample();
    pct = inst.get_inst_coverage(covered, total);
    $display("stopped: %0.2f (%0d of %0d)", pct, covered, total);
    inst.start();
    p = 2; inst.sample();
    pct = inst.get_inst_coverage(covered, total);
    $display("started: %0.2f (%0d of %0d)", pct, covered, total);
  end
endmodule
