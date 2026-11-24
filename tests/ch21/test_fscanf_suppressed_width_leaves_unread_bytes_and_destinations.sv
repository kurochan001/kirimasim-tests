/*
:name: test_fscanf_suppressed_width_leaves_unread_bytes_and_destinations
:description: A width-limited suppressed file conversion advances the stream without assigning
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fscanf_suppressed_width_leaves_unread_bytes_and_destinations.expected
*/
module test_fscanf_suppressed_width_leaves_unread_bytes_and_destinations;
  int fd, assignments, word, unused;
  byte next_byte;

  initial begin
    fd = $fopen("scan_width.txt", "w+");
    if (fd == 0)
      $fatal(1, "could not create scan input");
    $fwrite(fd, "12345:7f/Q9");
    $rewind(fd);
    unused = 63;
    assignments = $fscanf(fd, "%*2d%d:%h/%*1s", word, next_byte, unused);
    $display("count=%0d retained digits=%0d hex=%h excess=%0d",
             assignments, word, next_byte, unused);
    $display("next character=%c", $fgetc(fd));
    $fclose(fd);
  end
endmodule
