module eof_separator_part_b;
  // A source of test_end_of_file_separates_tokens, compiled after
  // eof_separator_part_a.sv (:files:). Its first token, module, comes right
  // after the end of that file, and this file ends without a newline too.
  int val = 20;
endmodule