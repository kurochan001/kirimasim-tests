/*
:name: test_duplicate_attribute_advisory_sites
:description: The optional duplicate attribute warning applies to repeated names on one declaration in either attribute spelling
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_duplicate_attribute_advisory_sites.expected
*/
// tools/run_optional_lexical.py checks the source-local advisory with
// the diagnostic enabled and suppressed. Reusing the same attribute on
// different declarations is the negative control.
module test_duplicate_attribute_advisory_sites;
  (* mark = 1, mark = 2 *) logic one_list;    // duplicate site
  (* mark = 3 *) (* mark = 4 *) logic two_lists;  // duplicate site
  (* mark = 5 *) logic independent_left;
  (* mark = 6 *) logic independent_right;

  initial begin
    {one_list, two_lists, independent_left, independent_right} = 4'b1010;
    $display("carriers=%b%b%b%b", one_list, two_lists, independent_left, independent_right);
  end
endmodule
