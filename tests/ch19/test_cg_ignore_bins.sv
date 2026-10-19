/*
:name: test_cg_ignore_bins
:description: ignore_bins remove their values from the other bins after the values are shared out, and bins left empty are not counted (IEEE 1800-2023 Section 19.5.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.5 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_ignore_bins.expected
*/
// IEEE 1800-2023 §19.5.5: the values of ignore_bins are taken out of every
// other bin after the values have been given to the bins. bins x[] = {[0:3]}
// makes x[0] to x[3]; ignoring 2 and 3 leaves x[2] and x[3] empty, and empty
// bins do not count (19.11.1), so the coverpoint has 2 bins. Sampling an
// ignored value covers nothing.
//
// Version 5.052 of Verilator keeps x[2] and x[3] and counts the ignored values
// in them; Icarus Verilog 13.0 does not compile covergroups.

module test_cg_ignore_bins;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins x[] = {[0:3]};
      ignore_bins skip = {2, 3};
    }
  endgroup

  cg inst;

  initial begin
    inst = new;
    a = 2; inst.sample();
    a = 3; inst.sample();
    $display("after the ignored values 2 and 3: %0.2f", inst.get_inst_coverage());
    a = 0; inst.sample();
    $display("after 0: %0.2f", inst.get_inst_coverage());
    a = 1; inst.sample();
    $display("after 1: %0.2f", inst.get_inst_coverage());
  end
endmodule
