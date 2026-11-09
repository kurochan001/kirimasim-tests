/*
:name: test_illegal_cg_extends_own_arguments
:description: A derived embedded covergroup implicitly has the argument list of its base covergroup and its declaration has no place for one, so covergroup extends with its own argument list is an error (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1 19.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the derived covergroup in class bad writes the argument list (int hi) after covergroup extends g1
:expected_stderr_regex: test_illegal_cg_extends_own_arguments\.sv:48:
*/
// IEEE 1800-2023 §19.4.1: a derived covergroup implicitly has the argument
// list of its base covergroup. §19.3 (Syntax 19-1): the extends form is
// covergroup extends, the name of the base covergroup and a semicolon,
// without the argument list that the declaration of a new covergroup may
// have. Class good extends g1, whose argument lo is used by the new
// coverpoint of the derived covergroup; it is legal. Class bad writes its own
// argument list (int hi) after the name, which the extends form does not
// allow.
// Icarus Verilog 13.0 does not implement covergroups; its syntax errors fall
// on every line of the classes, including line 48, so they are no evidence for
// the rule. The 5.052 release of Verilator rejects line 48 with a syntax
// error, but it also reports the legal extends of class good as unsupported.

module test_illegal_cg_extends_own_arguments;
  class base;
    int a, b;
    covergroup g1 (int lo);
      cp: coverpoint a { bins low = {[lo:lo + 3]}; }
    endgroup
    function new();
      g1 = new(0);
    endfunction
  endclass

  class good extends base;
    covergroup extends g1;
      cb: coverpoint b { bins from_lo = {[lo:$]}; }
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class bad extends base;
    covergroup extends g1 (int hi);   // illegal: own argument list
      cb: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  initial begin
    $display("not reached");
  end
endmodule
