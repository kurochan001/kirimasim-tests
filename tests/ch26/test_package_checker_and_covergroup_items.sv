/*
:name: test_package_checker_and_covergroup_items
:description: a package holds a checker and a covergroup; a module instantiates the checker by its package-scoped name and declares covergroup variables of the package type and of a local type (IEEE 1800-2023 Sections 26.2, A.1.11, A.2.2.1)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 A.1.11 A.2.2.1 17.2 17.3 19.3 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_checker_and_covergroup_items.expected
*/
// IEEE 1800-2023 §26.2 and A.1.11: a package item can be a checker
// declaration and a covergroup declaration. §17.2 allows a checker in a
// package, and §17.3 instantiates it by its name, which may be package
// scoped. The checker no_double_pulse asserts sig |=> !sig at each tick of its
// event argument; sig is 0 1 1 0 1 0 at the six rising edges (5 to 55), so the
// attempt of tick 2 fails at tick 3, time 25, and the failure action prints it.
// A.2.2.1: a data type can be a covergroup identifier, with or without a
// package scope. c_pkg has the package covergroup type cg_val, two bins of
// which sample(1), done twice, hits one; c_loc has the module covergroup
// cg_local, three of whose four bins are hit. §19.11: the coverage of an
// instance is the share of its bins that are hit, 50.00 and 75.00 percent.
// Neither release takes the test: Icarus Verilog 13.0 has neither checkers
// nor covergroups, and the other release does not support a checker inside a
// package.

`timescale 1ns/1ns

package pk_chk_cov;
  checker no_double_pulse(logic sig, event clk);
    a_once: assert property (@clk sig |=> !sig)
      else $display("no_double_pulse failed at %0t", $time);
  endchecker

  covergroup cg_val with function sample(int v);
    coverpoint v {
      bins lo = {[0:3]};
      bins hi = {[4:7]};
    }
  endgroup
endpackage

module test_package_checker_and_covergroup_items;
  logic clk = 0, sig = 0;

  covergroup cg_local with function sample(int v);
    coverpoint v {
      bins b0 = {0};
      bins b1 = {1};
      bins b2 = {2};
      bins b3 = {3};
    }
  endgroup

  pk_chk_cov::no_double_pulse u_chk(sig, posedge clk);

  always #5 clk = ~clk;   // rising edges at 5, 15, ..., 55

  initial begin
    static logic [1:6] s = 6'b011010;
    pk_chk_cov::cg_val c_pkg;
    cg_local c_loc;

    c_pkg = new;
    c_loc = new;
    c_pkg.sample(1);
    c_pkg.sample(1);
    c_loc.sample(0);
    c_loc.sample(2);
    c_loc.sample(3);
    $display("c_pkg=%0.2f c_loc=%0.2f", c_pkg.get_inst_coverage(), c_loc.get_inst_coverage());
    for (int k = 1; k <= 6; k++) begin
      sig = s[k];
      #10;
    end
    $display("done at %0t", $time);
    $finish;
  end
endmodule
