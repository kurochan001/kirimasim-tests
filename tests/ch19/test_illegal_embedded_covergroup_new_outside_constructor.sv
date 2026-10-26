/*
:name: test_illegal_embedded_covergroup_new_outside_constructor
:description: An embedded covergroup instance may be assigned new only in the constructor of its parent class, so creating it again in another method is an error (IEEE 1800-2023 Section 19.4)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: reset assigns new to the embedded covergroup cg outside the constructor new
:expected_stderr_regex: test_illegal_embedded_covergroup_new_outside_constructor\.sv:33:
*/
// IEEE 1800-2023 §19.4: an embedded covergroup may be created by assigning
// the result of new to its instance variable in the new method of its parent
// class. The covergroup variable shall not be assigned outside that
// constructor. The constructor of c_emb creates cg and is legal. The method
// reset assigns new to cg again and is illegal, even though it would replace
// the existing instance.

class c_emb;
  int x;

  covergroup cg;
    coverpoint x;
  endgroup

  function new();
    cg = new;
  endfunction

  function void reset();
    cg = new;   // illegal: outside the constructor
  endfunction
endclass

module test_illegal_embedded_covergroup_new_outside_constructor;
  c_emb o = new;

  initial begin
    o.reset();
    $display("ok");
  end
endmodule
