/*
:name: test_vpi_mcd_name_buffer
:description: vpi_mcd_name returns the name of a file of a channel in one buffer that each call overwrites, so a saved pointer shows the name of the later call (IEEE 1800-2023 Section 38.26)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_mcd_name_buffer.c
:expected_stdout: @test_vpi_mcd_name_buffer.expected
*/
// IEEE 1800-2023 §38.26: vpi_mcd_name returns the name of the file that a
// single-channel descriptor represents, in a temporary buffer that the routine
// overwrites on subsequent calls, so an application that needs the string
// copies it. The application opens two files with vpi_mcd_open, takes the name
// of the first and then the name of the second, and checks that the two
// returned pointers are equal and that the first pointer now holds the second
// name. It then asks for the name of the first file again, checks that it is
// the first name, closes a file and checks that the name of the closed channel
// is NULL. The release 13.0 of Icarus Verilog returns a different buffer for
// each call of vpi_mcd_name, so the expected output follows the clause alone.

module test_vpi_mcd_name_buffer;
  initial begin
    #1 $vt_name;
    $finish;
  end
endmodule
