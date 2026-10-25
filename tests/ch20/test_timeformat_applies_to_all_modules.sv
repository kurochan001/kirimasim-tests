/*
:name: test_timeformat_applies_to_all_modules
:description: a $timeformat call in one module sets the unit, precision, suffix and minimum width of %t for $display, $fdisplay and $sformatf in every module, whatever its time unit, until the next $timeformat call (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.3 21.2.1.1 21.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeformat_applies_to_all_modules.expected
*/
// IEEE 1800-2023 §20.4.3: $timeformat sets the time unit, the number of
// fractional digits, the suffix and the minimum field width of every %t in
// the design, for the display and file output tasks, until $timeformat is
// called again. §21.2.1.1: so %t shows the times of modules with different
// time units in one uniform format.
// The top module (1 ns) calls $timeformat(-9, 3, " ns", 12) at time 0 and
// $timeformat(-12, 0, "ps", 8) at 10 ns. A module with the unit 1 ps and
// one with 1 us print their $realtime with %t at 2.5 ns and 4 ns (before the
// second call) and at 12.345 ns and 20 ns (after it), to standard output
// and, for the 1 us module, also with $fdisplay to a file. The top module
// formats its own time with $sformatf at 30 ns and then prints the lines
// of the file.

`timescale 1ns/1ps

module test_timeformat_applies_to_all_modules;
  int fd;
  string line;

  tf_all_ps u_ps();
  tf_all_us u_us();

  initial begin
    fd = $fopen("test_timeformat_applies_to_all_modules.txt", "w");
    $timeformat(-9, 3, " ns", 12);
    #10;
    $timeformat(-12, 0, "ps", 8);
    #20;
    line = $sformatf("top [%t]", $realtime);
    $display("%s", line);
    $fclose(fd);
    fd = $fopen("test_timeformat_applies_to_all_modules.txt", "r");
    while ($fgets(line, fd) != 0) $write("file: %s", line);
    $fclose(fd);
  end
endmodule

`timescale 1ps/1ps

module tf_all_ps;
  initial begin
    #2500;
    $display("ps [%t]", $realtime);
    #9845;
    $display("ps [%t]", $realtime);
  end
endmodule

`timescale 1us/1ns

module tf_all_us;
  initial begin
    #0.004;
    $display("us [%t]", $realtime);
    $fdisplay(test_timeformat_applies_to_all_modules.fd, "us [%t]", $realtime);
    #0.016;
    $display("us [%t]", $realtime);
    $fdisplay(test_timeformat_applies_to_all_modules.fd, "us [%t]", $realtime);
  end
endmodule
