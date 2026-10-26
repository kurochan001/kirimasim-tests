/*
:name: test_illegal_covergroup_derived_base_local
:description: A derived embedded covergroup may inherit the coverage model of a local member of the base class, but shall not define a new coverage point for that local member (IEEE 1800-2023 Section 19.4)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the derived covergroup adds a coverpoint for the base member secret, which is local to c_base
:expected_stderr_regex: test_illegal_covergroup_derived_base_local\.sv:40:
*/
// IEEE 1800-2023 §19.4: an embedded covergroup can define a coverage model
// for protected and local members of its class without changing the
// encapsulation. A derived covergroup in a derived class may inherit a
// coverage model for base-local members, but it shall not define a new
// coverage model for them. The base covergroup cg covers the local secret and
// is legal. The derived covergroup extends cg and adds a new coverpoint for
// secret; that reference is not accessible in the derived class, and the new
// model for the base-local member is illegal.

class c_base;
  local int secret;
  int own;

  covergroup cg;
    coverpoint secret;
    coverpoint own;
  endgroup

  function new();
    cg = new;
  endfunction
endclass

class c_derived extends c_base;
  covergroup extends cg;
    own_new: coverpoint own;
    coverpoint secret;   // illegal: new coverage of base-local member
  endgroup : cg

  function new();
    super.new();
  endfunction
endclass

module test_illegal_covergroup_derived_base_local;
  c_derived o = new;

  initial begin
    o.cg.sample();
    $display("ok");
  end
endmodule
