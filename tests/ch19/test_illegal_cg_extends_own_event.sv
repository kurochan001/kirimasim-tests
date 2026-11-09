/*
:name: test_illegal_cg_extends_own_event
:description: A derived embedded covergroup uses the coverage event of its base covergroup and its declaration has no place for one, so covergroup extends with its own clocking event is an error (IEEE 1800-2023 Section 19.4.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.4.1 19.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the derived covergroup in class bad writes its own coverage event @(negedge clk) after covergroup extends g1
:expected_stderr_regex: test_illegal_cg_extends_own_event\.sv:49:
*/
// IEEE 1800-2023 §19.4.1: when the base covergroup has a coverage event, the
// derived covergroup shall use that event. §19.3 (Syntax 19-1): the extends
// form is covergroup extends, the name of the base covergroup and a
// semicolon; unlike the declaration of a new covergroup it has no argument
// list and no coverage event. Class good extends g1 of base, which is sampled
// at posedge clk, and adds a coverpoint; it is legal. Class bad writes
// @(negedge clk) after the name, which the extends form does not allow, and
// which would differ from the event of the base.
// Icarus Verilog 13.0 does not implement covergroups; its syntax errors fall
// on every line of the classes, including line 49, so they are no evidence for
// the rule. The 5.052 release of Verilator rejects line 49 with a syntax
// error, but it also reports the legal extends of class good as unsupported.

module test_illegal_cg_extends_own_event;
  class base;
    bit clk;
    int a, b;
    covergroup g1 @(posedge clk);
      cp: coverpoint a;
    endgroup
    function new();
      g1 = new;
    endfunction
  endclass

  class good extends base;
    covergroup extends g1;
      cb: coverpoint b;
    endgroup
    function new();
      super.new();
    endfunction
  endclass

  class bad extends base;
    covergroup extends g1 @(negedge clk);   // illegal: own coverage event
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
