/*
:name: test_vpi_mcd_flush
:description: vpi_mcd_flush returns 0 and writes the buffered output of a multichannel descriptor to its file, where the design can read it while the file is still open (IEEE 1800-2023 Section 38.25)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.25 38.27 38.28 38.24 21.3.1 21.3.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_flush.c
:expected_stdout: @test_vpi_mcd_flush.expected
*/
// IEEE 1800-2023 §38.25: vpi_mcd_flush flushes the output buffers of the files
// of a multichannel descriptor and returns 0 on success. $vt_write opens
// test_vpi_mcd_flush.txt with vpi_mcd_open (38.27), writes a line with
// vpi_mcd_printf (38.28) and flushes it, without closing the file. The design
// then opens the file for reading (21.3.1) and reads the line with $fgets
// (21.3.4.2), which works only because the line has been flushed. Finally
// $vt_close closes the file with vpi_mcd_close (38.24), which returns 0.

module test_vpi_mcd_flush;
  int fd;
  string line;

  initial begin
    $vt_write;
    fd = $fopen("test_vpi_mcd_flush.txt", "r");
    if (fd == 0) begin
      $display("cannot open the file");
    end else begin
      void'($fgets(line, fd));
      $display("read back: %s", line.substr(0, line.len() - 2));
      $fclose(fd);
    end
    $vt_close;
  end
endmodule
