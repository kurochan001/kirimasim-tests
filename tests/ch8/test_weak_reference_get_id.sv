/*
:name: test_weak_reference_get_id
:description: The static get_id() of weak_reference returns 0 for null and a nonzero value for an object, the same at every call and through every class type of the handle, and different for different objects (IEEE 1800-2023 Section 8.30.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.5 7.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_get_id.expected
*/
// IEEE 1800-2023 §8.30.5: get_id() is a static function that returns 0 for a
// null object and otherwise a nonzero identification value, the same at every
// call for the same object whatever class type the handle has, and unique among
// the objects that exist. The value can index an associative array (7.8). The
// identifiers themselves are not printed, only how they compare.

module test_weak_reference_get_id;
  class base;
  endclass

  class derived extends base;
  endclass

  typedef weak_reference #(base) base_ref;
  typedef weak_reference #(derived) derived_ref;

  derived d1, d2;
  base b;
  longint id1;
  string names[longint];

  initial begin
    d1 = new();
    d2 = new();
    b = d1;
    id1 = derived_ref::get_id(d1);
    $display("null gives 0: %0d", base_ref::get_id(null) == 0);
    $display("nonzero: %0d", id1 != 0);
    $display("same at a second call: %0d", derived_ref::get_id(d1) == id1);
    $display("same through a base handle: %0d", base_ref::get_id(b) == id1);
    $display("differs for another object: %0d", derived_ref::get_id(d2) != id1);
    names[id1] = "first";
    names[derived_ref::get_id(d2)] = "second";
    $display("lookup: %s %s", names[base_ref::get_id(b)], names[base_ref::get_id(d2)]);
  end
endmodule
