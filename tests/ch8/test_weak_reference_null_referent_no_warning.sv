/*
:name: test_weak_reference_null_referent_no_warning
:description: A weak_reference constructed from a null referent, given as the literal null, as a class handle that holds null or as the null that get() returns, is a new object whose get() returns null, and no warning is printed (IEEE 1800-2023 Sections 8.30.2 and 8.30.3)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.2 8.30.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_weak_reference_null_referent_no_warning.expected
:expected_stderr_regex: \A(?![\s\S]*(?i:warn(?:ing)?))[\s\S]*\Z
*/
// IEEE 1800-2023 §8.30.2: the constructor new(referent) creates a weak
// reference, which is an object of its own, and it issues no warning when the
// referent is null. §8.30.3: until a reference is cleared, get() returns the
// referent it was constructed with, so it returns null for a reference made
// from null and the object for one made from an object.
//
// The test makes weak references from null in six ways: the literal null, a
// handle that was never assigned (a class handle starts as null, 8.4), a
// handle that held an object and was then set to null, a null handle of a
// class derived from the parameter type, the null that get() returns for one
// of these references, and the initializer of a declaration. Each reference
// is an object (not null) different from the five others, and its get()
// returns null. A reference made from an object is the control: its get()
// returns that object. The regular expression on the messages matches only
// when they do not contain the word warning, so a tool that warns about a
// null referent fails the test. Nothing is cleared, and obj keeps the object
// of the control strongly reachable (8.29), so the memory system does not
// change what get() returns.

module test_weak_reference_null_referent_no_warning;
  class item;
    int id;
    function new(int id);
      this.id = id;
    endfunction
  endclass

  class special_item extends item;
    function new();
      super.new(9);
    endfunction
  endclass

  typedef weak_reference #(item) item_ref;

  item obj;
  item never_set;
  item set_to_null;
  special_item no_special;
  item_ref from_declaration = new(null);
  item_ref from_literal, from_unset, from_reset, from_derived, from_get, control;
  item_ref refs[6];
  int equal_pairs;

  function automatic void show(string how, item_ref r);
    $display("%s: reference is an object %0d, get() is null %0d", how, r != null,
             r.get() == null);
  endfunction

  initial begin
    obj = new(5);
    set_to_null = obj;
    set_to_null = null;
    from_literal = new(null);
    from_unset = new(never_set);
    from_reset = new(set_to_null);
    from_derived = new(no_special);
    from_get = new(from_literal.get());
    control = new(obj);
    show("literal null", from_literal);
    show("handle never assigned", from_unset);
    show("handle set to null", from_reset);
    show("null derived handle", from_derived);
    show("null from get()", from_get);
    show("declaration initializer", from_declaration);
    $display("control: get() is obj %0d, id %0d", control.get() == obj, control.get().id);
    refs = '{from_literal, from_unset, from_reset, from_derived, from_get, from_declaration};
    equal_pairs = 0;
    foreach (refs[i])
      foreach (refs[j])
        if (i < j && refs[i] == refs[j]) equal_pairs++;
    $display("equal pairs among the six references: %0d", equal_pairs);
  end
endmodule
