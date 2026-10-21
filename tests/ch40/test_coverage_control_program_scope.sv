/*
:name: test_coverage_control_program_scope
:description: The scope of $coverage_control and $coverage_get_max may be a program instance, whose coverage the calls report (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.2.2 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_program_scope.expected
*/
// IEEE 1800-2023 §40.3.2.1: the scope argument of $coverage_control names a
// module, interface, program, package or $root; with SV_COV_HIER it is a
// hierarchical name. §24.3: the program p is an instance of the design.
// §40.2.2: toggle coverage counts the signals of the scope, here d, which the
// initial procedure of p changes. The calls name p. A tool with no coverage of
// a program answers NOCOV, which is a valid answer, not an error; the maximum
// is the number of coverable items, or NOCOV or OVERFLOW, never ERROR.

program cov_prog;
  logic d = 0;

  initial begin
    #1 d = 1;
    #1 d = 0;
  end
endprogram

module test_coverage_control_program_scope;
  cov_prog p();

  initial begin
    #5;
    begin
      int check;
      int maximum;
      check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_HIER,
                                "test_coverage_control_program_scope.p");
      maximum = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER,
                                  "test_coverage_control_program_scope.p");
      $display("program scope check is OK, NOCOV or PARTIAL: %0d",
               check inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL});
      $display("program maximum is not ERROR: %0d", maximum != `SV_COV_ERROR);
    end
    $finish;
  end
endmodule
