/*
:name: test_statement_item_forms
:description: The procedural statement items of the grammar run in one procedure: blocking, operator, increment and nonblocking assignments, a procedural continuous assignment, if and case, a task call, disable, an event trigger, loops with continue and break, fork-join, delays and event controls, wait, an immediate assertion, a clocking drive, randcase, randsequence and expect (IEEE 1800-2023 Section 12.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.3 12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_statement_item_forms.expected
*/
// IEEE 1800-2023 §12.3: a statement_item is one of the listed procedural
// forms, each ending in the semicolon its syntax requires. The initial block
// uses every form that this test can run without a second source: assignments,
// if and case, a task call, disable of a named block, an event trigger, a for,
// repeat, while and do-while loop with continue and break, a fork-join, a
// delay and an event control, a wait, an immediate assertion, a clocking
// drive, randcase, randsequence and expect. The value of i after each group is
// fixed: 1+2+1 = 4, 5, 6, +4 = 10, +4 in the loop = 14, +2 = 16, +2 = 18,
// -1 = 17, the disabled block adds nothing, the fork adds and removes 100,
// the assertion gives 18, the fork gives 21, the nonblocking assignment 22,
// the randcase adds 10 whatever branch it takes, the two randsequence
// productions add 4 and 8, so i is 44. p is 1 from the procedural continuous
// assignment and keeps that value after deassign (10.6.1), and the clocking
// drive writes q_cb at the next rising edge.
// The task add declares v as input: a formal without a direction takes the
// direction of the one before it (13.3), so v would be ref, and a literal
// actual such as 4 cannot be passed by reference (13.5.2).

`timescale 1ns/1ns

module test_statement_item_forms;
  logic clk = 0;
  logic p = 0;
  logic q_cb = 0;
  event ev;
  int i = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    output q_cb;
  endclocking

  task automatic add(ref int x, input int v);
    x += v;
  endtask

  initial begin : outer
    int k;
    i = 1;
    i += 2;
    i++;
    if (i == 4) i = 5;
    else i = 99;
    case (i)
      5: i = 6;
      default: i = 99;
    endcase
    add(i, 4);
    for (k = 0; k < 6; k++) begin
      if (k == 1) continue;
      if (k == 5) break;
      i += 1;
    end
    repeat (2) i++;
    while (i < 18) i++;
    do i--; while (i > 17);
    begin : inner
      disable inner;
      i = 99;
    end
    fork
      begin
        @ev;
        i += 100;
      end
      #1 -> ev;
    join
    i = i - 100;
    wait (i == 17);
    assert (i == 17) i++;
    else i = 99;
    fork
      #1 i += 1;
      #2 i += 2;
    join
    i <= i + 1;
    #0;
    assign p = 1'b1;
    #1 deassign p;
    randcase
      1: i += 10;
      1: i += 10;
    endcase
    randsequence (main)
      main: one two;
      one: { i += 4; };
      two: { i += 8; };
    endsequence
    cb.q_cb <= 1'b1;
    @(posedge clk);
    #0;
    expect (@(posedge clk) 1'b1) i += 0;
    else i = 99;
    #20;
    $display("i=%0d p=%b q_cb=%b", i, p, q_cb);
    $finish;
  end
endmodule
