/*
:name: test_vpi_mcd_name_flush_fopen
:description: vpi_mcd_name gives the names of files that $fopen opened, as an mcd or as an fd, and NULL for a channel that is not open; vpi_mcd_vprintf writes to a $fopen file and to a vpi_mcd_open file, and one vpi_mcd_flush of both channels makes the lines readable while the files are open (IEEE 1800-2023 Sections 38.26, 38.25 and 38.29)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.26 38.25 38.29 38.27 38.24 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_name_flush_fopen.c
:expected_stdout: @test_vpi_mcd_name_flush_fopen.expected
*/
// IEEE 1800-2023 §38.26: vpi_mcd_name returns the name of the file of a
// channel descriptor, which can be an mcd or an fd that $fopen returned
// (21.3.1), and NULL on error, here for a channel that no file uses and for
// the fd after $fclose. §38.29: vpi_mcd_vprintf writes like vpi_mcd_printf
// with a started varargs list and returns the number of characters written.
// §38.25: vpi_mcd_flush flushes the files of all the channels of its mcd and
// returns 0 on success. $vt_files writes a line to the file of the $fopen mcd
// and one to a file it opens with vpi_mcd_open (38.27), and flushes both with
// one call; the design then reads both files while they are still open.
// $vt_closed closes the second file with vpi_mcd_close (38.24), which returns
// 0. The files are created in the current directory.

module test_vpi_mcd_name_flush_fopen;
  int mcd, fd, rd;
  string line;

  initial begin
    mcd = $fopen("test_vpi_mcd_name_flush_fopen_a.txt");
    fd = $fopen("test_vpi_mcd_name_flush_fopen_b.txt", "w");
    $vt_files(mcd, fd);
    rd = $fopen("test_vpi_mcd_name_flush_fopen_a.txt", "r");
    void'($fgets(line, rd));
    $fclose(rd);
    $write("read from a: %s", line);
    rd = $fopen("test_vpi_mcd_name_flush_fopen_c.txt", "r");
    void'($fgets(line, rd));
    $fclose(rd);
    $write("read from c: %s", line);
    $fclose(fd);
    $vt_closed(fd);
    $fclose(mcd);
  end
endmodule
