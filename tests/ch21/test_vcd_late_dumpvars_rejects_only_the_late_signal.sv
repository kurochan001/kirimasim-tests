/*
:name: test_vcd_late_dumpvars_rejects_only_the_late_signal
:description: A dumpvars call at the next time leaves an established two-signal selection intact
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_late_dumpvars_rejects_only_the_late_signal.expected
:expected_stderr_regex: (?im)^(?=[^\n]*(?:warning|error))(?=[^\n]*\$dumpvars)(?=[^\n]*(?:already|ignored|time|different))[^\n]+
:expected_stdout_icarus: @test_vcd_late_dumpvars_rejects_only_the_late_signal.icarus.expected
*/
`timescale 1ns/1ns
module test_vcd_late_dumpvars_rejects_only_the_late_signal;
  bit first_pin, anchor_pin, late_pin;

  initial begin
    int fd, size;
    bit first_found, anchor_found, late_found;
    string word, kind, code, signal_name;
    $dumpfile("late_time.vcd");
    #3;
    $dumpvars(0, first_pin);
    $dumpvars(0, anchor_pin);
    #1 $dumpvars(0, late_pin);
    #1;
    first_pin = 1;
    anchor_pin = 1;
    late_pin = 1;
    #1 $dumpflush;
    fd = $fopen("late_time.vcd", "r");
    if (fd == 0)
      $fatal(1, "waveform file could not be read");
    while ($fscanf(fd, "%s", word) == 1 && word != "$enddefinitions") begin
      if (word == "$var" && $fscanf(fd, "%s %d %s %s", kind, size, code, signal_name) == 4) begin
        first_found |= signal_name == "first_pin";
        anchor_found |= signal_name == "anchor_pin";
        late_found |= signal_name == "late_pin";
      end
    end
    $fclose(fd);
    $display("first=%0d anchor=%0d late=%0d", first_found, anchor_found, late_found);
  end
endmodule
