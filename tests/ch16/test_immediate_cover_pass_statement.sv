/*
:name: test_immediate_cover_pass_statement
:description: an immediate cover is evaluated each time it is reached and runs its pass statement at once, before the next statement, only when its expression is true; 0, x and z are false as in an if condition (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 12.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_immediate_cover_pass_statement.expected
*/
// IEEE 1800-2023 §16.3: an immediate cover succeeds when its expression is
// true, read as the condition of an if statement (§12.4): 0, x and z are
// false, any other value is true. Its statement_or_null is the pass
// statement, which runs right after a successful evaluation, so it comes
// before the statement that follows the cover, which writes " /"; the pass
// statement can also be a block, or null. One loop reaches the same three
// covers once for each of five values of v, all in time step 0; cond()
// counts how often a cover expression is evaluated, and the block counts
// its runs. Icarus Verilog 13.0 skips immediate cover statements: it neither
// evaluates their expressions nor runs their pass statements.

module test_immediate_cover_pass_statement;
  logic [3:0] vals[5] = '{4'b0000, 4'b0001, 4'b0100, 4'bxxxx, 4'bzzzz};
  logic [3:0] v;
  int evals = 0, hits = 0;
  string log;

  function automatic logic [3:0] cond(logic [3:0] x);
    evals++;
    return x;
  endfunction

  initial begin
    foreach (vals[i]) begin
      v = vals[i];
      log = "";
      cover (cond(v)) log = {log, " covered"};
      log = {log, " /"};
      cover (cond(v)) begin
        hits++;
        log = {log, $sformatf(" hit %0d", hits)};
      end
      log = {log, " /"};
      cover (cond(v));
      $display("v=%b:%s", v, log);
    end
    $display("evaluations: %0d, hits: %0d", evals, hits);
  end
endmodule
