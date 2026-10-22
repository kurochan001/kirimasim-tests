/*
:name: test_weak_reference_id_alias_after_clear
:description: Clearing one weak wrapper leaves another wrapper and the ownerly held object identity unchanged (IEEE 1800-2023 Section 8.30.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.1 8.30.2 8.30.5 8.29
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_id_alias_after_clear.expected
*/
// IEEE 1800-2023 8.30.1 8.30.2 8.30.5 8.29: Two independently constructed weak
// references to one ownerly reachable object have the same target; clearing
// one wrapper cannot clear the other.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_weak_reference_id_alias_after_clear;
  class item; int value = 37; endclass
  typedef weak_reference #(item) weak_t;
  item owner, recovered;
  weak_t first_ref, second_ref;
  longint identity;
  initial begin
    owner = new; first_ref = new(owner); second_ref = new(owner);
    identity = weak_t::get_id(owner);
    first_ref.clear(); recovered = second_ref.get();
    $display("cleared=%0d alive=%0d value=%0d same_id=%0d", first_ref.get() == null,
             recovered == owner, recovered.value, weak_t::get_id(recovered) == identity);
  end
endmodule
