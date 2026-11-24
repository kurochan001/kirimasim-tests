/*
:name: test_weak_reference_identity_survives_base_and_derived_specialization
:description: Weak references specialized on a base class and a derived class retain one object identity and its derived behavior
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.1 8.30.3 8.30.5 8.20 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_identity_survives_base_and_derived_specialization.expected
*/
module test_weak_reference_identity_survives_base_and_derived_specialization;
  virtual class root_type;
    virtual function int score();
      return -1;
    endfunction
  endclass

  class child_type extends root_type;
    int value;
    function new(int number);
      value = number;
    endfunction

    virtual function int score();
      return value;
    endfunction
  endclass

  typedef std::weak_reference #(root_type) root_reference;
  typedef std::weak_reference #(child_type) child_reference;

  initial begin
    child_type original, another, downcast, concrete;
    root_type recovered;
    root_reference base_view;
    child_reference direct_view;
    longint base_id, direct_id, different;
    bit cast_ok;
    original = new(73);
    another = new(91);
    base_view = new(original);
    direct_view = new(original);
    recovered = base_view.get();
    concrete = direct_view.get();
    cast_ok = $cast(downcast, recovered);
    if (recovered == null || concrete == null) $fatal(1, "live referent is missing");
    base_id = root_reference::get_id(recovered);
    direct_id = child_reference::get_id(concrete);
    different = child_reference::get_id(another);
    $display("base value=%0d derived value=%0d cast=%b same=%b",
             recovered.score(), concrete.score(), cast_ok,
             downcast == original && concrete == original);
    $display("identity stable=%b unique=%b",
             base_id != 0 && base_id == direct_id, different != 0 && different != direct_id);
  end
endmodule
