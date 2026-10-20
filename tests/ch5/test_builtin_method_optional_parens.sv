/*
:name: test_builtin_method_optional_parens
:description: A built-in method called without arguments, or with only arguments that have defaults, can leave out the empty parentheses (IEEE 1800-2023 Section 5.13)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.13 7.5.2 7.9.1 6.16.1 6.19.5.3 7.10.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_builtin_method_optional_parens.expected
*/
// IEEE 1800-2023 §5.13: built-in methods are called with the dot notation,
// and when a call gives no arguments the parentheses are optional, also for a
// method whose arguments all have defaults. size of a dynamic array (7.5.2),
// num of an associative array (7.9.1) and len of a string (6.16.1) are called
// without parentheses, as is next of an enum (6.19.5.3), whose argument
// defaults to 1, and delete of a queue (7.10.2.3), whose index is optional.

module test_builtin_method_optional_parens;
  typedef enum {RED, GREEN, BLUE} color_t;

  int dyn[];
  int assoc[string];
  string s = "method";
  color_t c = RED;
  int q[$] = '{1, 2, 3};

  initial begin
    dyn = new[4];
    assoc["a"] = 1;
    assoc["b"] = 2;
    c = c.next;
    q.delete;
    $display("size=%0d num=%0d len=%0d next=%s queue=%0d", dyn.size, assoc.num, s.len,
             c.name, q.size);
  end
endmodule
