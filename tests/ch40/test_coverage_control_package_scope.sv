/*
:name: test_coverage_control_package_scope
:description: The scope of $coverage_control and $coverage_get_max may be a package, whose coverage the calls report (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.2.2 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_package_scope.expected
*/
// IEEE 1800-2023 §40.3.2.1: the scope argument of $coverage_control names a
// module, interface, program, package or $root; with SV_COV_HIER it is a
// hierarchical name. §26.3: cov_pkg is a package of the design. §40.2.2:
// statement coverage counts the statements of the scope, here those of bump.
// The module runs bump twice, then names the package. A tool with no coverage
// of a package answers NOCOV, which is a valid answer, not an error; the
// maximum is the number of coverable items, or NOCOV or OVERFLOW, never ERROR.

package cov_pkg;
  int calls = 0;

  function automatic void bump();
    calls = calls + 1;
  endfunction
endpackage

module test_coverage_control_package_scope;
  import cov_pkg::*;

  initial begin
    bump();
    #1 bump();
    #4;
    begin
      int check;
      int maximum;
      check = $coverage_control(`SV_COV_CHECK, `SV_COV_STATEMENT, `SV_COV_HIER,
                                "cov_pkg");
      maximum = $coverage_get_max(`SV_COV_STATEMENT, `SV_COV_HIER, "cov_pkg");
      $display("package scope check is OK, NOCOV or PARTIAL: %0d",
               check inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL});
      $display("package maximum is not ERROR: %0d", maximum != `SV_COV_ERROR);
    end
    $finish;
  end
endmodule
