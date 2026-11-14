/*
:name: test_function_declaration_scoped_and_override_forms
:description: function declarations named through an interface port or a class scope, and class methods with the dynamic override specifiers initial, extends and final, are declared and called with the right results (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_declaration_scoped_and_override_forms.expected
*/
// IEEE 1800-2023 13.4 (Syntax 13-2): the name of a declared function may be
// preceded by an interface identifier and a dot or by a class scope, and the
// keyword function may be followed by dynamic override specifiers when the
// function is a method of a class that is not an interface class.
//
// The module fdecl_provider defines the function exported by the modport
// prov of its interface port p as p.scaled; fdecl_user calls it through the
// modport usr, which imports it: scaled(5) = 15. The class shape declares
// area as extern and the module defines it with the class scope shape::,
// so a 4-sided shape has area 16. square extends shape: kind is declared
// with :extends and overrides the virtual shape::kind, so a shape handle to
// a square calls it and gets 2 instead of 1; extra is a new virtual method
// declared with :initial :final and returns 30.
//
// Icarus Verilog 13.0 does not support functions in modport lists.

interface fdecl_if;
  modport prov(export function int scaled(int v));
  modport usr(import function int scaled(int v));
endinterface

module fdecl_provider(fdecl_if.prov p);
  function int p.scaled(int v);
    return v * 3;
  endfunction : scaled
endmodule

module fdecl_user(fdecl_if.usr u);
  initial $display("interface port function: %0d", u.scaled(5));
endmodule

module test_function_declaration_scoped_and_override_forms;
  class shape;
    int side;
    function new(int s);
      side = s;
    endfunction
    extern function int area();
    virtual function int kind();
      return 1;
    endfunction
  endclass

  function int shape::area();
    return side * side;
  endfunction : area

  class square extends shape;
    function new(int s);
      super.new(s);
    endfunction
    virtual function :extends int kind();
      return 2;
    endfunction : kind
    virtual function :initial :final int extra();
      return 30;
    endfunction
  endclass

  fdecl_if bus();
  fdecl_provider prov_inst(bus.prov);
  fdecl_user user_inst(bus.usr);

  shape h;
  square sq;

  initial begin
    #1;
    sq = new(4);
    h = sq;
    $display("class scope: area=%0d", h.area());
    $display(":extends: kind=%0d", h.kind());
    $display(":initial :final: extra=%0d", sq.extra());
  end
endmodule
