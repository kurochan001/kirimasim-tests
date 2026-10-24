/*
:name: test_immediate_assertion_label_scope
:description: the label of an immediate assert, assume or cover creates a named block around it, so %m in its action shows the label as the last part of the scope name; an unlabeled assertion and the statement after a labeled one show the enclosing scope (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 21.2.1.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_label_scope.expected
*/
// IEEE 1800-2023 §16.3: the optional label of an immediate assertion creates
// a named block around the assertion, and %m (§21.2.1.5) shows the
// hierarchical name of that scope. The actions of labeled assertions in the
// named block blk and in the task t_check therefore print the label after
// the name of the enclosing scope, for a passing and a failing assert, an
// assume and a cover. The scope of a label covers only its assertion: an
// unlabeled assertion and the statement that follows the labeled ones print
// the name of blk itself. Icarus Verilog 13.0 leaves the label out of %m
// and skips the immediate cover.

module test_immediate_assertion_label_scope;
  int x = 0;

  task automatic t_check();
    a_task: assert (x == 1) $display("pass: %m"); else $display("task fail: %m");
  endtask

  initial begin : blk
    a_pass: assert (x == 0) $display("assert pass: %m"); else $display("wrong: %m");
    a_fail: assert (x == 1) $display("wrong: %m"); else $display("assert fail: %m");
    u_assume: assume (x == 0) $display("assume pass: %m");
    c_cover: cover (x == 0) $display("cover pass: %m");
    assert (x == 0) $display("unlabeled pass: %m");
    $display("next statement: %m");
    t_check();
  end
endmodule
