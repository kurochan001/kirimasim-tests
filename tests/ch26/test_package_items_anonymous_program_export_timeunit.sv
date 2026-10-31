/*
:name: test_package_items_anonymous_program_export_timeunit
:description: a package holds declarations, an anonymous program with a task, a function, a class, an interface class, a covergroup, an out-of-block constructor and an empty item, an export of an imported name, and a repeated matching timeunit declaration; a program uses all of them (IEEE 1800-2023 Sections 26.2, 24.6, A.1.11)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 24.6 A.1.11 26.6 3.14.2.2 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_items_anonymous_program_export_timeunit.expected
*/
// IEEE 1800-2023 §26.2 and A.1.11: an item of a package can be a declaration,
// an anonymous program, a package export declaration, or a timeunits
// declaration that repeats and matches the earlier one of the same time scope
// (A.10 note 3, §3.14.2.2). An anonymous program is the keyword program and a
// semicolon, any number of items, and endprogram; an item is a task, a
// function, a class, an interface class, a covergroup, a class constructor
// declaration, or a semicolon. §24.6: its items belong to the namespace of the
// package without a scope of their own and can be used from programs, so the
// program imports them from pk_prog.
// - export pk_base::base_val makes the imported base_val (40) visible to an
//   importer of pk_prog (§26.6);
// - pk_prog has time unit 1 ns and precision 10 ps, so the #1.25 of its task
//   wait_pkg lasts 1250 ps, which $time of the program (unit 1 ps) shows;
//   with the program's own unit the delay would round to 1 ps;
// - ap_accumulate adds to an inout argument, ap_cube returns x*x*x;
// - ApBox's constructor, defined outside the class within the anonymous
//   program, stores 10 times its argument;
// - ApSquare implements the interface class ApShape;
// - ap_cg has two bins, one of which sample(1) hits: 50.00 percent (§19.11).
// Neither Icarus Verilog 13.0 nor the other release supports anonymous
// programs.

`timescale 1ps/1ps

package pk_base;
  int base_val = 40;
endpackage

package pk_prog;
  timeunit 1ns / 10ps;

  import pk_base::base_val;
  export pk_base::base_val;

  int pkg_calls = 0;

  timeunit 1ns / 10ps;

  task automatic wait_pkg();
    pkg_calls++;
    #1.25;
  endtask

  program;
    task automatic ap_accumulate(inout int acc, input int v);
      acc += v;
    endtask

    function automatic int ap_cube(int x);
      return x * x * x;
    endfunction

    class ApBox;
      int v;
      extern function new(int v);
      function int get();
        return v;
      endfunction
    endclass

    interface class ApShape;
      pure virtual function int area();
    endclass

    class ApSquare implements ApShape;
      int side;
      function new(int s);
        side = s;
      endfunction
      virtual function int area();
        return side * side;
      endfunction
    endclass

    covergroup ap_cg with function sample(int v);
      coverpoint v {
        bins b0 = {0};
        bins b1 = {1};
      }
    endgroup

    function ApBox::new(int v);
      this.v = 10 * v;
    endfunction

    ;
  endprogram
endpackage

program test_package_items_anonymous_program_export_timeunit;
  import pk_prog::*;

  initial begin
    static int acc = 5;
    ApBox box;
    ApSquare sq;
    ApShape sh;
    ap_cg cg;

    $display("base_val=%0d", base_val);
    ap_accumulate(acc, 7);
    $display("acc=%0d cube=%0d", acc, ap_cube(3));
    box = new(4);
    sq = new(6);
    sh = sq;
    $display("box=%0d area=%0d", box.get(), sh.area());
    cg = new;
    cg.sample(1);
    $display("coverage=%0.2f", cg.get_inst_coverage());
    wait_pkg();
    $display("time=%0d calls=%0d", $time, pkg_calls);
  end
endprogram
