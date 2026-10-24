/*
:name: test_cg_block_event_begin_end
:description: A block event begin samples a covergroup just before the first statement of a task runs and a block event end just after its last statement, and the end event is not triggered when the task is disabled (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_block_event_begin_end.expected
*/
// IEEE 1800-2023 §19.3: a covergroup whose coverage event is @@(begin t) is
// sampled immediately before the task t executes its first statement, and one
// with @@(end t) immediately after t executes its last statement; an end
// event is not triggered when the task is disabled.
//
// Each coverpoint has one bin for one value, so its coverage is 100 when that
// value was sampled and 0 otherwise. set_two is called while v is 1 and sets
// v to 2: the begin event samples 1, the end event samples 2. slow sets v to
// 4, waits 5 and sets v to 5. The first call starts while v is 3, and slow is
// disabled during the wait: the begin event samples 3, and the end event
// samples nothing. The second call starts while v is 0 and runs to its end:
// the end event samples 5.

module test_cg_block_event_begin_end;
  int v;

  task set_two();
    v = 2;
  endtask

  task slow();
    v = 4;
    #5 v = 5;
  endtask

  covergroup cg_begin @@(begin set_two);
    one: coverpoint v { bins b = {1}; }
    two: coverpoint v { bins b = {2}; }
  endgroup

  covergroup cg_end @@(end set_two);
    one: coverpoint v { bins b = {1}; }
    two: coverpoint v { bins b = {2}; }
  endgroup

  covergroup cg_slow_begin @@(begin slow);
    three: coverpoint v { bins b = {3}; }
    four: coverpoint v { bins b = {4}; }
  endgroup

  covergroup cg_slow_end @@(end slow);
    four: coverpoint v { bins b = {4}; }
    five: coverpoint v { bins b = {5}; }
  endgroup

  cg_begin gb = new;
  cg_end ge = new;
  cg_slow_begin sb = new;
  cg_slow_end se = new;

  initial begin
    v = 1;
    set_two();
    $display("set_two: begin 1 %.0f, 2 %.0f; end 1 %.0f, 2 %.0f", gb.one.get_inst_coverage(),
             gb.two.get_inst_coverage(), ge.one.get_inst_coverage(),
             ge.two.get_inst_coverage());
    v = 3;
    fork
      slow();
      #1 disable slow;
    join
    #1;
    $display("slow disabled: begin 3 %.0f, 4 %.0f; end 4 %.0f, 5 %.0f",
             sb.three.get_inst_coverage(), sb.four.get_inst_coverage(),
             se.four.get_inst_coverage(), se.five.get_inst_coverage());
    v = 0;
    slow();
    $display("slow completed: begin 3 %.0f, 4 %.0f; end 4 %.0f, 5 %.0f",
             sb.three.get_inst_coverage(), sb.four.get_inst_coverage(),
             se.four.get_inst_coverage(), se.five.get_inst_coverage());
  end
endmodule
