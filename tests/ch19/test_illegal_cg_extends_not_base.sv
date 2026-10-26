/*
:name: test_illegal_cg_extends_not_base
:description: covergroup extends may name a covergroup only from a base class of the enclosing class, not one defined in the same class (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the extends declaration in class bad names gx, which bad itself defines instead of inheriting from a base class
:expected_stderr_regex: test_illegal_cg_extends_not_base\.sv:58:
*/
// IEEE 1800-2023 §19.4.1: when covergroup extends is used, the name shall
// have been defined previously in a base class of the enclosing class, and a
// derived covergroup may itself be the base for another class. Class good
// extends g1 of base and adds a point, and class good2 extends good and
// extends the same name again; both are legal. Class bad defines gx in its
// own body and then extends gx; that name is not defined in a base class, so
// the second declaration is the error.

module test_illegal_cg_extends_not_base;
  class base;
    int a;
    covergroup g1;
      cp: coverpoint a;
    endgroup
    function new();
      g1 = new;
    endfunction
  endclass

  class good extends base;
    int b;
    covergroup extends g1;
      extra: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class good2 extends good;
    int c;
    covergroup extends g1;
      more: coverpoint c;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class bad extends base;
    int d;
    covergroup gx;
      cp: coverpoint d;
    endgroup
    covergroup extends gx;   // illegal: gx is not in a base class
      extra: coverpoint d;
    endgroup
    function new();
      super.new();
      gx = new;
    endfunction
  endclass

  initial begin
    $display("not reached");
  end
endmodule
