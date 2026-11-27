/*
:name: test_global_pulse_limit_sources
:description: Module path delays, local pulse limits, and SDF drive distinguishable waveforms
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7 30.7.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_global_pulse_limit_sources.expected
*/
`timescale 1ns/1ns

module global_pulse_fast(input a, output y);
  buf (y, a);
  specify
    (a => y) = 10;
  endspecify
endmodule

module global_pulse_asymmetric(input a, output y);
  buf (y, a);
  specify
    (a => y) = (12, 8);
  endspecify
endmodule

module global_pulse_local(input a, output y);
  buf (y, a);
  specify
    specparam PATHPULSE$a$y = (4, 7);
    (a => y) = 10;
  endspecify
endmodule

module test_global_pulse_limit_sources;
  logic a = 0;
  wire fast_y, asym_y, local_y, sdf_y;
  string fast_log = "", asym_log = "", local_log = "", sdf_log = "";

  global_pulse_fast fast(a, fast_y);
  global_pulse_asymmetric asym(a, asym_y);
  global_pulse_local local_limits(a, local_y);
  global_pulse_fast sdf_limits(a, sdf_y);

  always @(fast_y) if ($time >= 30) fast_log = {fast_log, $sformatf(" %0d:%b", $time, fast_y)};
  always @(asym_y) if ($time >= 30) asym_log = {asym_log, $sformatf(" %0d:%b", $time, asym_y)};
  always @(local_y) if ($time >= 30) local_log = {local_log, $sformatf(" %0d:%b", $time, local_y)};
  always @(sdf_y) if ($time >= 30) sdf_log = {sdf_log, $sformatf(" %0d:%b", $time, sdf_y)};

  task automatic pulse_at(time start_at, time width);
    #(start_at - $time) a = 1;
    #width a = 0;
  endtask

  initial begin
    int fd;
    if ($test$plusargs("invocation_projection")) $sdf_annotate("invocation.sdf");
    fd = $fopen("individual_pulse.sdf", "w");
    if (!fd) $fatal(1, "cannot create pulse annotation");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "(CELL (CELLTYPE \"global_pulse_fast\") (INSTANCE sdf_limits)");
    $fdisplay(fd, "(DELAY (ABSOLUTE (PATHPULSE a y (1) (5))))))");
    $fclose(fd);
    $sdf_annotate("individual_pulse.sdf");

    pulse_at(30, 3);
    pulse_at(60, 5);
    pulse_at(90, 6);
    pulse_at(120, 9);
    pulse_at(150, 10);
    pulse_at(180, 15);
    #45 a = 1;  // establish a stable high value at time 240
    #30 a = 0;
    #5 a = 1;
    #45;
    $display("fast:%s", fast_log);
    $display("asym:%s", asym_log);
    $display("local:%s", local_log);
    $display("sdf:%s", sdf_log);
    $finish(0);
  end
endmodule
