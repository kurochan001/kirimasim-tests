/*
:name: test_unit_scope_shared_state
:description: A variable and a task declared in the compilation-unit scope are one object and one subroutine for every module (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 3.13
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_scope_shared_state.expected
*/
// IEEE 1800-2023 §3.12.1: a declaration in the compilation-unit scope is
// visible to every design element of the compilation unit, and there is one
// instance of a variable declared there. §3.13: the task unit_bump is in the
// compilation-unit name space, so both modules call the same task, which
// increments the same unit_count. The module at 1 runs after the top module
// has incremented it once, and the top module at 2 sees both increments.

int unit_count = 0;

task unit_bump();
  unit_count = unit_count + 1;
endtask

module m_unit_user;
  initial begin
    #1 unit_bump();
    $display("m_unit_user %0d", unit_count);
  end
endmodule

module test_unit_scope_shared_state;
  initial begin
    unit_bump();
    #2 $display("top %0d", unit_count);
  end
endmodule
