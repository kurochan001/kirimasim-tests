/*
:name: test_randsequence_code_block_scopes
:description: a randsequence code block is an automatic scope, so its variables are created and initialized again each time it runs unless they are declared static, and the production names of a randsequence statement are local to it, so two statements in one procedure can use the same names for different productions (IEEE 1800-2023 Section 18.17)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_code_block_scopes.expected
*/
// IEEE 1800-2023 §18.17: a randsequence statement creates an automatic scope,
// and its production identifiers are local to it. Each code block creates an
// anonymous automatic scope, so a variable declared there is created and
// initialized on each entry (6.21), while a variable declared there with the
// static prefix is initialized once and keeps its value between executions.
// In the first statement, tick runs three times. Its code block declares
// a = 10 and static s = 10 and increments both, so a is 11 every time and s
// counts 11, 12, 13. The second statement in the same procedure declares the
// productions top and tick again with other bodies: its tick declares static
// s = 100, and top generates it twice, giving 101 and 102. Each statement uses
// its own productions, so the second log does not continue the first one.
// Every production has one rule, so the logs do not depend on random choices.
// Icarus Verilog 13.0 does not support randsequence, and the 5.054 release
// of Verilator stops with an internal error at the initialized variables of
// the code block.

module test_randsequence_code_block_scopes;
  string log;

  initial begin
    log = "";
    randsequence (top)
      top  : repeat (3) tick;
      tick : { int a = 10; static int s = 10; a++; s++; log = {log, $sformatf(" %0d/%0d", a, s)}; };
    endsequence
    $display("first:%s", log);

    log = "";
    randsequence (top)
      top  : tick tick;
      tick : { static int s = 100; s++; log = {log, $sformatf(" %0d", s)}; };
    endsequence
    $display("second:%s", log);
  end
endmodule
