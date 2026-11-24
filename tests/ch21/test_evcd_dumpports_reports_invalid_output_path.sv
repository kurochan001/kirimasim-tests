/*
:name: test_evcd_dumpports_reports_invalid_output_path
:description: A dumpports file creation failure names the inaccessible path and a second valid file is written
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_dumpports_reports_invalid_output_path.expected
:expected_stderr_regex: (?im:^[^\n]*(?:error|warn(?:ing)?)[^\n]*\$dumpports[^\n]*(?:open|creat|writ)[^\n]*regular_file_parent/invalid\.evcd)
*/
`timescale 1ns/1ns

module evcd_file_write_target(input wire in_value, output wire out_value);
  assign out_value = in_value;
endmodule

module test_evcd_dumpports_reports_invalid_output_path;
  logic stimulus = 0;
  wire invalid_path_value, valid_path_value;
  evcd_file_write_target invalid_target(stimulus, invalid_path_value);
  evcd_file_write_target valid_target(stimulus, valid_path_value);
  integer obstruction, written, status, port_width;
  time dump_time;
  string line;
  bit saw_port, saw_change;

  initial begin
    obstruction = $fopen("regular_file_parent", "w");
    if (!obstruction) $fatal(1, "cannot create the file that blocks the dump path");
    $fclose(obstruction);
    $dumpports(invalid_target, "regular_file_parent/invalid.evcd");
    $dumpports(valid_target, "valid_output.evcd");
    #1 stimulus = 1;
    #1 $dumpportsflush("valid_output.evcd");
    written = $fopen("valid_output.evcd", "r");
    if (!written) $fatal(1, "the valid EVCD file could not be read");
    line = "";
    status = $fgets(line, written);
    while (status > 0) begin
      if (line.len() > 0) begin
        if ($sscanf(line, "$var port %d", port_width) == 1 && port_width == 1) saw_port = 1;
        if (line[0] == "#") begin
          if ($sscanf(line, "#%d", dump_time) != 1)
            $fatal(1, "cannot read EVCD time marker");
        end
        if (line[0] == "p" && dump_time == 1) saw_change = 1;
      end
      line = "";
      status = $fgets(line, written);
    end
    $fclose(written);
    $display("written port=%b change=%b", saw_port, saw_change);
  end
endmodule
