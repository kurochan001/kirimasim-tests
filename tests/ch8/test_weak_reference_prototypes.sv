/*
:name: test_weak_reference_prototypes
:description: std::weak_reference has a class type parameter T, a constructor taking a T referent, get() returning T with the referent until clear() sets it to null, clear() returning nothing, and a static get_id(T) whose longint result is 0 for null, nonzero for an object and the same at every call for one object (IEEE 1800-2023 Sections G.7, 8.30.1 to 8.30.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_prototypes.expected
*/
// IEEE 1800-2023 §G.7: weak_reference is a parameterized class whose
// parameter T is a class type, with the constructor new(T referent), get()
// returning T, clear() returning nothing, and the static get_id(T obj)
// returning longint. §8.30.2: the constructor takes the referent. §8.30.3:
// get() returns the referent until the reference is cleared. §8.30.4: clear()
// sets the value get() returns to null. §8.30.5: get_id() gives 0 for null and
// otherwise a nonzero identification value that is the same at every call for
// one object.
//
// The test names the class through the std package with the class type item as
// its parameter, creates a reference to an item, takes the referent back
// through get(), and reads the identification value of the object at two calls
// and of null. It prints the number of bits of the result of get_id(), which
// is 64 exactly when the result is a longint, and checks that get() gives null
// after clear(). Objects stay strongly reachable through the handles of the
// test, so the memory system does not clear the reference.

module test_weak_reference_prototypes;
  class item;
    int id;
    function new(int id);
      this.id = id;
    endfunction
  endclass

  typedef std::weak_reference #(item) item_ref;

  initial begin
    item obj;
    item_ref reference;
    item got;
    longint id;
    longint again;
    longint from_null;

    obj = new(7);
    reference = new(obj);
    got = reference.get();
    $display("get returns the referent %0d", got == obj);

    id = item_ref::get_id(obj);
    again = item_ref::get_id(obj);
    from_null = item_ref::get_id(null);
    $display("get_id of null is 0 %0d", from_null == 0);
    $display("get_id of an object is nonzero and stable %0d",
             id != 0 && again == id);
    $display("get_id returns 64 bits %0d",
             $bits(item_ref::get_id(obj)) == 64);

    reference.clear();
    $display("get after clear is null %0d", reference.get() == null);
  end
endmodule
