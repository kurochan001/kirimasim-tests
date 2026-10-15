/*
:name: test_unit_scope_shadow_minimal
:description: A local name hides $unit and package names, which stay reachable by scope
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_scope_shadow_minimal.expected
*/
// A local name hides $unit and package names, which stay reachable by scope
package pkg_global;
  parameter int G = 11;
endpackage

// $unit scope symbol
int G = 3;

module test_unit_scope_shadow_minimal;
  import pkg_global::*;
  // Local symbol shadows $unit.G, but $unit::G remains accessible
  int G = 7;
  initial begin
    if (G != 7) $fatal(1, "local shadow failed");
    if ($unit::G != 3) $fatal(1, "$unit lookup failed");
    if (pkg_global::G != 11) $fatal(1, "package G failed");
    $display("TEST PASSED: unit scope shadow minimal");
    $finish;
  end
endmodule
