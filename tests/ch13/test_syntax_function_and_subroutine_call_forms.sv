/*
:name: test_syntax_function_and_subroutine_call_forms
:description: A function body is a statement that may hold attributes and a null statement, and the subroutine call statement forms "call;" and "void'(call);" run tasks and functions, while return with and without a value, break and continue end their statements as A.6.4, A.6.5 and A.6.9 say (IEEE 1800-2023 Sections 12.8 and 13.4, A.6.4, A.6.5, A.6.9)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.1 12.8 A.6.4 A.6.5 A.6.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_function_and_subroutine_call_forms.expected
*/
// IEEE 1800-2023 A.6.4: function_statement is statement and
// function_statement_or_null adds a null statement with attributes. A.6.9: a
// subroutine call statement is "subroutine_call ;" or "void ' (
// function_subroutine_call ) ;". A.6.5 and §12.8: return with an expression
// leaves a function with that value, return without one leaves a void
// function or a task, break leaves the loop, and continue starts its next
// pass.
//
// The function with_return logs its call, has a block label, an attributed
// null statement in its body, and returns 0 for a negative argument and x+1
// otherwise. The task add and the void function early add to total, and
// early returns before its addition for 0. just_log is called as a statement
// and with_return through the void cast. The for loop skips 2 with continue
// and stops at 5 with break, so sum is 0+1+3+4 = 8. The test prints total,
// log, the two return values and sum.

module test_syntax_function_and_subroutine_call_forms;
  int log = 0;
  int total = 0;

  function automatic int with_return(int x);
    log = log + 1;
    begin : fblock
      (* keep *) ;
      if (x < 0) return 0;
      return x + 1;
    end : fblock
  endfunction

  function automatic void just_log;
    log = log + 1;
  endfunction

  function automatic void early(int x);
    if (x == 0) return;
    total = total + 100;
  endfunction

  task automatic add(input int x);
    total = total + x;
  endtask

  task automatic add_or_skip(input int x);
    if (x == 0) return;
    total = total + x;
  endtask

  int sum = 0;

  initial begin
    add(3);
    add_or_skip(0);
    add_or_skip(4);

    just_log();
    void'(with_return(1));

    early(0);
    early(1);

    for (int i = 0; i < 10; i++) begin
      if (i == 2) continue;
      if (i == 5) break;
      sum = sum + i;
    end

    $display("total=%0d log=%0d sum=%0d", total, log, sum);
    $display("return: %0d %0d", with_return(-1), with_return(2));
  end
endmodule
