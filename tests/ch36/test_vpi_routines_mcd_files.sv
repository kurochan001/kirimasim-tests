/*
:name: test_vpi_routines_mcd_files
:description: the file routines of Table 36-9 do what it lists: vpi_mcd_open opens files for writing as channels of a multichannel descriptor, vpi_mcd_name gives the name of a file, vpi_mcd_printf and vpi_mcd_vprintf write to one or more files, vpi_mcd_flush flushes them and vpi_mcd_close closes them, and the design then reads what was written (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.27 38.26 38.28 38.29 38.25 38.24 21.3.1 21.3.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_mcd_files.c
:expected_stdout: @test_vpi_routines_mcd_files.expected
*/
// IEEE 1800-2023 §36.11, Table 36-9: vpi_mcd_open opens a file for writing,
// vpi_mcd_close closes one or more files, vpi_mcd_printf writes to one or
// more files, vpi_mcd_vprintf does so with varargs, vpi_mcd_flush flushes the
// buffer of an mcd, and vpi_mcd_name gives the name of an open file.
// §38.27: vpi_mcd_open returns a multichannel descriptor with one bit set,
// never channel 1 (bit 0, the output of the tool) or the MSB (an fd of
// $fopen). §38.26: vpi_mcd_name gives the name of the file of a channel.
// §38.28, §38.29: the routines write, as C fprintf does, to every channel
// whose bit is set in the mcd, and return the number of characters written.
// §38.25: vpi_mcd_flush returns 0 on success. §38.24: vpi_mcd_close closes
// every channel of the mcd and returns 0 on success.
// At the start of simulation the application opens two files, prints the
// name of the first, writes one line to both at once with vpi_mcd_printf, one
// line to the first with vpi_mcd_printf and one to the second with
// vpi_mcd_vprintf, flushes, closes both, and prints the results; the count
// is printed only for the writes to a single file. At time 1 the design
// reads the two files with $fopen and $fgets (21.3.1, 21.3.4.2) and prints
// their lines. The files are created in the directory where the test runs.
// Under Verilator 5.052 the descriptors from vpi_mcd_open fail the first two
// checks, and vpi_mcd_name is not supported.

module test_vpi_routines_mcd_files;
  int fd;
  string line;

  task automatic show(string name);
    fd = $fopen(name, "r");
    if (fd == 0) begin
      $display("%s: cannot be read", name);
      return;
    end
    while ($fgets(line, fd) != 0)
      $write("%s: %s", name, line);
    $fclose(fd);
  endtask

  initial begin
    #1;
    show("test_vpi_routines_mcd_files_a.txt");
    show("test_vpi_routines_mcd_files_b.txt");
  end
endmodule
