/*
:name: test_vpi_coverage_instance_control
:description: vpi_control resets and stops the coverage of one instance without touching another instance (IEEE 1800-2023 Section 40.5.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.3 40.5.1 40.3.2.1 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_instance_control.c
:expected_stdout: @test_vpi_coverage_instance_control.expected
*/
// IEEE 1800-2023 §40.5.3: vpi_control with vpiCoverageReset or vpiCoverageStop
// and an instance handle controls the coverage of that instance as
// $coverage_control does (40.3.2.1). The task $vt_cov_ctl calls it with
// vpiToggleCoverage (40.5.1). A reset clears the coverage of the instance
// given and leaves the other instances as they were, so after the reset of u1
// its toggle coverage (40.3.2.3) is zero and that of u2 is unchanged; while u1
// is stopped its toggles do not count. This holds whether or not the tool
// collects toggle coverage, as NOCOV is zero.

module test_vpi_coverage_instance_control_leaf;
  logic [3:0] t = 0;
endmodule

module test_vpi_coverage_instance_control;
  test_vpi_coverage_instance_control_leaf u1();
  test_vpi_coverage_instance_control_leaf u2();

  int a2, b1, b2, c1;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

`define TOGGLE_OF(i) $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, i)

  initial begin
    #1 u1.t = 4'hf;
    u2.t = 4'hf;
    #1 u1.t = 4'h0;
    u2.t = 4'h0;
    #1 a2 = `TOGGLE_OF(u2);
    $vt_cov_ctl("reset", "test_vpi_coverage_instance_control.u1");
    b1 = `TOGGLE_OF(u1);
    b2 = `TOGGLE_OF(u2);
    $vt_cov_ctl("stop", "test_vpi_coverage_instance_control.u1");
    #1 u1.t = 4'hf;
    #1 u1.t = 4'h0;
    #1 c1 = `TOGGLE_OF(u1);
    $display("after vpiCoverageReset of u1, u1 is zero and u2 is unchanged: %s",
             yes_no(b1 == 0 && b2 == a2));
    $display("while u1 is stopped, its toggles do not raise its coverage: %s",
             yes_no(c1 == b1));
  end
endmodule
