/*
:name: test_package_scoped_name_avoids_wildcard_conflict
:description: Explicit package qualification resolves same-named declarations despite competing wildcard imports (IEEE 1800-2023 Section 26.5)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.5 23.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_scoped_name_avoids_wildcard_conflict.expected
*/
// IEEE 1800-2023 26.5 23.7.1: Wildcard candidates need not conflict until
// referenced;
// a fully scoped reference selects its package without importing an ambiguous
// simple name.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

package scope_left; int value = 11; endpackage
package scope_right; int value = 29; endpackage
module test_package_scoped_name_avoids_wildcard_conflict;
  import scope_left::*;
  import scope_right::*;
  initial begin
    scope_left::value = 13;
    $display("left=%0d right=%0d", scope_left::value, scope_right::value);
  end
endmodule
