/*
:name: test_weak_reference_get_clear
:description: A weak_reference returns its referent from get() until clear() is called on it, after which get() returns null; two weak references to one object are different objects with the same referent (IEEE 1800-2023 Section 8.30.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.3 8.30.2 8.30.4 26.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_get_clear.expected
*/
// IEEE 1800-2023 §8.30.2: new(referent) creates a weak reference, a unique
// object, so two weak references to one object differ while their get()
// results are the same; a null referent gives no warning. §8.30.3: get()
// returns the referent until the reference is cleared, then null. §8.30.4:
// clear() clears one weak reference only. weak_reference is a parameterized
// class of the std package (8.30.1, 26.7). The objects stay strongly reachable
// through obj, so the memory system does not clear them.

module test_weak_reference_get_clear;
  class item;
    int id;
    function new(int id);
      this.id = id;
    endfunction
  endclass

  item obj;
  weak_reference #(item) w1, w2, wn;

  initial begin
    obj = new(42);
    w1 = new(obj);
    w2 = new(obj);
    wn = new(null);
    $display("w1 != w2: %0d, same referent: %0d, id: %0d", w1 != w2,
             w1.get() == w2.get(), w1.get().id);
    $display("null referent: %0d", wn.get() == null);
    w1.clear();
    $display("after w1.clear(): w1.get() null: %0d, w2.get() is obj: %0d", w1.get() == null,
             w2.get() == obj);
  end
endmodule
