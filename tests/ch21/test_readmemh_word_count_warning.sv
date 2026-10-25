/*
:name: test_readmemh_word_count_warning
:description: When $readmemh is given a start and a finish address and the file, which has no @ addresses, holds fewer words than that range, the tool warns, loads the words it has from the start address and leaves the other words of the range unchanged (IEEE 1800-2023 Section 21.4)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_readmemh_word_count_warning.expected
:expected_stderr_regex: (?i:\bwarn(?:ing)?\b|%Warning-)
*/
// IEEE 1800-2023 §21.4: a warning shall be issued if the number of words in
// the file differs from the number of words from the start to the finish
// address and the file has no address specifications; the words of the file
// are then loaded from the start address and the other addresses are not
// changed. The range 5 down to 2 has four words and the file two, so mem[5]
// and mem[4] are loaded and mem[3] and mem[2] keep ee. The test checks the
// messages for a warning, but not its wording. The file is created in the
// current directory. The 5.052 release of Verilator loads the two words upward
// from address 5 and prints no warning.

module test_readmemh_word_count_warning;
  logic [7:0] mem [0:7];
  int fd;

  initial begin
    foreach (mem[i]) mem[i] = 8'hee;
    fd = $fopen("test_readmemh_word_count_warning.mem", "w");
    $fdisplay(fd, "11 22");
    $fclose(fd);
    $readmemh("test_readmemh_word_count_warning.mem", mem, 5, 2);
    $display("mem[0..7] = %h %h %h %h %h %h %h %h", mem[0], mem[1], mem[2], mem[3], mem[4],
             mem[5], mem[6], mem[7]);
  end
endmodule
