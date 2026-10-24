/*
:name: test_cg_derived_option_override
:description: An option that a derived embedded covergroup sets again overrides the one of its base covergroup, and the base options that it does not set still apply to it (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 19.7 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_derived_option_override.expected
*/
// IEEE 1800-2023 §19.4.1: when a derived covergroup specifies a coverage option
// that its base covergroup also specifies, the derived value overrides the
// base one; base options that it does not override apply to the derived
// covergroup. The base covergroup cg sets at_least 2 and auto_bin_max 4
// (19.7); the derived one sets only at_least 1. So the coverpoint cp of the
// 3-bit v has 4 automatic bins in both, and one sample covers a bin in the
// derived covergroup but not in the base one, where a bin needs two hits.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_derived_option_override;
  class base;
    bit [2:0] v;
    covergroup cg;
      option.at_least = 2;
      option.auto_bin_max = 4;
      cp: coverpoint v;
    endgroup
    function new();
      cg = new;
    endfunction
    function void put(bit [2:0] x);
      v = x;
      cg.sample();
    endfunction
  endclass

  class derived extends base;
    covergroup extends cg;
      option.at_least = 1;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  base b;
  derived d;

  initial begin
    int bc, bt, dc, dt;
    b = new;
    d = new;
    b.put(0);
    d.put(0);
    void'(b.cg.cp.get_inst_coverage(bc, bt));
    void'(d.cg.cp.get_inst_coverage(dc, dt));
    $display("base: at_least %0d, auto_bin_max %0d, cp %0d/%0d", b.cg.option.at_least,
             b.cg.option.auto_bin_max, bc, bt);
    $display("derived: at_least %0d, auto_bin_max %0d, cp %0d/%0d", d.cg.option.at_least,
             d.cg.option.auto_bin_max, dc, dt);
  end
endmodule
