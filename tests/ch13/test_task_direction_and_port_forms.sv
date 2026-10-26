/*
:name: test_task_direction_and_port_forms
:description: Task formals default to input, inherit the last direction including ref and const ref, inherit the type of the previous formal, and accept attributes, var, signed dimensions and defaults (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_direction_and_port_forms.expected
*/
// IEEE 1800-2023 §13.3: a formal with no direction is an input until a
// direction is given, and later formals inherit that direction, including
// the const and static qualifiers of ref. A formal with no type inherits the
// previous formal's type. Task t names only the first input, output and inout
// directions, so b, v and x inherit them. Task rd gives r1 the ref direction
// and r2 inherits it, and task cr gives c1 the const ref direction and c2
// inherits that. Task tp carries an attribute, var, a signed packed
// dimension and a default value on its formals.
//
// Icarus Verilog 13.0 does not support ref ports, and the 5.052 release of
// the simulator named Verilator does not support ref static ports, so the
// expectation follows 13.3.

module test_task_direction_and_port_forms;
  int a, b, u, v, w, x, r;

  task automatic t(input int a, b, output int u, v, inout int w, x);
    u = a + b;
    v = a - b;
    w = w + 1;
    x = x + 2;
  endtask : t

  task automatic rd(input int a, ref int r1, r2);
    r1 = a;
    r2 = a + 1;
  endtask : rd

  task automatic cr(const ref int c1, c2);
    $display("cr=%0d,%0d", c1, c2);
  endtask : cr

  task automatic sr(ref static int r1, r2);
    $display("sr=%0d,%0d", r1, r2);
  endtask : sr

  task automatic tp((* keep = "true" *) input var logic signed [3:0] s,
                    input int d = 5, output int q);
    q = s + d;
  endtask : tp

  initial begin
    a = 7;
    b = 2;
    w = 10;
    x = 20;
    t(a, b, u, v, w, x);
    $display("t=%0d,%0d,%0d,%0d", u, v, w, x);
    rd(4, a, b);
    $display("rd=%0d,%0d", a, b);
    cr(a, b);
    sr(a, b);
    tp(4'sd3, , r);
    $display("tp=%0d", r);
  end
endmodule
