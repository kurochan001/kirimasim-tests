/*
:name: test_cg_extends_inherited_event_base_handle
:description: A derived embedded covergroup is sampled on the coverage event of its base covergroup, including its added coverpoints, and the covergroup member reached through a base class handle of a derived object is the derived instance (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 19.3 19.4 19.11 19.11.1 19.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_extends_inherited_event_base_handle.expected
*/
// IEEE 1800-2023 §19.4.1: a derived covergroup uses the coverage event of
// its base covergroup, here the class event smp, and a coverpoint with a new
// name is an additional coverpoint sampled with the others. The derived
// covergroup replaces the base instance, so every reference to cg in the
// class and its base classes, including the base constructor and a base
// class handle to the derived object, reaches the derived instance. §19.3: a
// clocking event samples the covergroup when it takes place. §19.11 and
// §19.11.1: the coverage of a covergroup is the average of its items (weights
// 1), and cm, a 2-bit coverpoint, has 4 automatic bins, cf 2 (§19.5.3).
// The derived object sees m = 1, f = 0 and then m = 2, f = 1, each followed
// by -> smp: cm covers 2 of 4 bins (50%), cf both (100%), so the instance has
// 75.00, through the derived handle and through the base handle bh alike,
// and bh.cg.cm reports 2/4. The base object sees m = 1 once: its covergroup
// has only cm, 1 of 4 bins, 25.00. Each trigger is followed by a delay, so
// the values do not change before the sample.
// Icarus Verilog 13.0 has no covergroups in classes, and the 5.052 release
// of Verilator does not support covergroup extends.

module test_cg_extends_inherited_event_base_handle;
  class base;
    bit [1:0] m;
    event smp;
    covergroup cg @(smp);
      cm: coverpoint m;
    endgroup
    function new();
      cg = new;
    endfunction
    task put(bit [1:0] v);
      m = v;
      -> smp;
      #1;
    endtask
  endclass

  class derived extends base;
    bit f;
    covergroup extends cg;
      cf: coverpoint f;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  base b, bh;
  derived d;
  int c, t;

  initial begin
    b = new;
    d = new;
    bh = d;
    d.f = 0;
    d.put(1);
    d.f = 1;
    d.put(2);
    b.put(1);
    void'(bh.cg.cm.get_inst_coverage(c, t));
    $display("derived object: %.2f, through base handle: %.2f, cm %0d/%0d",
             d.cg.get_inst_coverage(), bh.cg.get_inst_coverage(), c, t);
    $display("base object: %.2f", b.cg.get_inst_coverage());
  end
endmodule
