/*
:name: test_ch9_extra_wait_forms
:description: wait (expression) takes a statement or a null statement, and wait fork waits for the child processes of the calling process (IEEE 1800-2023 Section 9.4.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.3 9.6.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_wait_forms.expected
*/
// IEEE 1800-2023 §9.4.3: a wait statement is "wait ( expression )
// statement_or_null", "wait fork ;" or wait_order. The first fork branch
// uses the statement form and the second uses the null statement form; both
// continue when flag becomes 1 at time 2. The third branch starts a child
// with fork-join_none and then runs wait fork, which §9.6.1 makes wait for
// its immediate children, so it continues at time 1 after the child's delay.
// The fourth branch is the wait_order form, which neither Icarus Verilog 13.0
// nor Verilator 5.052 parses (both reject wait_order as unsupported), so it
// is left out and the wait_order part of the grammar is not exercised.
//
// All four branches run in one fork-join, which ends after the last one at
// time 2. The display shows that both wait (expression) forms and wait fork
// completed.

`timescale 1ns/1ns

module test_ch9_extra_wait_forms;
  int flag = 0;
  int w_stmt = 0;
  int w_null = 0;
  int w_fork = 0;

  initial begin
    fork
      begin wait (flag) w_stmt = 1; end
      begin wait (flag); w_null = 1; end
      begin
        fork
          begin #1; end
        join_none
        wait fork;
        w_fork = 1;
      end
    join
    $display("wait_stmt=%0d wait_null=%0d wait_fork=%0d", w_stmt, w_null, w_fork);
    $finish;
  end

  initial begin
    #2 flag = 1;
  end
endmodule
