/*
:name: test_package_lookup_reference_point
:description: a name other than a subroutine call is looked up among the declarations and wildcard imports before it, a call among all declarations of the scope, before the compilation unit is searched (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_lookup_reference_point.expected
*/
// IEEE 1800-2023 §26.3: a reference that is not a task or function call is
// first matched against the identifiers that are locally visible at its
// point, that is, declared or explicitly imported before it; a call is
// matched against those up to the end of the scope. If nothing matches, the
// names that a wildcard import before the reference makes potentially
// visible are tried, and a match is imported. Otherwise the search goes on
// in the outer scope, here the compilation unit.
// The compilation unit declares z = 300, k = 100 and a function f that
// returns 1; package lp has k = 5, m = 6 and a function f that returns 50.
// In the module, z_first reads z before the local z = 30 is declared and
// z_then after it; k_first reads k before the wildcard import of lp and
// k_then after it; m comes from that import. The call f() comes before the
// module's own function f, which returns 2, and still calls it.
// Icarus Verilog 13.0 gives k_first=5: it binds the reference before the
// wildcard import to lp::k as well, when k is also referenced after the
// import. The 5.052 release of Verilator gives z_first=30 and k_first=5.

localparam int z = 300;
localparam int k = 100;
function automatic int f();
  return 1;
endfunction

package lp;
  localparam int k = 5;
  localparam int m = 6;
  function automatic int f();
    return 50;
  endfunction
endpackage

module test_package_lookup_reference_point;
  localparam int z_first = z;
  localparam int z = 30;
  localparam int z_then = z;
  localparam int k_first = k;
  import lp::*;
  localparam int k_then = k;
  localparam int m_then = m;

  initial #1 $display("z_first=%0d z_then=%0d k_first=%0d k_then=%0d m=%0d f()=%0d",
                      z_first, z_then, k_first, k_then, m_then, f());

  function automatic int f();
    return 2;
  endfunction
endmodule
