/*
:name: test_syntax_action_block_and_simple_assertions
:description: Simple immediate assert, assume and cover take an expression and an action block that is a statement, a null statement, an else statement, or a statement before else, and run the action of the result of the expression (IEEE 1800-2023 Section 16.3 and A.6.3, A.6.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 A.6.3 A.6.10 A.6.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_action_block_and_simple_assertions.expected
*/
// IEEE 1800-2023 A.6.3: an action block is a statement or null statement, or
// an optional statement followed by "else" and a statement or null
// statement. A.6.10 and §16.3: "assert (e)" and "assume (e)" take an action
// block, whose statement before else is the pass action and whose else
// statement is the fail action; "cover (e)" takes a statement or null
// statement, which runs when e is true.
//
// Each of the three keywords is written with all the action forms: a pass
// statement only, a null statement only, an else statement only, and a pass
// statement followed by else. a is 0, so the assertions and assumptions with
// e = (a == 0) pass and those with e = (a == 1) fail; the cover with e =
// (a == 0) runs its statement and the one with e = (a == 1) has a null
// statement and prints nothing. The failing assertions and assumptions print
// their severity messages, which are not part of the test's output.
//
// Icarus Verilog 13.0 does not run the statement of a true immediate cover,
// so the expected output follows the standard; the 5.052 release of the
// other simulator produces it.

module test_syntax_action_block_and_simple_assertions;
  int a = 0;

  initial begin
    assert (a == 0) $display("assert pass action");
    assert (a == 0) ;
    assert (a == 1) else $display("assert fail else action");
    assert (a == 1) $display("not printed"); else $display("assert fail with pass action");

    assume (a == 0) $display("assume pass action");
    assume (a == 0) ;
    assume (a == 1) else $display("assume fail else action");
    assume (a == 1) $display("not printed"); else $display("assume fail with pass action");

    cover (a == 0) $display("cover true statement");
    cover (a == 1) ;

    $finish;
  end
endmodule
