/*
:name: test_coverage_control_interface_scope
:description: The scope of $coverage_control and $coverage_get_max may be an interface instance, whose coverage the calls report (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.2.2 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_interface_scope.expected
*/
// IEEE 1800-2023 §40.3.2.1: the scope argument of $coverage_control names a
// module, interface, program, package or $root; with SV_COV_HIER it is a
// hierarchical name. §40.2.2: toggle coverage counts the signals of the scope.
// The interface cov_if toggles d at every rising edge of clk, and the calls
// name its instance u. A tool that has no interface coverage answers NOCOV,
// which is still a valid answer, not an error. The maximum is the number of
// coverable items, or NOCOV or OVERFLOW, never ERROR.

interface cov_if(input logic clk);
  logic d = 0;
  always @(posedge clk) d <= ~d;
endinterface

module test_coverage_control_interface_scope;
  logic clk = 0;

  cov_if u(.clk(clk));

  always #5 clk = ~clk;

  initial begin
    #12;
    begin
      int check;
      int maximum;
      check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_HIER,
                                "test_coverage_control_interface_scope.u");
      maximum = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER,
                                  "test_coverage_control_interface_scope.u");
      $display("interface scope check is OK, NOCOV or PARTIAL: %0d",
               check inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL});
      $display("interface maximum is not ERROR: %0d", maximum != `SV_COV_ERROR);
    end
    $finish;
  end
endmodule
