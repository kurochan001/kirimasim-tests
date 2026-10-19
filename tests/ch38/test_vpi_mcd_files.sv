/*
:name: test_vpi_mcd_files
:description: vpi_mcd_open opens a file and returns a multichannel descriptor, vpi_mcd_printf writes to it, and the file can be read back with $fopen and $fgets (IEEE 1800-2023 Section 38.27)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.27 38.28 38.26 38.24 21.3.1 21.3.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_files.c
:expected_stdout: @test_vpi_mcd_files.expected
*/
// IEEE 1800-2023 §38.27: vpi_mcd_open opens a file for writing and returns a
// multichannel descriptor; channel 1 is the output of the tool. §38.28:
// vpi_mcd_printf writes to every channel set in the descriptor, so writing to
// the descriptor ORed with 1 also prints the line. §38.26: vpi_mcd_name gives
// the file name, and §38.24: vpi_mcd_close closes it. The test then reads the
// file with $fopen and $fgets (21.3.1, 21.3.4.2). The file is created in the
// current directory.

module test_vpi_mcd_files;
  integer fd, k;
  reg [8*32-1:0] line;

  initial begin
    $vt_write_file("test_vpi_mcd_files.txt");
    fd = $fopen("test_vpi_mcd_files.txt", "r");
    while ($fgets(line, fd) != 0)
      $display("read: %0s", line);
    $fclose(fd);
  end
endmodule
