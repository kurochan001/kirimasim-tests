// A source of test_include_guard_two_files, compiled before it (:files:).
`include "include_guard_two_files.svh"
module include_guard_two_files_helper(input int x, output int y);
  assign y = x * `INCLUDE_GUARD_TWO_FILES_SCALE;
endmodule
