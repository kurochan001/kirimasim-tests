// Included by test_include_file_declarations (:files:).
typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} include_file_declarations_pair_t;

function automatic int include_file_declarations_sum(include_file_declarations_pair_t p);
  return p.hi + p.lo;
endfunction
