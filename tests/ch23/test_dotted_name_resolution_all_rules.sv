/*
:name: test_dotted_name_resolution_all_rules
:description: A dotted name resolves its first component as a simple identifier, so a data object gives a member select, a directly visible scope gives a hierarchical name, an imported scope name resolves under its package, and an unresolved first component is treated as a hierarchical name (IEEE 1800-2023 Section 23.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dotted_name_resolution_all_rules.expected
*/
// IEEE 1800-2023 §23.7: a dotted name is a member select or a hierarchical
// name, and which one is decided by resolving its first component as though
// it were a simple identifier at the point where the name appears: a data
// object or interface port gives a member select, a directly visible scope
// name gives a hierarchical name, an imported scope name gives a
// hierarchical name prefixed by the package it came from, and a name that
// is not found is treated as a hierarchical name. The test follows the
// example of §23.7. Inside the generate block s1, which declares an int x,
// the name s1.x (s1 is a directly visible scope) reads that block's own x,
// 1; s2.x reads the member x of the structure s2 imported from package dp
// (s2 is a data object); the block's module instance s2 is declared after
// the initial block and is not visible at the point of appearance, so it
// does not make s2.x a hierarchical name, and a wrong implementation that
// used it would read its x = 8; t.x names the imported task t, so it is the
// hierarchical name dp::t.x and reads the static local x that t set to 3;
// and in module dchild the name sib.x is not a simple identifier at that
// point, so it is treated as a hierarchical name and finds the instance sib
// of the enclosing module dtop, whose x is 8. A tool that decided the kind
// from anything but the first component would read 8 for s2.x or fail to
// find t.x or sib.x. The display times 1 and 4 fix the order of the lines.

package dp;
  typedef struct packed { int x; } dp_st;
  dp_st s2;

  task t;
    static int x;
    x = 3;
  endtask
endpackage

module dsome;
  int x = 8;
endmodule

module dchild;
  initial begin
    #4 $display("upward sib.x=%0d", sib.x);
  end
endmodule

module dtop;
  import dp::*;
  dsome sib ();
  dchild u_child ();

  if (1) begin : s1
    int x;
    initial begin
      #1 begin
        s1.x = 1;
        s2.x = 2;
        t();
        $display("scope s1.x=%0d object s2.x=%0d imported t.x=%0d", s1.x, s2.x, t.x);
      end
    end
    dsome s2 ();
  end
endmodule
