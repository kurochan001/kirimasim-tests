/*
:name: test_weak_reference_type_argument_resolves_after_class_forward_declaration
:description: A weak reference specialization made from a forward-declared class uses its completed class type
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.1 8.30.3 6.18 6.20.3 6.23 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_type_argument_resolves_after_class_forward_declaration.expected
*/
module test_weak_reference_type_argument_resolves_after_class_forward_declaration;
  typedef class payload_object;
  typedef std::weak_reference #(.T(payload_object)) pending_reference;

  class payload_object;
    local int payload;
    function new(int value);
      payload = value;
    endfunction
    function int read();
      return payload;
    endfunction
  endclass

  initial begin
    payload_object retained, recovered;
    pending_reference ref_handle;
    longint original_id, recovered_id;
    retained = new(41);
    ref_handle = new(retained);
    recovered = ref_handle.get();
    if (recovered == null) $fatal(1, "live object lost through forward specialization");
    original_id = pending_reference::get_id(retained);
    recovered_id = pending_reference::get_id(recovered);
    $display("value=%0d handle=%b id=%b typed=%b",
             recovered.read(), retained == recovered,
             original_id != 0 && original_id == recovered_id,
             type(ref_handle.get()) == type(retained));
  end
endmodule
