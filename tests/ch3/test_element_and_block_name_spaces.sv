/*
:name: test_element_and_block_name_spaces
:description: Each module, interface and package has its own name space for all its kinds of items, and named blocks, unnamed blocks, functions, tasks and specify blocks each have a local name space, so the same names can be declared in each of them (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_element_and_block_name_spaces.expected
*/
// IEEE 1800-2023 §3.13 e): a module, interface, package, program, checker or
// primitive introduces a name space that unifies its modules, interfaces,
// programs, checkers, functions, tasks, named blocks, instances, parameters,
// named events, nets, variables and user-defined types. §3.13 f): named and
// unnamed blocks, specify blocks, functions and tasks introduce a block name
// space for their own blocks, subroutines, parameters, events, variables and
// types.
// The modules space_a and space_b, the interface space_if and the package
// space_pkg each declare a parameter P, a type T, a variable v, a net n, an
// event e, a function f, a task t, a named block blk and, in the modules, an
// instance u, all with the same names but different values. Each one prints
// the values it sees. In the test module, the name x is declared in the
// module, in a named block, in an unnamed block, in a function, in a task
// and as a specparam of a specify block; each reference sees its own x.

package space_pkg;
  parameter int P = 30;
  typedef byte T;
  T v = 31;
  function automatic int f();
    return 32;
  endfunction
endpackage

module space_leaf #(parameter int V = 0);
  int value = V;
endmodule

interface space_if;
  parameter int P = 40;
  typedef shortint T;
  T v = 41;
  wire [7:0] n = 8'd42;
  event e;
  function automatic int f();
    return 43;
  endfunction
  task automatic t(output int o);
    o = 44;
  endtask
endinterface

module space_a;
  parameter int P = 10;
  typedef int T;
  T v = 11;
  wire [7:0] n = 8'd12;
  event e;
  space_leaf #(.V(13)) u();
  function automatic int f();
    return 14;
  endfunction
  task automatic t(output int o);
    o = 15;
  endtask
  initial begin : blk
    int r;
    t(r);
    #1 $display("space_a: P=%0d $bits(T)=%0d v=%0d n=%0d u=%0d f=%0d t=%0d", P, $bits(T), v, n,
                u.value, f(), r);
  end
endmodule

module space_b;
  parameter int P = 20;
  typedef longint T;
  T v = 21;
  wire [7:0] n = 8'd22;
  event e;
  space_leaf #(.V(23)) u();
  function automatic int f();
    return 24;
  endfunction
  task automatic t(output int o);
    o = 25;
  endtask
  initial begin : blk
    int r;
    t(r);
    #2 $display("space_b: P=%0d $bits(T)=%0d v=%0d n=%0d u=%0d f=%0d t=%0d", P, $bits(T), v, n,
                u.value, f(), r);
  end
endmodule

module test_element_and_block_name_spaces;
  int x = 1;
  int fx, tx;

  space_a a();
  space_b b();
  space_if i();

  function automatic int read_x();
    int x = 4;
    return x;
  endfunction

  task automatic take_x(output int o);
    int x = 5;
    o = x;
  endtask

  specify
    specparam x = 6;
  endspecify

  initial begin
    int r;
    #3;
    begin : named
      static int x = 2;
      $display("named block x=%0d", x);
    end
    begin
      static int x = 3;
      $display("unnamed block x=%0d", x);
    end
    take_x(tx);
    $display("function x=%0d task x=%0d module x=%0d", read_x(), tx, x);
    i.t(r);
    $display("space_if: P=%0d $bits(T)=%0d v=%0d n=%0d f=%0d t=%0d", i.P, $bits(i.v), i.v, i.n,
             i.f(), r);
    $display("space_pkg: P=%0d $bits(T)=%0d v=%0d f=%0d", space_pkg::P, $bits(space_pkg::T),
             space_pkg::v, space_pkg::f());
  end
endmodule
