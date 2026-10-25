// An include file of test_include_text_joins_compilation_unit (:files:). It
// is included outside any module, so these declarations are in the
// compilation-unit scope of the including file.
int inc_count = 3;
typedef enum {INC_RED, INC_GREEN, INC_BLUE} inc_color_t;

function automatic int inc_double(int x);
  return 2 * x;
endfunction
