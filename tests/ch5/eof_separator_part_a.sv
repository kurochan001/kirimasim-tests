// A source of test_end_of_file_separates_tokens, compiled before it
// (:files:). This file ends right after the keyword endmodule, without a
// newline, and the next file starts with the keyword module.
module eof_separator_part_a;
  int val = 10;
endmodule