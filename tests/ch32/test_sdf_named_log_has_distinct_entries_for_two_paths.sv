/*
:name: test_sdf_named_log_has_distinct_entries_for_two_paths
:description: A named SDF annotation log contains distinct entries for the two paths it updates
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_named_log_has_distinct_entries_for_two_paths.expected
*/
`timescale 1ns/1ns
module individually_logged_cell(input wire source, output wire logged_first, logged_second);
  assign logged_first = source;
  assign logged_second = source;
  specify
    (source => logged_first) = 1;
    (source => logged_second) = 1;
  endspecify
endmodule

module test_sdf_named_log_has_distinct_entries_for_two_paths;
  bit source;
  wire first, second;
  time first_time, second_time;
  individually_logged_cell subject(source, first, second);

  function automatic bit contains_text(string line, string needle);
    for (int start = 0; start + needle.len() <= line.len(); start++)
      if (line.substr(start, start + needle.len() - 1) == needle)
        return 1;
    return 0;
  endfunction

  function automatic bit entries_are_distinct(string filename);
    int fd, row_count, first_row, second_row;
    string line;
    fd = $fopen(filename, "r");
    if (fd == 0)
      return 0;
    while ($fgets(line, fd) != 0) begin
      row_count++;
      if (contains_text(line, "logged_first"))
        first_row = row_count;
      if (contains_text(line, "logged_second"))
        second_row = row_count;
    end
    $fclose(fd);
    return first_row > 0 && second_row > 0 && first_row != second_row;
  endfunction

  always @(posedge first) first_time = $time;
  always @(posedge second) second_time = $time;

  initial begin
    int fd;
    fd = $fopen("annotation.sdf", "w");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "(CELL (CELLTYPE \"individually_logged_cell\") (INSTANCE subject)");
    $fdisplay(fd, "(DELAY (ABSOLUTE (IOPATH source logged_first (4))");
    $fdisplay(fd, "                 (IOPATH source logged_second (9))))))");
    $fclose(fd);
    $sdf_annotate("annotation.sdf", , , "named_annotation.log");
    #20 source = 1;
    #12;
    $display("annotated delays=%0d/%0d", first_time - 20, second_time - 20);
    $display("distinct log entries=%0d", entries_are_distinct("named_annotation.log"));
  end
endmodule
