/*
:name: test_a2_7_dynamic_override_specifiers
:description: The dynamic override specifiers initial, extends and final mark the declarations of a new override chain, of an override of a virtual task and of a task no subclass may override, and virtual dispatch still reaches the right task (IEEE 1800-2023 Sections 8.13 and 13.3, A.2.7 and A.10)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 8.13 A.2.7 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a2_7_dynamic_override_specifiers.expected
*/
// IEEE 1800-2023 A.2.7, clarification 25: the dynamic override specifiers are
// legal on a method declaration inside a non-interface class. They are the
// optional ": initial" or ": extends" followed by the optional ": final", and
// 8.13 Example 3 gives their meaning: ": initial" marks a method that does not
// override a virtual method, ": extends" marks one that does, and ": final"
// marks one that no subclass may override.
//
// base has the virtual tasks t_virt and t_final, each printing its own name.
// derived extends base and declares t_virt with ": extends", t_final with
// ": extends : final", which is the order of A.2.7, and the new task t_new
// with ": initial". Calls through a base handle and through a derived handle
// print the derived texts, which shows that a declaration with a specifier
// still takes part in virtual dispatch.

`timescale 1ns/1ns
module test_a2_7_dynamic_override_specifiers;
  class base;
    virtual task t_virt;
      $display("base t_virt");
    endtask

    virtual task t_final;
      $display("base t_final");
    endtask
  endclass

  class derived extends base;
    virtual task :extends t_virt;
      $display("derived t_virt");
    endtask

    virtual task :extends :final t_final;
      $display("derived t_final");
    endtask

    task :initial t_new;
      $display("derived t_new");
    endtask
  endclass

  base h;
  derived d;

  initial begin
    d = new;
    h = d;
    h.t_virt;
    h.t_final;
    d.t_new;
  end
endmodule
