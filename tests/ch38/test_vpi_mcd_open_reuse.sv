/*
:name: test_vpi_mcd_open_reuse
:description: vpi_mcd_open returns the descriptor a file already has when vpi_mcd_open or $fopen opened it before, and 0 when the file cannot be opened; vpi_mcd_flush returns 0 for an open channel and nonzero for a channel with no file (IEEE 1800-2023 Sections 38.27 and 38.25)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.27 38.25 21.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_open_reuse.c
:expected_stdout: @test_vpi_mcd_open_reuse.expected
*/
// IEEE 1800-2023 §38.27: vpi_mcd_open returns 0 on an error, and for a file
// that a previous vpi_mcd_open or a $fopen of the design (21.3.1) has already
// opened it returns that descriptor. §38.25: vpi_mcd_flush takes a PLI_UINT32
// multichannel descriptor and returns a PLI_INT32, 0 if it succeeds and
// nonzero if it does not. The application opens a file twice by the same
// name, opens the file that fm of the design has open, and opens a file in a
// directory that does not exist. It then writes a line to the file and
// flushes it, and flushes a channel that no file uses (not 1, not a, not fm),
// which cannot succeed. The files are created in the current directory.
// Icarus Verilog 13.0 gives a new descriptor for a file that is already open
// and returns 0 when it flushes a channel with no file.

module test_vpi_mcd_open_reuse;
  integer fm;

  initial begin
    fm = $fopen("test_vpi_mcd_open_reuse_m.txt");
    $vt_open(fm);
    $fclose(fm);
  end
endmodule
