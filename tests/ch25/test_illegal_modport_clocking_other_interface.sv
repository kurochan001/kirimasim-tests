/*
:name: test_illegal_modport_clocking_other_interface
:description: A clocking block named in a modport has to be declared in the same interface as the modport (IEEE 1800-2023 Section 25.5.5)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modport tb of mco_user names the clocking block cb, which is declared in the interface mco_bus and not in mco_user
:expected_stderr_regex: test_illegal_modport_clocking_other_interface\.sv:32:
*/
// IEEE 1800-2023 §25.5.5: all clocking blocks used in a modport declaration
// shall be declared by the same interface as the modport. The modport stb of
// mco_bus names the clocking block cb of mco_bus, which is legal. The
// interface mco_user declares no clocking block, and its modport tb names
// cb, the clocking block of mco_bus.
// Oracle checks: Icarus Verilog 13.0 does not support clocking blocks in
// interfaces and stops at the clocking block of mco_bus.

interface mco_bus(input logic clk);
  logic req;
  clocking cb @(posedge clk);
    output req;
  endclocking
  modport stb (clocking cb);
endinterface

interface mco_user(input logic clk);
  logic req;
  modport tb (clocking cb);   // illegal: cb belongs to mco_bus
endinterface

module test_illegal_modport_clocking_other_interface;
  logic clk = 1'b0;
  mco_bus b (clk);
  mco_user u (clk);
endmodule
