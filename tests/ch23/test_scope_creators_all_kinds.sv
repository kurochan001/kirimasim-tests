/*
:name: test_scope_creators_all_kinds
:description: Modules, interfaces, programs, checkers, packages, classes, tasks, functions, named and unnamed sequential and parallel blocks and generate blocks each introduce a scope, so a declaration of one name in each of them denotes a different object (IEEE 1800-2023 Section 23.9)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_creators_all_kinds.expected
*/
// IEEE 1800-2023 §23.9: modules, interfaces, programs, checkers, packages,
// classes, tasks, functions, begin-end blocks (named or unnamed), fork-join
// blocks (named or unnamed) and generate blocks each define a new scope, and an
// identifier may be declared only once in a scope. The test declares the
// same name x in every one of those scopes with a different value and prints
// each of them, so a tool that merged two of the scopes would print one
// value twice or reject the design as a duplicate declaration. The values
// are 14 in package sm_pkg, 15 as the static member of class sm_class, 12 in
// the interface bus, 13 in the program, 11 in the module instance and its
// array element, 23 in the checker, 16 in the local of function sm_f, 17 in
// the local of task
// sm_t, 19 in the generate block gen, 18 in the named block blk, 20 in an
// unnamed sequential block, and 21 and 22 in the named parallel block par
// and an unnamed parallel block inside it. The outer x of sm_top stays 1.
// The display times 5 to 10 and 20 for the program fix the order of the
// first lines. §17.5 does not allow a delay control in a checker initial
// procedure, so the checker prints x from a final procedure, which runs at the
// end of simulation and prints its line last. Icarus Verilog 13.0 does not
// support programs with items read this way or classes in this context, so
// the expected output is recorded with release 5.052 of the other simulator.

int x = 24;

package sm_pkg;
  int x = 14;
endpackage

class sm_class;
  static int x = 15;
endclass

checker sm_chk;
  int x = 23;
  final $display("checker x=%0d", x);
endchecker

interface sm_ifc;
  int x = 12;
endinterface

program sm_prog;
  int x = 13;
  initial begin
    #20 $display("program x=%0d", x);
  end
endprogram

module sm_child;
  int x = 11;
endmodule

module sm_top;
  int x = 1;
  sm_child u_child ();
  sm_ifc bus ();
  sm_prog u_prog ();
  sm_chk c_chk ();
  sm_child u_arr [2] ();

  function int sm_f ();
    int x;
    x = 16;
    return x;
  endfunction

  task sm_t ();
    int x;
    x = 17;
    $display("task x=%0d", x);
  endtask

  generate
    if (1) begin : gen
      int x = 19;
    end
  endgenerate

  initial begin : blk
    int x;
    x = 18;
    #5 $display("blk x=%0d", x);
  end

  initial begin
    int x;
    x = 20;
    #6 $display("unnamed x=%0d", x);
  end

  initial begin
    fork : par
      begin
        int x;
        x = 21;
        #7 $display("par x=%0d", x);
      end
      begin
        int x;
        x = 22;
        #8 $display("upar x=%0d", x);
      end
    join
  end

  initial begin
    #10 begin
      sm_t();
      $display("top x=%0d pkg=%0d class=%0d ifc=%0d gen=%0d child=%0d arr1=%0d fn=%0d",
               x, sm_pkg::x, sm_class::x, bus.x, gen.x, u_child.x, u_arr[1].x, sm_f());
    end
  end
endmodule
