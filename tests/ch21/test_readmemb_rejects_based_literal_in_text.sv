/*
:name: test_readmemb_rejects_based_literal_in_text
:description: A memory text file does not accept a sized and based source literal
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemb_rejects_based_literal_in_text.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:readmem|bad_binary\.mem))(?=[^\n]*(?:invalid|illegal|malformed|unexpected|syntax|digit|not part of a number))[^\n]+
*/
module test_readmemb_rejects_based_literal_in_text;
  logic [7:0] words [0:2];
  int fd;

  initial begin
    fd = $fopen("bad_binary.mem", "w");
    if (fd == 0)
      $fatal(1, "could not create memory input");
    $fwrite(fd, "01001010 8'b01010101 01001010\n");
    $fclose(fd);
    $display("reading a sized source literal");
    $readmemb("bad_binary.mem", words);
  end
endmodule
