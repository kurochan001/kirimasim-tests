/*
:name: test_vcd_dumpvars_reports_late_variable_selection
:description: A late dumpvars call is diagnosed and does not add the requested variable to an active VCD
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.1.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_dumpvars_reports_late_variable_selection.expected
:expected_stdout_icarus: @test_vcd_dumpvars_reports_late_variable_selection.icarus.expected
:expected_stderr_regex: (?im)^[^\n]*(?:warning|error)[^\n]*\$dumpvars[^\n]*(?:already|ignored|time)
*/
`timescale 1ns/1ns
module test_vcd_dumpvars_reports_late_variable_selection;
  reg first_signal = 0, second_signal = 0;

  initial begin
    int file_handle, size, first_count, second_count;
    string line, keyword, value_type, code, name;
    $dumpfile("late_selection.vcd");
    $dumpvars(0, first_signal);
    #1 first_signal = 1;
    #1 $dumpvars(0, second_signal);
    #1 second_signal = 1;
    #1 $dumpflush;
    file_handle = $fopen("late_selection.vcd", "r");
    if (!file_handle) $fatal(1, "cannot open late_selection.vcd");
    while ($fgets(line, file_handle) != 0) begin
      if ($sscanf(line, "%s %s %d %s %s", keyword, value_type, size, code, name) == 5
          && keyword == "$var") begin
        first_count += name == "first_signal";
        second_count += name == "second_signal";
      end
    end
    $fclose(file_handle);
    $display("first=%0d late=%0d", first_count, second_count);
  end
endmodule
