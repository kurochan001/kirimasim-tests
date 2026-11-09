/*
:name: test_cg_extends_type_option_inherited
:description: A derived embedded covergroup takes the type options of its base covergroup that it does not set, so type_option.merge_instances of the base makes its type coverage the union of its own instances, without the base instances, while an option it sets again overrides the base value (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4.1 19.7 19.7.1 19.11.3 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_extends_type_option_inherited.expected
*/
// IEEE 1800-2023 §19.4.1: the coverage options of a base covergroup (option
// and type_option, Syntax 19-1) that a derived covergroup does not set apply
// to it, an option it sets again overrides the base value, and for
// get_coverage() the base and the derived covergroup are separate types.
// §19.7.1 and §19.11.3: with type_option.merge_instances = 1 the type coverage
// is that of the union of the bins of all instances of the type; without it,
// it is the average of the instances. §19.7: with merge_instances set,
// option.get_inst_coverage = 0 makes get_inst_coverage() return the type
// coverage, and 1 makes it return the coverage of the instance.
// The base cg sets merge_instances 1 and get_inst_coverage 1; the derived cg
// sets get_inst_coverage 0 and adds cn. Coverpoint cm has the bins 0 to 3,
// cn the bins 0 and 1.
// - Base instances: b1 samples m = 2 and 3, b2 samples m = 3. The base type
//   merges them: 2 of 4 bins, 50.00 (the average would be 37.50); b1 has
//   50.00 and b2 25.00 as instances.
// - Derived instances: d1 samples m = 0, n = 0 and d2 samples m = 1, n = 1.
//   The derived type, with the inherited merge, has cm 2 of 4 (50%) and cn 2
//   of 2 (100%), 75.00 (the average of the instances would be 37.50); the
//   base instances do not count. cm alone has 50.00. With get_inst_coverage
//   0, d1 and d2 return the type coverage, 75.00 (each instance alone has
//   37.50).
// Icarus Verilog 13.0 has no covergroups in classes, and the 5.052 release
// of Verilator does not support covergroup extends.

module test_cg_extends_type_option_inherited;
  class base;
    bit [1:0] m;
    covergroup cg;
      type_option.merge_instances = 1;
      option.get_inst_coverage = 1;
      cm: coverpoint m { bins b[] = {[0:3]}; }
    endgroup
    function new();
      cg = new;
    endfunction
  endclass

  class derived extends base;
    bit n;
    covergroup extends cg;
      option.get_inst_coverage = 0;
      cn: coverpoint n { bins b[] = {[0:1]}; }
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  base b1, b2;
  derived d1, d2;

  initial begin
    b1 = new;
    b2 = new;
    d1 = new;
    d2 = new;
    b1.m = 2; b1.cg.sample();
    b1.m = 3; b1.cg.sample();
    b2.m = 3; b2.cg.sample();
    d1.m = 0; d1.n = 0; d1.cg.sample();
    d2.m = 1; d2.n = 1; d2.cg.sample();
    $display("base type %.2f, b1 %.2f, b2 %.2f", b1.cg.get_coverage(),
             b1.cg.get_inst_coverage(), b2.cg.get_inst_coverage());
    $display("derived type %.2f, cm type %.2f, d1 %.2f, d2 %.2f", d1.cg.get_coverage(),
             d1.cg.cm.get_coverage(), d1.cg.get_inst_coverage(), d2.cg.get_inst_coverage());
  end
endmodule
