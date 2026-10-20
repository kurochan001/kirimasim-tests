/*
:name: test_vpi_vprintf_flush_mcd
:description: vpi_vprintf and vpi_mcd_vprintf write a started varargs list like vpi_printf and vpi_mcd_printf, returning the number of characters, and vpi_flush returns 0 on success (IEEE 1800-2023 Section 38.41)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.41 38.29 38.5 38.28 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_vprintf_flush_mcd.c
:expected_stdout: @test_vpi_vprintf_flush_mcd.expected
*/
// IEEE 1800-2023 §38.41: vpi_vprintf writes to the output channel like
// vpi_printf, with a varargs list that is already started, and returns the
// number of characters written. §38.29: vpi_mcd_vprintf does the same for the
// files of a multichannel descriptor, here one that $fopen opened (21.3.1,
// 38.28). §38.5: vpi_flush flushes the output buffers and returns 0 on
// success. The test reads the file back after closing it.

module test_vpi_vprintf_flush_mcd;
  int mcd, fd, n;
  string line;

  initial begin
    $vt_say;
    mcd = $fopen("test_vpi_vprintf_flush_mcd.txt");
    $vt_write(mcd);
    $fclose(mcd);
    fd = $fopen("test_vpi_vprintf_flush_mcd.txt", "r");
    n = $fgets(line, fd);
    $fclose(fd);
    $write("file: %s", line);
  end
endmodule
