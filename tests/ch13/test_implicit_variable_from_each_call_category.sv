/*
:name: test_implicit_variable_from_each_call_category
:description: the result of a call of a user function, of built-in methods, of a system function and of a DPI imported function can each be selected as an implicit variable of the return type of the function within an expression (IEEE 1800-2023 Section 13.4.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_implicit_variable_from_each_call_category.c
:expected_stdout: @test_implicit_variable_from_each_call_category.expected
*/
// IEEE 1800-2023 §13.4.1: a nonvoid function call may be used as an implicit
// variable within an expression, of the return type of the function, so its
// selects use the range of that type; unless otherwise specified this holds
// for every nonvoid call, including built-in methods (§5.13), system
// functions and DPI imported functions (§35.5).
//
// - upper returns hi_t, bit [15:8], so upper(16'hA55A) holds 'hA5 in bits
//   15 to 8 and its select [11:8] is 5; a zero-based range would leave
//   [11:8] outside the value.
// - q.max() returns a queue with the largest element (§7.12.1), and its
//   element [0] is 9; s.substr(1, 3) returns "bcd", and its byte [1] is "c",
//   99.
// - $realtobits(-2.0) returns 64 bits (§20.5): the sign 1 and the biased
//   exponent 1024 make its select [63:52] 'hc00.
// - c_scaled, written in C, returns 16 * x + 3 as an int, so c_scaled(4) is
//   'h43 and its select [7:4] is 4.
// Icarus Verilog 13.0 has no DPI and stops at the import declaration.

module test_implicit_variable_from_each_call_category;
  typedef bit [15:8] hi_t;

  import "DPI-C" function int c_scaled(input int x);

  function automatic hi_t upper(input bit [15:0] v);
    return v[15:8];
  endfunction

  int q[$];
  string s;

  initial begin
    q = '{5, 2, 9};
    s = "abcdef";
    $display("user function: %h", upper(16'hA55A)[11:8]);
    $display("array method: %0d", q.max()[0]);
    $display("string method: %0d", s.substr(1, 3)[1]);
    $display("system function: %h", $realtobits(-2.0)[63:52]);
    $display("DPI import: %0d", c_scaled(4)[7:4]);
  end
endmodule
