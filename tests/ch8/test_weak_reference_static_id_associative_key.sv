/*
:name: test_weak_reference_static_id_associative_key
:description: A static weak reference ID has longint type and identifies one live object across handle types
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.5 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_static_id_associative_key.expected
*/
// Insert using a derived-typed handle and look up through a base-typed
// handle to the same live object. A second live object must have a new key.
module test_weak_reference_static_id_associative_key;
  class parent_t;
  endclass
  class child_t extends parent_t;
  endclass
  typedef std::weak_reference#(parent_t) parent_ref;
  typedef std::weak_reference#(child_t) child_ref;

  child_t first, second;
  parent_t base_alias;
  int values[longint];
  longint first_id, second_id, alias_id;

  initial begin
    first = new;
    second = new;
    base_alias = first;
    first_id = child_ref::get_id(first);
    second_id = child_ref::get_id(second);
    alias_id = parent_ref::get_id(.obj(base_alias));
    values[first_id] = 17;
    values[second_id] = 41;
    $display("longint=%0d same=%0d nonzero=%0d",
             type(child_ref::get_id(first)) == type(longint),
             alias_id == first_id, first_id != 0 && second_id != 0);
    $display("keys=%0d via_base=%0d second=%0d null=%0d",
             values.num(), values[alias_id], values[second_id], parent_ref::get_id(null));
  end
endmodule
