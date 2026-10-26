/*
:name: test_illegal_cg_extends_outside_class
:description: the extends form of a covergroup is allowed only within a class (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module-level covergroup extends base_cg is not inside a class
:expected_stderr_regex: test_illegal_cg_extends_outside_class\.sv:48:
*/
// IEEE 1800-2023 §19.3: the extends variation of covergroup declaration is
// allowed only for a covergroup defined within a class. The base covergroup
// base_cg at module scope is legal, and the derived class below extends the
// covergroup g1 of its base class, which is legal. The second extends at
// module scope is the one error: an extends declaration has no place outside
// a class.

module test_illegal_cg_extends_outside_class;
  int x, y, z;

  covergroup base_cg;
    cp: coverpoint x;
  endgroup

  class base;
    int a;
    covergroup g1;
      cp: coverpoint a;
    endgroup
    function new();
      g1 = new;
    endfunction
  endclass

  class derived extends base;
    int b;
    covergroup extends g1;
      extra: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  covergroup extends base_cg;   // illegal: extends outside a class
    cp2: coverpoint z;
  endgroup

  initial begin
    $display("not reached");
  end
endmodule
