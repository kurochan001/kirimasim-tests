/*
:name: test_cg_class_two_covergroups
:description: A class can declare two embedded covergroups, each with its own coverage event, sampled independently of the other (IEEE 1800-2023 Section 19.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_class_two_covergroups.expected
*/
// IEEE 1800-2023 §19.4: a class can have more than one covergroup. Here cx is
// sampled by the class event ev and covers x, and cy has no coverage event
// and covers y through sample(); both are created in the constructor.
// Triggering ev samples cx only, and cy.sample() samples cy only. Each
// coverpoint has a bin for each of its values, so the coverage of cx is the
// share of the four values of x that were sampled and that of cy the share of
// the two values of y. The test prints 1 time unit after each trigger of ev.
// Icarus Verilog 13.0 does not compile covergroups.

class two_groups;
  bit [1:0] x;
  bit y;
  event ev;

  covergroup cx @(ev);
    cp: coverpoint x { bins b[] = {[0:3]}; }
  endgroup

  covergroup cy;
    cp: coverpoint y { bins b[] = {0, 1}; }
  endgroup

  function new();
    cx = new;
    cy = new;
  endfunction
endclass

module test_cg_class_two_covergroups;
  two_groups o;

  initial begin
    o = new;
    o.x = 2;
    o.y = 1;
    -> o.ev;
    #1 $display("after ev: cx %.2f, cy %.2f", o.cx.get_inst_coverage(),
                o.cy.get_inst_coverage());
    o.x = 3;
    o.cy.sample();
    $display("after cy.sample(): cx %.2f, cy %.2f", o.cx.get_inst_coverage(),
             o.cy.get_inst_coverage());
    o.y = 0;
    -> o.ev;
    #1 $display("after ev again: cx %.2f, cy %.2f", o.cx.get_inst_coverage(),
             o.cy.get_inst_coverage());
  end
endmodule
