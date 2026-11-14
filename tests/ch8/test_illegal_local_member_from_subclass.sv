/*
:name: test_illegal_local_member_from_subclass
:description: A local property is not visible within a subclass, so a method of the subclass cannot refer to it, while an inherited nonlocal method still can (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.18
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method peek of the subclass box_c refers to secret, a local property of its base class vault_c
:expected_stderr_regex: test_illegal_local_member_from_subclass\.sv:42:
*/
// IEEE 1800-2023 §8.18: a local member is available only to the methods of
// the class that declares it and is not visible within its subclasses; a
// nonlocal method of that class that uses it is inherited and keeps working
// in the subclass. box_c extends vault_c. Its method via_base calls the
// inherited get, which reads secret, and that is legal. Its method peek names
// secret itself. No other scope declares the name secret. Without peek and
// its call the design prints 6.
// test_illegal_local_member_outside checks a reference from outside the
// class.
// The 5.054 release of Verilator reports on the marked line that secret is
// hidden as local. Icarus Verilog 13.0 reports instead that it finds no
// function get for the legal call in via_base, which does not count.

class vault_c;
  local int secret;
  function void put(int s);
    secret = s;
  endfunction
  function int get();
    return secret;
  endfunction
endclass

class box_c extends vault_c;
  function int via_base();
    return get();
  endfunction
  function int peek();
    return secret;   // illegal: secret is local to vault_c
  endfunction
endclass

module test_illegal_local_member_from_subclass;
  box_c b;

  initial begin
    b = new;
    b.put(6);
    $display("%0d", b.via_base());
    $display("%0d", b.peek());
  end
endmodule
