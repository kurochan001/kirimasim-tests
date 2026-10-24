/*
:name: test_illegal_inherited_nonvirtual_method_for_interface
:description: an inherited nonvirtual method does not implement a method of an interface class (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: bad_c implements run_if but its only method run is the nonvirtual one inherited from plain_base_c
:expected_stderr_regex: test_illegal_inherited_nonvirtual_method_for_interface\.sv:(42|43):
*/
// IEEE 1800-2023 §8.26.2: an inherited virtual method can provide the
// implementation of a method of an implemented interface class, but an
// inherited nonvirtual method cannot. ok_c inherits a virtual run and is
// legal; bad_c, which is not abstract, inherits only a nonvirtual run, so it
// does not implement run_if::run. A tool can report the class or its end.
// Icarus Verilog 13.0 does not support interface classes. Verilator 5.052
// reports bad_c, but it also rejects the legal ok_c, whose implementation of
// run is inherited, so its error does not count.

interface class run_if;
  pure virtual function int run();
endclass

class plain_base_c;
  function int run();
    return 1;
  endfunction
endclass

class virt_base_c;
  virtual function int run();
    return 2;
  endfunction
endclass

class ok_c extends virt_base_c implements run_if;
endclass

class bad_c extends plain_base_c implements run_if;   // illegal: run is not implemented
endclass   // (or reported here)

module test_illegal_inherited_nonvirtual_method_for_interface;
  run_if r;
  ok_c o = new;
  initial begin
    r = o;
    $display("%0d", r.run());
  end
endmodule
