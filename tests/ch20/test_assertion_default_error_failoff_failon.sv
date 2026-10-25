/*
:name: test_assertion_default_error_failoff_failon
:description: a failing immediate assert or assume statement without an else clause calls $error by default, one with an else clause runs that instead, and $assertcontrol FailOff (9) stops both the default $error and the else clause of the selected assertions until FailOn (8) (IEEE 1800-2023 Sections 20.10 and 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.11 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_default_error_failoff_failon.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:45:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:46:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:47:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:48:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:52:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:53:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:54:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:55:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:59:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:60:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:61:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:62:)(?=[\s\S]*test_assertion_default_error_failoff_failon\.sv:66:)(?![\s\S]*test_assertion_default_error_failoff_failon\.sv:67:)
*/
// IEEE 1800-2023 §20.10: when the action block of an assert or assume
// statement has no else clause, the fail action is a call to $error, whose
// message gives the file and line; for assertions, $assertcontrol with
// control_type 9 (FailOff) suppresses it. §20.11: FailOff stops the fail
// actions of the selected assertions, the default $error included, until
// control_type 8 (FailOn); assertion_type 2 selects simple immediate
// assertions and directive_type 4 assume directives.
// Every statement below fails, since z is 0, and is on its own line: an
// assert with no action block, an assume with no action block, an assert
// with a pass statement only, and an assert with an else clause, which
// counts in place of the $error. The regular expression requires a message
// from the lines where the default $error has to run and none from the
// others: all three run in the first group (lines 45 to 47), none after
// FailOff of all assertions (52 to 54), all three again after FailOn (59 to
// 61), and after FailOff of assume directives alone the assert of line 66
// reports but the assume of line 67 does not. No else-clause line (48, 55,
// 62) ever reports. The else clause counts in the first and third groups
// only, and the pass statements never run.
// Release 5.052 of the Verilator tool prints no message for a failing assert
// that has a pass statement but no else clause (lines 47 and 61), and Icarus
// Verilog 13.0 does not define $assertcontrol.

module test_assertion_default_error_failoff_failon;
  logic z = 0;
  int passes = 0, fails = 0;

  task automatic show(string name);
    $display("%s: pass statements %0d, else clauses %0d", name, passes, fails);
  endtask

  initial begin
    a1: assert (z);
    m1: assume (z);
    p1: assert (z) passes++;
    e1: assert (z) else fails++;
    show("default");
    $assertcontrol(9);
    #1;
    a2: assert (z);
    m2: assume (z);
    p2: assert (z) passes++;
    e2: assert (z) else fails++;
    show("failoff");
    $assertcontrol(8);
    #1;
    a3: assert (z);
    m3: assume (z);
    p3: assert (z) passes++;
    e3: assert (z) else fails++;
    show("failon");
    $assertcontrol(9, 2, 4);
    #1;
    a4: assert (z);
    m4: assume (z);
    $assertcontrol(8);
    show("failoff assume");
    $finish;
  end
endmodule
