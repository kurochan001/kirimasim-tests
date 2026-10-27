/*
:name: test_ch21_extra_readmem_address_range_error
:description: An @ address in the memory file that lies outside the start and finish range of $readmemh terminates the load, so the words before it are loaded and the words after it are not (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch21_extra_readmem_address_range_error.expected
*/
// IEEE 1800-2023 §21.4: "When addressing information is specified both in the
// system task and in the data file, the addresses in the data file shall be
// within the address range specified by the system task arguments; otherwise,
// an error message is issued, and the load operation is terminated." The
// file holds aa, then @9, then bb; the task selects addresses 0 through 7.
// The first word is loaded at address 0, the address 9 is outside the range,
// and the load ends before bb, so every other word keeps the initial ee.
// The test prints the words but not the text of the error message, whose form
// the standard leaves to the tool.
//
// Icarus Verilog 13.0 issues the error and leaves the words as shown.
// The 5.052 release of Verilator stops the run at that file address with an
// error and no output, so it has no expected output for this test.

module test_ch21_extra_readmem_address_range_error;
  localparam string FILE = "test_ch21_extra_readmem_address_range_error.mem";
  logic [7:0] mem[0:7];
  int fd;

  initial begin
    foreach (mem[i]) mem[i] = 8'hee;
    fd = $fopen(FILE, "w");
    $fdisplay(fd, "aa @9 bb");
    $fclose(fd);
    $readmemh(FILE, mem, 0, 7);
    foreach (mem[i]) $display("mem[%0d]=%h", i, mem[i]);
  end
endmodule
