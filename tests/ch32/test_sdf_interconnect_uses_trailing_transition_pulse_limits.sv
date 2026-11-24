/*
:name: test_sdf_interconnect_uses_trailing_transition_pulse_limits
:description: Direction-specific SDF interconnect pulse limits apply the trailing transition thresholds to both pulse polarities
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 30.7 32.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_uses_trailing_transition_pulse_limits.expected
*/
`timescale 1ns/1ns

module interconnect_pulse_source(input a, output y);
  buf (y, a);
endmodule

module interconnect_pulse_load(input a, output y);
  assign y = a;
endmodule

module test_sdf_interconnect_uses_trailing_transition_pulse_limits;
  logic a = 0;
  wire connection, observed, default_observed;
  string history = "", default_history = "";
  integer fd;
  interconnect_pulse_source s(a, connection);
  interconnect_pulse_load l(connection, observed);
  interconnect_pulse_load baseline(connection, default_observed);

  always @(l.a) if ($time >= 20)
    history = {history, $sformatf(" %0d:%b", $time, l.a)};
  always @(baseline.a) if ($time >= 20)
    default_history = {default_history, $sformatf(" %0d:%b", $time, baseline.a)};

  initial begin
    fd = $fopen("interconnect_pulse.sdf", "w");
    if (!fd) $fatal(1, "cannot create SDF fixture");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "  (CELL (CELLTYPE \"%m\")");
    $fdisplay(fd, "    (INSTANCE) (DELAY (ABSOLUTE");
    $fdisplay(fd, "    (INTERCONNECT s.y baseline.a (10) (10))");
    $fdisplay(fd, "    (INTERCONNECT s.y l.a ((10) (2) (4)) ((10) (6) (8)))");
    $fdisplay(fd, "  ))))");
    $fclose(fd);
    $sdf_annotate("interconnect_pulse.sdf");

    // High width 5 is below fall reject 6.
    #20 a = 1;
    #5 a = 0;
    // High width 7 passes reject 6 but is below fall error 8.
    #15 a = 1;
    #7 a = 0;
    // High width 8 reaches the fall error limit.
    #13 a = 1;
    #8 a = 0;
    #12 a = 1;
    // Low width 1 is below rise reject 2.
    #20 a = 0;
    #1 a = 1;
    // Low width 3 becomes x at rise limits 2 and 4.
    #19 a = 0;
    #3 a = 1;
    // Low width 4 reaches the rise error limit.
    #17 a = 0;
    #4 a = 1;
    #20;
    $display("limits:%s", history);
    $display("default:%s", default_history);
  end
endmodule
