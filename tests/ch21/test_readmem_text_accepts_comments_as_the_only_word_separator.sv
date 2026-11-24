/*
:name: test_readmem_text_accepts_comments_as_the_only_word_separator
:description: Memory files preserve mixed-case unknown digits and accept comments between adjacent words
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_readmem_text_accepts_comments_as_the_only_word_separator.expected
*/
module test_readmem_text_accepts_comments_as_the_only_word_separator;
  logic [7:0] binary_words [0:3];
  logic [7:0] hex_words [0:3];
  int fd;

  initial begin
    fd = $fopen("binary_words.mem", "w");
    if (fd == 0)
      $fatal(1, "could not create binary input");
    $fwrite(fd, "  /%s 00xX_11zZ/%s 10_10_01_01\n",
            "* comment before a word */", "* separates two words */");
    $fwrite(fd, "// comment before tab-separated words\n\t11_11_00_00\t00_00_11_11\n");
    $fclose(fd);
    fd = $fopen("hex_words.mem", "w");
    if (fd == 0)
      $fatal(1, "could not create hexadecimal input");
    $fwrite(fd, "X_z/%s a_F// comment before newline\nZ_x\t5_0\n", "* boundary */");
    $fclose(fd);

    $readmemb("binary_words.mem", binary_words);
    $readmemh("hex_words.mem", hex_words);
    foreach (binary_words[i])
      $display("word %0d binary=%b hex=%h", i, binary_words[i], hex_words[i]);
  end
endmodule
