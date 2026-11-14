/*
:name: test_class_protected_members_in_subclasses
:description: A protected property and a protected method are inherited by subclasses and visible to them, so subclass methods one and two levels down read and write the property and call the method (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.18
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_protected_members_in_subclasses.expected
*/
// IEEE 1800-2023 §8.18: a protected class property or method has the
// characteristics of a local member, except that it is inherited and visible
// to subclasses.
// tank_c has the protected property level and the protected method scaled,
// and the public method show, which returns level. pump_c extends tank_c,
// and its method fill reads and writes level and calls scaled; big_pump_c
// extends pump_c, and its method drain does the same two levels below
// tank_c. The module only calls the public methods. p starts at level 3:
// fill(4) makes it 7 and returns 7 * 2. q starts at 50: drain(8) makes it 42
// and returns 42 * 10, and the inherited fill(1) makes it 43 and returns
// 43 * 2. show reads the same level that the subclass methods wrote; an
// implementation that gave the subclasses a copy of level would print the
// starting levels there.
// Icarus Verilog 13.0 reports that it finds no function scaled for the call
// in drain of big_pump_c.

class tank_c;
  protected int level;
  function new(int l);
    level = l;
  endfunction
  protected function int scaled(int k);
    return level * k;
  endfunction
  function int show();
    return level;
  endfunction
endclass

class pump_c extends tank_c;
  function new(int l);
    super.new(l);
  endfunction
  function int fill(int d);
    level = level + d;
    return scaled(2);
  endfunction
endclass

class big_pump_c extends pump_c;
  function new(int l);
    super.new(l);
  endfunction
  function int drain(int d);
    level = level - d;
    return scaled(10);
  endfunction
endclass

module test_class_protected_members_in_subclasses;
  pump_c p;
  big_pump_c q;
  int r1, r2, r3;

  initial begin
    p = new(3);
    q = new(50);
    r1 = p.fill(4);
    $display("pump: fill=%0d level=%0d", r1, p.show());
    r2 = q.drain(8);
    $display("big pump: drain=%0d level=%0d", r2, q.show());
    r3 = q.fill(1);
    $display("big pump: fill=%0d level=%0d", r3, q.show());
  end
endmodule
