/*
:name: test_program_contains_permitted_items
:description: A program between program and endprogram holds data declarations, a class definition, a class object, a function and a task, two initial procedures and a final procedure; its data and subroutines belong to the program scope, apart from the same names in the module (IEEE 1800-2023 Section 3.4)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.4 24.3 9.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_contains_permitted_items.expected
*/
// IEEE 1800-2023 §3.4, §24.3: a program, enclosed by program and endprogram,
// can contain data declarations, class definitions, subroutine definitions,
// object instances and one or more initial or final procedures, and its data
// and subroutines are local to the program scope.
// prog_items declares an int, a typedef and a variable of that structure, the
// class box_c and an object of it made by new, the function scale and the
// task bump, two initial procedures and a final procedure. The module that
// instantiates it declares its own count and scale with other values, and
// each scope uses its own: the module prints its count 1000 and its
// scale(2) = 1002 at time 1; the program adds 4 to its count 3 in bump and
// prints count 7, its scale(2) = 20, box.twice() = 42 and pr.a + pr.b = 9 at
// time 3. The second initial procedure prints at time 5; then both initial
// procedures of the program have ended, the simulation ends (§24.3), and the
// final procedure (§9.2.3) prints the count of the program.

`timescale 1ns/1ns

module test_program_contains_permitted_items;
  int count = 1000;

  function automatic int scale(int v);
    return v + 1000;
  endfunction

  prog_items p();

  initial #1 $display("t=%0t module: count=%0d scale(2)=%0d", $time, count, scale(2));
endmodule

program prog_items;
  int count = 3;
  typedef struct packed { int a; int b; } pair_t;
  pair_t pr = '{4, 5};

  class box_c;
    int v;

    function new(int v0);
      v = v0;
    endfunction

    function int twice();
      return 2 * v;
    endfunction
  endclass

  box_c box = new(21);

  function automatic int scale(int v);
    return v * 10;
  endfunction

  task automatic bump(input int by);
    #1 count += by;
  endtask

  initial begin
    #2 bump(4);
    $display("t=%0t program: count=%0d scale(2)=%0d box.twice()=%0d pr.a+pr.b=%0d",
             $time, count, scale(2), box.twice(), pr.a + pr.b);
  end

  initial #5 $display("t=%0t program: second initial procedure", $time);

  final $display("program final: count=%0d", count);
endprogram : prog_items
