/*
:name: test_immediate_assert_syntax_actions
:description: simple immediate assert and assume take a parenthesized expression and an action block, cover takes a statement or null, a bare fail calls $error, an x expression is false, a label names the block around the statement, and severity tasks run in both pass and fail actions (IEEE 1800-2023 Sections 16.3 and 20.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 20.10
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_immediate_assert_syntax_actions.expected
*/
// IEEE 1800-2023 §16.3: the expression of an immediate assertion is
// interpreted like the condition of an if, so 0, x and z are false and
// anything else is true. assert and assume take an action block whose first
// statement runs on success and whose else statement runs on failure; cover
// takes a statement or null that runs on success. A failed assert or assume
// without an else calls $error. The optional label makes a named block, which
// %m shows. §20.10: a severity system task may appear in a pass or in a fail
// action. The wording of the messages is the tool's and is not compared here;
// the $display calls that follow the severity tasks show that both actions
// ran.

module test_immediate_assert_syntax_actions;
  logic v = 1;
  logic x = 1'bx;
  int passed = 0;

  initial begin
    a1: assert (v) $display("a1 pass");
    a2: assert (v) $display("a2 pass"); else $display("a2 fail");
    a3: assert (!v) $display("a3 pass"); else $display("a3 fail");
    a4: assume (v) $display("a4 pass");
    a5: assume (!v) $display("a5 pass"); else $display("a5 fail");
    c1: cover (v) $display("c1 covered");
    c2: cover (!v) $display("c2 covered");
    c3: cover (x) $display("c3 covered");
    a6: assert (x) $display("a6 pass"); else $display("a6 fail");
    a7: assert (v);   // a true expression runs no action
    a8: assume (v);
    a9: assert (!v);   // no else: the tool calls $error
    $display("after the bare failure");

    sev_p: assert (v) begin
        $info("severity in a pass action");
        $display("sev pass ran");
      end else begin
        $error("severity in a fail action");
        $display("sev fail ran");
      end
    sev_f: assert (!v) begin
        $info("severity in a pass action");
        $display("sev pass ran");
      end else begin
        $error("severity in a fail action");
        $display("sev fail ran");
      end

    lbl: assert (v) $display("label scope %m");
    passed = 1;
    $display("passed=%0d", passed);
    $finish;
  end
endmodule
