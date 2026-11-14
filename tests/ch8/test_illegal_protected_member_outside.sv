/*
:name: test_illegal_protected_member_outside
:description: A protected property is visible to subclasses but hidden from code outside the class and its subclasses, so a module cannot read it through a handle (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.18
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module reads d.level, a protected property of meter_c, through the handle d
:expected_stderr_regex: test_illegal_protected_member_outside\.sv:45:
*/
// IEEE 1800-2023 §8.18: a protected member has all the characteristics of a
// local member except that it is inherited and visible to subclasses, so it
// stays hidden from code outside the class and its subclasses. dial_c
// extends meter_c, and its method read returns the protected level, which is
// legal. The module reads level through the dial_c handle d. Without the
// last $display the design prints 4.
// The 5.054 release of Verilator reports on the marked line that level is
// hidden as protected; Icarus Verilog 13.0 accepts the design.

class meter_c;
  protected int level;
  function new(int l);
    level = l;
  endfunction
endclass

class dial_c extends meter_c;
  function new(int l);
    super.new(l);
  endfunction
  function int read();
    return level;
  endfunction
endclass

module test_illegal_protected_member_outside;
  dial_c d;

  initial begin
    d = new(4);
    $display("%0d", d.read());
    $display("%0d", d.level);   // illegal: level is protected
  end
endmodule
