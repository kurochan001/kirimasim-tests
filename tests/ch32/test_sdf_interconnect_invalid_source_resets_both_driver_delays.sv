/*
:name: test_sdf_interconnect_invalid_source_resets_both_driver_delays
:description: A missing or disconnected SDF source replaces earlier delays for all drivers at only its load and permits later per-source overrides
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_invalid_source_resets_both_driver_delays.expected
:expected_stderr_regex: \A(?=[\s\S]*(?im:^[^\n]*warn[^\n]*absent_source[^\n]*missing_load))(?=[\s\S]*(?im:^[^\n]*warn[^\n]*isolated_source[^\n]*disconnected_load))
*/
`timescale 1ns/1ns

module fallback_driver(input value, enable, output pin);
  bufif1 (pin, value, enable);
endmodule

module fallback_receiver(input pin, output value);
  assign value = pin;
endmodule

module test_sdf_interconnect_invalid_source_resets_both_driver_delays;
  logic drive_a = 0, drive_b = 0, drive_elsewhere = 0;
  wire net_with_two_sources, unrelated_net;
  wire base_out, missing_out, disconnected_out;
  string base_log = "", missing_log = "", disconnected_log = "";

  fallback_driver source_a(1'b1, drive_a, net_with_two_sources);
  fallback_driver source_b(1'b0, drive_b, net_with_two_sources);
  fallback_driver isolated_source(1'b1, drive_elsewhere, unrelated_net);
  fallback_receiver base_load(net_with_two_sources, base_out);
  fallback_receiver missing_load(net_with_two_sources, missing_out);
  fallback_receiver disconnected_load(net_with_two_sources, disconnected_out);

  always @(base_load.pin) if ($time >= 20)
    base_log = {base_log, $sformatf(" %0d:%b", $time, base_load.pin)};
  always @(missing_load.pin) if ($time >= 20)
    missing_log = {missing_log, $sformatf(" %0d:%b", $time, missing_load.pin)};
  always @(disconnected_load.pin) if ($time >= 20)
    disconnected_log = {disconnected_log, $sformatf(" %0d:%b", $time, disconnected_load.pin)};

  integer fd;
  initial begin
    fd = $fopen("fallback.sdf", "w");
    if (!fd) $fatal(1, "cannot create SDF fixture");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "  (CELL (CELLTYPE \"%m\")");
    $fdisplay(fd, "    (INSTANCE) (DELAY (ABSOLUTE");
    $fdisplay(fd, "    (INTERCONNECT source_a.pin base_load.pin (2))");
    $fdisplay(fd, "    (INTERCONNECT source_b.pin base_load.pin (4))");
    $fdisplay(fd, "    (INTERCONNECT source_a.pin missing_load.pin (2))");
    $fdisplay(fd, "    (INTERCONNECT source_b.pin missing_load.pin (4))");
    $fdisplay(fd, "    (INTERCONNECT absent_source.pin missing_load.pin (7))");
    $fdisplay(fd, "    (INTERCONNECT source_b.pin missing_load.pin (3))");
    $fdisplay(fd, "    (INTERCONNECT source_a.pin disconnected_load.pin (2))");
    $fdisplay(fd, "    (INTERCONNECT source_b.pin disconnected_load.pin (4))");
    $fdisplay(fd, "    (INTERCONNECT isolated_source.pin disconnected_load.pin (9))");
    $fdisplay(fd, "    (INTERCONNECT source_a.pin disconnected_load.pin (3))");
    $fdisplay(fd, "  ))))");
    $fclose(fd);
    $sdf_annotate("fallback.sdf");

    #20 drive_elsewhere = 1;
    #20 drive_elsewhere = 0;
    #20 drive_a = 1;
    #20 drive_a = 0;
    #20 drive_b = 1;
    #20 drive_b = 0;
    #20;
    $display("base:%s", base_log);
    $display("missing:%s", missing_log);
    $display("disconnected:%s", disconnected_log);
  end
endmodule
