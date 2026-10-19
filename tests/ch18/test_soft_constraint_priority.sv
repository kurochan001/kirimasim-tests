/*
:name: test_soft_constraint_priority
:description: Soft constraints give way to hard constraints and to later soft constraints, and disable soft drops them (IEEE 1800-2023 Section 18.5.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.1 18.5.13.2 18.5.13 18.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_constraint_priority.expected
*/
// IEEE 1800-2023 §18.5.13: a soft constraint is kept only when it does not
// contradict a hard constraint. §18.5.13.1: between soft constraints, the one
// declared later has the higher priority, and an inline constraint of
// randomize() with (18.7) comes after those of the class. §18.5.13.2: disable
// soft v drops the lower-priority soft constraints on v.

class scp_obj;
  rand int a, b, c;
  constraint c1 { soft a == 1; soft a == 2; }
  constraint c2 { soft b == 5; b > 10; b < 20; }
  constraint c3 { soft c == 3; }
endclass

module test_soft_constraint_priority;
  scp_obj o;
  int b_ok = 1;

  initial begin
    o = new;
    void'(o.randomize());
    $display("later soft wins: a=%0d", o.a);
    repeat (20) begin
      void'(o.randomize());
      if (!(o.b > 10 && o.b < 20)) b_ok = 0;
    end
    $display("hard constraint wins over soft: b in (10,20) every time=%0d", b_ok);
    $display("soft kept when nothing contradicts it: c=%0d", o.c);
    void'(o.randomize() with { soft a == 7; });
    $display("inline soft wins over class soft: a=%0d", o.a);
    void'(o.randomize() with { a == 9; });
    $display("inline hard: a=%0d", o.a);
    void'(o.randomize() with { disable soft c; c inside {40, 41}; });
    $display("disable soft c: c in {40,41}=%0d", o.c inside {40, 41});
  end
endmodule
