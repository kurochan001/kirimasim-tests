/*
:name: test_illegal_randsequence_code_block_hierarchical_reference
:description: a variable declared in a randsequence code block cannot be referenced by a hierarchical name, here through the named block that contains the randsequence statement (IEEE 1800-2023 Section 18.17)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.17
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: gen.v is a hierarchical reference to the variable v, which is declared in a code block of the randsequence statement in the named block gen
:expected_stderr_regex: test_illegal_randsequence_code_block_hierarchical_reference\.sv:40:
*/
// IEEE 1800-2023 §18.17: each code block of a randsequence statement creates
// an anonymous automatic scope, and hierarchical references to the variables
// declared in code blocks are not allowed.
// The named block gen declares w and holds a randsequence statement whose code
// block declares the static variable v; v is static so that only the rule of
// 18.17 forbids reaching it, not the lifetime of an automatic variable. The
// second initial procedure reads gen.w, a variable of the named block, which
// is legal, and gen.v, the variable of the code block, which is the only
// error.
// The 5.054 release of Verilator runs the design without gen.v and reports
// that it finds no v in gen. Icarus Verilog 13.0 does not support
// randsequence, so its error does not count.

module test_illegal_randsequence_code_block_hierarchical_reference;
  int seen;

  initial begin : gen
    int w;
    w = 2;
    randsequence (top)
      top : { static int v; v = 3; seen = v + w; };
    endsequence
  end

  initial begin
    #1 $display("w=%0d seen=%0d", gen.w, seen);
    $display("v=%0d", gen.v);   // illegal
  end
endmodule
