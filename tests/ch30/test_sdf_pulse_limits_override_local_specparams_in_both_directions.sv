/*
:name: test_sdf_pulse_limits_override_local_specparams_in_both_directions
:description: SDF annotation can lower or raise pulse limits set by local PATHPULSE specparams
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.3 30.7.2 32.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_pulse_limits_override_local_specparams_in_both_directions.expected
*/
`timescale 1ns/1ns
module default_pulse_cell(input a, output y);
  buf (y, a);
  specify
    (a => y) = 10;
  endspecify
endmodule

module local_pulse_cell(input a, output y);
  buf (y, a);
  specify
    specparam PATHPULSE$a$y = (4, 7);
    (a => y) = 10;
  endspecify
endmodule

module test_sdf_pulse_limits_override_local_specparams_in_both_directions;
  logic a = 0;
  wire default_y, local_y, low_y, high_y;
  string default_history = "", local_history = "", low_history = "", high_history = "";

  default_pulse_cell defaults(a, default_y);
  local_pulse_cell local_only(a, local_y);
  local_pulse_cell annotated_low(a, low_y);
  local_pulse_cell annotated_high(a, high_y);

  always @(default_y) if ($time >= 20)
    default_history = {default_history, $sformatf(" %0d:%b", $time, default_y)};
  always @(local_y) if ($time >= 20)
    local_history = {local_history, $sformatf(" %0d:%b", $time, local_y)};
  always @(low_y) if ($time >= 20)
    low_history = {low_history, $sformatf(" %0d:%b", $time, low_y)};
  always @(high_y) if ($time >= 20)
    high_history = {high_history, $sformatf(" %0d:%b", $time, high_y)};

  initial begin
    int fd;
    fd = $fopen("pulse_override.sdf", "w");
    if (!fd) $fatal(1, "cannot create SDF fixture");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "  (CELL (CELLTYPE \"local_pulse_cell\") (INSTANCE annotated_low)");
    $fdisplay(fd, "    (DELAY (ABSOLUTE (PATHPULSE a y (2) (5)))))");
    $fdisplay(fd, "  (CELL (CELLTYPE \"local_pulse_cell\") (INSTANCE annotated_high)");
    $fdisplay(fd, "    (DELAY (ABSOLUTE (PATHPULSEPERCENT a y (60) (90))))))");
    $fclose(fd);
    $sdf_annotate("pulse_override.sdf");

    #20 a = 1;
    #3 a = 0;
    #27 a = 1;
    #5 a = 0;
    #25 a = 1;
    #8 a = 0;
    #22 a = 1;
    #12 a = 0;
    #20;
    $display("default:%s", default_history);
    $display("local:%s", local_history);
    $display("lower:%s", low_history);
    $display("higher:%s", high_history);
  end
endmodule
