// A source of test_files_package_in_other_file, compiled before it (:files:).
package files_package_in_other_file_pkg;
  typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
  localparam int LIMIT = 3;
  function automatic state_t next(state_t s);
    if (s == DONE)
      return IDLE;
    return state_t'(s + 1);
  endfunction
endpackage
