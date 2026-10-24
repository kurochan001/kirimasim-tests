/*
:name: test_vpi_mcd_printf_channels
:description: vpi_mcd_open gives one free channel bit per file, never bit 0 or bit 31, until the 31 channels are used; vpi_mcd_printf and vpi_mcd_vprintf write C-formatted text once to every channel of the descriptor, the tool output included, return the number of characters, write nothing to a $fopen fd and return EOF for a closed channel; $fdisplay writes to a vpi_mcd_open descriptor (IEEE 1800-2023 Sections 38.28, 38.29 and 38.27)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.28 38.29 38.27 38.24 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_printf_channels.c
:expected_stdout: @test_vpi_mcd_printf_channels.expected
*/
// IEEE 1800-2023 §38.27: channel 1 (bit 0) of a multichannel descriptor is
// the output of the tool, and bit 31 marks an fd of $fopen, so vpi_mcd_open
// returns a descriptor with one other bit set, and 0 on error. §21.3.1 allows
// at most 31 channels, the tool output included. fm, opened by $fopen, takes
// one channel, so vpi_mcd_open opens 29 files and then fails. §38.28: bit k
// of the descriptor selects channel k+1, all selected channels are written,
// with the C fprintf format, and the number of characters is returned;
// $fopen mcds are accepted, an fd (MSB set) is never written, and an error
// gives EOF, here a write to a channel whose file is closed. §38.29:
// vpi_mcd_vprintf does the same with a started va_list. §38.27: descriptors
// of vpi_mcd_open and $fopen are shared by the system tasks and the VPI, so
// $fdisplay writes to the first file of vpi_mcd_open. The application writes
// two lines to the tool output, the 29 files and fm in one call each, closes
// its files with vpi_mcd_close (38.24), and reads every file back with the C
// library. The files are created in the current directory.

module test_vpi_mcd_printf_channels;
  integer fm, fd, vm;

  initial begin
    fm = $fopen("test_vpi_mcd_printf_channels_fm.txt");
    fd = $fopen("test_vpi_mcd_printf_channels_fd.txt", "w");
    $display("fd from $fopen has bit 31 set: %0d", fd[31]);
    vm = $vt_open_all(fm);
    $vt_write(fm, fd);
    $fdisplay(vm, "written by $fdisplay to a vpi_mcd_open descriptor");
    $vt_close_all;
    $fclose(fm);
    $fclose(fd);
    $vt_check;
  end
endmodule
