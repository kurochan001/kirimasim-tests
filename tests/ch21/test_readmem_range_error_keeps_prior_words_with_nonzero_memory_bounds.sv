/*
:name: test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds
:description: A memory file address outside a requested range issues an error and leaves earlier writes intact
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*bad_window\.mem)(?=[^\n]*address)(?=[^\n]*(?:out of range|outside))[^\n]+
*/
module test_readmem_range_error_keeps_prior_words_with_nonzero_memory_bounds;
  logic [11:0] words[8:15];
  int file_handle;

  initial begin
    foreach (words[i]) words[i] = 12'heee;
    file_handle = $fopen("bad_window.mem", "w");
    if (!file_handle) $fatal(1, "cannot open fixture");
    $fdisplay(file_handle, "@a a31 b72 @f 135 @c c8e");
    $fclose(file_handle);
    $readmemh("bad_window.mem", words, 10, 13);
    $display("before=%h/%h remaining=%h/%h outside=%h",
             words[10], words[11], words[12], words[13], words[15]);
    $finish(0);
  end
endmodule
