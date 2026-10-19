/*
:name: test_assoc_array_literal_default
:description: Associative array literals with a default value, and assignment of a whole associative array (IEEE 1800-2023 Section 7.9.11)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.11 7.9.9 7.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_literal_default.expected
*/
// IEEE 1800-2023 §7.9.11: an associative array literal lists index:value
// pairs and may give a default. Reading an index that does not exist then
// returns that default; the default is not an entry, so size() (7.9.1) does
// not count it. Assigning a literal replaces the whole contents. §7.9.9:
// assigning one associative array to another first removes every entry of the
// target and then copies the entries of the source.

module test_assoc_array_literal_default;
  int with_default[string];
  int copy[string];

  initial begin
    with_default = '{"a":1, "b":2, default:7};
    $display("a=%0d b=%0d missing=%0d size=%0d",
             with_default["a"], with_default["b"], with_default["zz"], with_default.size());
    copy["old"] = 5;
    copy = with_default;
    $display("copy: size=%0d has old=%0d has a=%0d a=%0d",
             copy.size(), copy.exists("old"), copy.exists("a"), copy["a"]);
    with_default = '{"x":9};
    $display("replaced: size=%0d has a=%0d x=%0d",
             with_default.size(), with_default.exists("a"), with_default["x"]);
  end
endmodule
