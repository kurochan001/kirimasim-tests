/*
:name: test_vpi_mcd_close_channels
:description: vpi_mcd_close closes every channel of its descriptor in one call and returns 0, also closes an mcd and an fd that $fopen opened, never closes channel 1 (the tool output) and then returns the mcd of that unclosed channel (IEEE 1800-2023 Section 38.24)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.24 38.27 38.28 38.26 21.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_close_channels.c
:expected_stdout: @test_vpi_mcd_close_channels.expected
*/
// IEEE 1800-2023 §38.24: vpi_mcd_close takes a PLI_UINT32 multichannel
// descriptor, closes the files of all its channels at once and returns the
// PLI_UINT32 0 on success; on an error it returns the mcd of the channels it
// did not close. It also closes descriptors that $fopen returned (21.3.1),
// mcds and fds alike. Descriptor 1, the output of the tool and the log file,
// cannot be closed by it. The application opens a, b and c with
// vpi_mcd_open (38.27) and writes a line to all three (38.28); closes a and b
// with one call; writes a second line to all three, which only c can take;
// closes 1|c, which leaves channel 1 open, so the call returns 1 and a line
// to channel 1 still reaches the tool output, while a line to c after it
// reaches no file. It then closes the mcd fm and the fd fd of the design.
// Last, it reads the five files with the C library: each holds what was
// written before it was closed, and vpi_mcd_name (38.26) gives NULL for the
// closed fm and fd. The files are created in the current directory.

module test_vpi_mcd_close_channels;
  integer fm, fd;

  initial begin
    fm = $fopen("test_vpi_mcd_close_channels_fm.txt");
    fd = $fopen("test_vpi_mcd_close_channels_fd.txt", "w");
    $fdisplay(fm, "fm: written by $fdisplay");
    $fdisplay(fd, "fd: written by $fdisplay");
    $vt_close(fm, fd);
    $vt_check(fm, fd);
  end
endmodule
