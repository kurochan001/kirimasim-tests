/*
:name: test_readmemb_honors_multiple_address_tokens_on_one_line
:description: Binary memory files honor every hexadecimal address token with either horizontal whitespace or line breaks
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemb_honors_multiple_address_tokens_on_one_line.expected
*/
module test_readmemb_honors_multiple_address_tokens_on_one_line;
  logic [7:0] inline_memory[0:15], multiline_memory[0:15];
  int fd;

  initial begin
    foreach (inline_memory[i]) inline_memory[i] = 8'hee;
    foreach (multiline_memory[i]) multiline_memory[i] = 8'hee;

    fd = $fopen("inline_addresses.mem", "w");
    if (!fd) $fatal(1, "cannot create single-line memory fixture");
    $fdisplay(fd, "@a 10101010\t@B 10111011   @2 00100010");
    $fclose(fd);

    fd = $fopen("multiline_addresses.mem", "w");
    if (!fd) $fatal(1, "cannot create multiline memory fixture");
    $fdisplay(fd, "@a 10101010");
    $fdisplay(fd, "@B 10111011");
    $fdisplay(fd, "@2 00100010");
    $fclose(fd);

    $readmemb("inline_addresses.mem", inline_memory, 1, 14);
    $readmemb("multiline_addresses.mem", multiline_memory, 1, 14);
    $display("inline=%h %h %h %h",
             inline_memory[2], inline_memory[10], inline_memory[11], inline_memory[12]);
    $display("multiline=%h %h %h %h",
             multiline_memory[2], multiline_memory[10], multiline_memory[11], multiline_memory[12]);
  end
endmodule
