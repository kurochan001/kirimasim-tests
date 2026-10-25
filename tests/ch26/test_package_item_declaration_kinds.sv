/*
:name: test_package_item_declaration_kinds
:description: a package holds net, variable, task, function, class, interface class, out-of-block constructor, external constraint, localparam, parameter and empty items, and a module uses each of them through an import (IEEE 1800-2023 Sections 26.2, A.1.11)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 A.1.11 18.5.1 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_item_declaration_kinds.expected
*/
// IEEE 1800-2023 §26.2 and A.1.11: an item of a package can be a net
// declaration, a data declaration, a task, a function, a class, an interface
// class, a class constructor declaration, an external constraint declaration,
// a localparam or parameter declaration followed by a semicolon, or a lone
// semicolon. Each kind appears in pk_items and is used from the module:
// - the net has no continuous assignment in the package (§26.2 forbids one
//   there); the module drives it and reads it back one time unit later;
// - the variables are initialized before any initial procedure starts (§26.2);
// - bump is a task with an inout argument, twice a function;
// - the parameter PP is computed from the localparam LP;
// - Tag implements the interface class Named and is called through it;
// - the constructor of Item is defined outside the class (§8.24), and its
//   explicit constraint prototype is completed by a constraint block outside
//   the class (§18.5.1), so randomize() can only give x = base + 1.

package pk_items;
  wire [7:0] shared;
  int counter = 7, step = 2;

  task automatic bump(inout int v, input int by);
    v += by;
  endtask

  function automatic int twice(int v);
    return 2 * v;
  endfunction

  ;

  localparam int LP = 11;
  parameter int PP = LP + 1;

  interface class Named;
    pure virtual function string name();
  endclass

  class Tag implements Named;
    virtual function string name();
      return "tag";
    endfunction
  endclass

  class Item;
    rand int x;
    int base;
    extern function new(int b);
    extern constraint c_fix;
  endclass

  function Item::new(int b);
    base = 3 * b;
  endfunction

  constraint Item::c_fix { x == base + 1; }
endpackage

module test_package_item_declaration_kinds;
  import pk_items::*;

  assign shared = 8'h5a;

  initial begin
    int v;
    int ok;
    Tag t;
    Named n;
    Item it;

    #1 $display("shared=%h", shared);
    v = counter;
    bump(v, step);
    $display("counter=%0d step=%0d bumped=%0d", counter, step, v);
    $display("twice(5)=%0d LP=%0d PP=%0d", twice(5), LP, PP);
    t = new;
    n = t;
    $display("name=%s", n.name());
    it = new(4);
    ok = it.randomize();
    $display("randomize=%0d base=%0d x=%0d", ok, it.base, it.x);
  end
endmodule
