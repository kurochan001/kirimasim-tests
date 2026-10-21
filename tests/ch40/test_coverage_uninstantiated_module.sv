/*
:name: test_coverage_uninstantiated_module
:description: Coverage of a module definition with no instances is NOCOV, not an error (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_coverage_uninstantiated_module
:expected_stdout: @test_coverage_uninstantiated_module.expected
*/
// IEEE 1800-2023 §40.3.2.1, Table 40-2: with SV_COV_MODULE the scope is a
// module definition, and its coverage is the sum over all its instances. The
// module cov_unused has no instance, because the top module is named and does
// not instantiate it (§23.3.1), so there are no coverable items: a check and
// the maximum and current values are SV_COV_NOCOV, not SV_COV_ERROR. The
// design has toggle coverage in the top module, so a tool that collects it has
// coverage of another module to compare with.

module cov_unused(input logic d, output logic q);
  always @(d) q = ~d;
endmodule

module test_coverage_uninstantiated_module;
  logic d = 0;

  initial begin
    #1 d = 1;
    begin
      int check;
      int maximum;
      int current;
      check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_MODULE,
                                "cov_unused");
      maximum = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_MODULE, "cov_unused");
      current = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, "cov_unused");
      $display("uninstantiated check is NOCOV: %0d", check == `SV_COV_NOCOV);
      $display("uninstantiated maximum is NOCOV: %0d", maximum == `SV_COV_NOCOV);
      $display("uninstantiated current is NOCOV: %0d", current == `SV_COV_NOCOV);
    end
    $finish;
  end
endmodule
