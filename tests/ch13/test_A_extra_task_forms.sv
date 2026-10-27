/*
:name: test_A_extra_task_forms
:description: An ANSI task body has a parenthesized port list, block item declarations and an end label, a non-ANSI task body has tf port declarations before statements, a tf port declaration lists directed identifiers with var and a type, and both kinds of item may appear in a task body (IEEE 1800-2023 Sections 13.3 and 13.4, A.2.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 A.2.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_task_forms.expected
*/
// IEEE 1800-2023 A.2.7, Task declarations: task_declaration is task, the
// optional dynamic override specifiers, the optional lifetime and a
// task_body_declaration. The ANSI body has the ports in parentheses, then
// block_item_declarations and statements, and may close with its name. The
// non-ANSI body has the task identifier and a semicolon, then repeated
// tf_item_declarations (a block item or a tf_port_declaration) and
// statements, and may close with its name. A tf_port_declaration has the
// direction, the optional var, the data type and a list of tf variable
// identifiers.
//
// ansi adds its two inputs and writes the sum through its output; the call
// without b uses the default 2. old subtracts its two var inputs and keeps
// the difference in a block item. life is a static task. The four results
// are 9, 6, 6 and 7.

module test_A_extra_task_forms;
  int r1, r2, r3, r4;

  task automatic ansi(input int a, input int b = 2, output int o);
    int tmp;
    tmp = a + b;
    o = tmp;
  endtask : ansi

  task old;
    input var logic [3:0] a, b;
    output int o;
    int tmp;
    tmp = a - b;
    o = tmp;
  endtask : old

  task static life(output int o);
    o = 7;
  endtask : life

  initial begin
    ansi(4, 5, r1);
    ansi(4, , r2);
    old(9, 3, r3);
    life(r4);
    $display("%0d %0d %0d %0d", r1, r2, r3, r4);
  end
endmodule
