/*
:name: test_typename_func
:description: Test $typename function (IEEE 1800-2023 Section 20.6)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typename_func.expected
*/
// Test $typename function (IEEE 1800-2023 Section 20.6)

module test_typename_func;
  int i;
  logic [7:0] byte_val, byte_val2;
  logic [15:0] word_val;
  string s;
  real r;
  int pass_count;

  typedef enum {A, B, C} enum_t;
  enum_t e, e2;

  initial begin
    pass_count = 0;

    // 20.6.1: built-in types are named by their keyword. For a packed
    // range or an enum, only the type identity is checked: equal types give
    // equal strings and different types different strings (the exact
    // spacing of "logic [7:0]" is not checked).
    s = $typename(i);
    if (s == "int") pass_count++; else $display("FAIL: int -> %s", s);

    s = $typename(r);
    if (s == "real") pass_count++; else $display("FAIL: real -> %s", s);

    s = $typename(s);
    if (s == "string") pass_count++; else $display("FAIL: string -> %s", s);

    if ($typename(byte_val) == $typename(byte_val2) && $typename(byte_val) != $typename(word_val))
      pass_count++;
    else $display("FAIL: logic [7:0] -> %s", $typename(byte_val));

    if ($typename(e) == $typename(e2) && $typename(e) != $typename(i)) pass_count++;
    else $display("FAIL: enum -> %s", $typename(e));

    $display("Typename func tests: %0d/5 passed", pass_count);
    if (pass_count == 5) begin
      $display("PASS: Typename func tests");
    end else begin
      $display("FAIL: Some typename tests failed");
    end
  end
endmodule
