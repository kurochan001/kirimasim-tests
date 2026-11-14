/*
:name: test_final_method_not_virtual_vpi
:description: The final specifier does not make a method virtual, so vpiVirtual is FALSE for final methods declared without virtual, both a new one and one that overrides a nonvirtual method, and TRUE for one declared virtual and final (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 37.41
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_final_method_not_virtual_vpi.c
:expected_stdout: @test_final_method_not_virtual_vpi.expected
*/
// IEEE 1800-2023 §8.20: the final specifier says that no further override of
// a method is allowed, and like initial it does not make the method virtual.
// A method is virtual when it is declared with the keyword virtual or
// overrides a virtual method. §37.41: a task or function has the property
// vpiVirtual, and §37.31 gives the methods of a class defn through
// vpiMethods.
// In leaf_c, plain is final and overrides the nonvirtual base_c::plain, and
// fresh is final and new; neither is declared virtual, so neither is
// virtual. vfinal is declared virtual and final, and other has neither.
// base_c gives two controls: the nonvirtual plain and the virtual vbase.
// Since no subclass may override a final method, which version a call runs
// does not show whether the method is virtual; the VPI application
// $vt_method_virtual_flags prints, for each class defn, the name and the
// vpiVirtual flag of each method, sorted by name. An implementation in which
// final made a method virtual would print virtual 1 for fresh and plain of
// leaf_c. The first line shows that the methods run, and that a base_c
// handle that holds a leaf_c object calls the nonvirtual base_c::plain.
// Icarus Verilog 13.0 does not support the final specifier, and the 5.054
// release of Verilator does not know the system task of the VPI application,
// so the expected output follows the cited clauses alone.

module test_final_method_not_virtual_vpi;
  class base_c;
    function int plain();
      return 1;
    endfunction
    virtual function int vbase();
      return 2;
    endfunction
  endclass

  class leaf_c extends base_c;
    function :final int plain();
      return 10;
    endfunction
    function :final int fresh();
      return 30;
    endfunction
    virtual function :final int vfinal();
      return 40;
    endfunction
    function int other();
      return 50;
    endfunction
  endclass

  leaf_c l;
  base_c b;

  initial begin
    l = new;
    b = l;
    $display("calls: plain=%0d fresh=%0d vfinal=%0d other=%0d vbase=%0d base_c plain=%0d",
             l.plain(), l.fresh(), l.vfinal(), l.other(), l.vbase(), b.plain());
    #1 $vt_method_virtual_flags;
  end
endmodule
