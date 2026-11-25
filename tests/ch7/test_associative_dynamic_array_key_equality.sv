/*
:name: test_associative_dynamic_array_key_equality
:description: Equivalent dynamic array values retrieve the same associative entry
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_dynamic_array_key_equality.expected
*/
module test_associative_dynamic_array_key_equality;
  typedef int dynamic_key[];
  int indexed[dynamic_key];
  dynamic_key original, matching, empty_key;
  initial begin
    original = new[2];
    original[0] = 8; original[1] = 1;
    matching = new[2];
    matching[0] = 8; matching[1] = 1;
    indexed[original] = 17;
    $display("equal=%0d value=%0d", original == matching, indexed[matching]);
    matching[1] = 5;
    indexed[matching] = 29;
    indexed[empty_key] = 11;
    $display("entries=%0d original=%0d changed=%0d empty=%0d",
             indexed.size(), indexed[original], indexed[matching], indexed[empty_key]);
    $finish(0);
  end
endmodule
