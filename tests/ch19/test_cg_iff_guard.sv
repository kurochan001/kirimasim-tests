/*
:name: test_cg_iff_guard
:description: A coverpoint with an iff guard ignores the samples taken while the guard is false (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_iff_guard.expected
*/
// IEEE 1800-2023 §19.5: coverpoint a iff (en) samples a only when en is true at
// the sampling point; a sample taken while en is false changes no bin.

module test_cg_iff_guard;
  bit [1:0] a;
  bit en;

  covergroup cg;
    cp: coverpoint a iff (en) { bins b[] = {[0:3]}; }
  endgroup

  cg inst;

  initial begin
    inst = new;
    en = 0;
    a = 0; inst.sample();
    a = 1; inst.sample();
    $display("guard false, after 0 and 1: %0.2f", inst.get_inst_coverage());
    en = 1;
    a = 2; inst.sample();
    $display("guard true, after 2: %0.2f", inst.get_inst_coverage());
    a = 0; inst.sample();
    $display("guard true, after 0: %0.2f", inst.get_inst_coverage());
  end
endmodule
