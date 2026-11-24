/*
:name: test_sdf_transition_pulse_values_override_local_specparam
:description: Pulse limits in SDF transition values take precedence over a path-specific PATHPULSE specparam
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.3 30.7 32.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_transition_pulse_values_override_local_specparam.expected
*/
`timescale 1ns/1ns

module transition_limit_cell(input a, output y);
  buf (y, a);
  specify
    specparam PATHPULSE$a$y = (5, 7);
    (a => y) = 10;
  endspecify
endmodule

module test_sdf_transition_pulse_values_override_local_specparam;
  logic a = 0;
  wire local_y, annotated_y;
  string local_log = "", annotated_log = "";
  integer fd;

  transition_limit_cell local_only(a, local_y);
  transition_limit_cell annotated(a, annotated_y);

  always @(local_y) if ($time >= 20)
    local_log = {local_log, $sformatf(" %0d:%b", $time, local_y)};
  always @(annotated_y) if ($time >= 20)
    annotated_log = {annotated_log, $sformatf(" %0d:%b", $time, annotated_y)};

  initial begin
    fd = $fopen("transition_priority.sdf", "w");
    if (!fd) $fatal(1, "cannot create SDF fixture");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "  (CELL (CELLTYPE \"transition_limit_cell\") (INSTANCE annotated)");
    $fdisplay(fd, "    (DELAY (ABSOLUTE");
    $fdisplay(fd, "      (IOPATH a y ((10) (8) (9)) ((10) (2) (4)))))))");
    $fclose(fd);
    $sdf_annotate("transition_priority.sdf");

    // With the annotated fall limits, a positive width-3 pulse becomes x
    // and a positive width-6 pulse passes.
    #20 a = 1;
    #3 a = 0;
    #17 a = 1;
    #6 a = 0;
    #14 a = 1;
    // A negative width-7 pulse passes the local limits but is rejected
    // by the annotated rise limits.
    #20 a = 0;
    #7 a = 1;
    #20;
    $display("local:%s", local_log);
    $display("annotated:%s", annotated_log);
  end
endmodule
