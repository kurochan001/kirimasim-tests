/*
:name: test_unit_scope_import
:description: A package imported in the compilation-unit scope is visible to every module of the compilation unit (IEEE 1800-2023 Sections 3.12.1 and 26.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_scope_import.expected
*/
// IEEE 1800-2023 §3.12.1: a declaration in the compilation-unit scope is
// visible to every design element of the compilation unit. §26.3: an import
// written at that scope makes the names of the package visible in the same
// way, so both modules use P and f without another import.

package unit_imp_pkg;
  parameter int P = 5;

  function automatic int f(int x);
    return x + P;
  endfunction
endpackage

import unit_imp_pkg::*;

module m_unit_import_user;
  initial $display("m_user %0d", f(1));
endmodule

module test_unit_scope_import;
  initial #1 $display("top %0d", P);
endmodule
