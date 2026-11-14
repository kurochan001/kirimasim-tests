/*
:name: test_class_inherited_method_uses_base_local
:description: A nonlocal method that uses a local property of its class is inherited, and called on subclass objects it reads and writes that local property of each object, not a subclass property of the same name (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.18
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inherited_method_uses_base_local.expected
*/
// IEEE 1800-2023 §8.18: a local member is not visible within subclasses, but
// a nonlocal method that accesses local members of its class can be
// inherited and works properly as a method of the subclass.
// counter_c has the local property count and the public methods set, bump
// and get, which write, read and write, and read it. tally_c extends
// counter_c and, since the local count is not visible there, declares a
// public property of its own named count, which its constructor sets to 100.
// set, bump and get called on the tally_c objects t1 and t2, and bump called
// through a counter_c handle that holds t2, work on the local count of each
// object: 7 and 20, then 8 for t1 and 21 for t2, while the count of tally_c
// stays 100 in both. An implementation that let the inherited methods use
// the count of tally_c would print 100 or 101 instead.

class counter_c;
  local int count;
  function void set(int v);
    count = v;
  endfunction
  function int bump();
    count = count + 1;
    return count;
  endfunction
  function int get();
    return count;
  endfunction
endclass

class tally_c extends counter_c;
  int count;
  function new();
    count = 100;
  endfunction
endclass

module test_class_inherited_method_uses_base_local;
  tally_c t1, t2;
  counter_c c;
  int b1, b2;

  initial begin
    t1 = new;
    t2 = new;
    t1.set(7);
    t2.set(20);
    $display("get: t1=%0d t2=%0d", t1.get(), t2.get());
    b1 = t1.bump();
    $display("bump t1=%0d get t1=%0d tally count t1=%0d", b1, t1.get(), t1.count);
    c = t2;
    b2 = c.bump();
    $display("bump via counter_c handle=%0d get t2=%0d tally count t2=%0d", b2, t2.get(),
             t2.count);
  end
endmodule
