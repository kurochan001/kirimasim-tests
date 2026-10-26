/*
:name: test_hierarchy_branches_syntax_and_uses
:description: Instance arrays, generate blocks, tasks, functions, named sequential and parallel blocks and named assertion action blocks create hierarchy branches, hierarchical names use periods, constant instance selects, a $root prefix and a terminated escaped identifier, and a lower level reads, writes, triggers and calls through them (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchy_branches_syntax_and_uses.expected
*/
// IEEE 1800-2023 §23.6: a module instance, an arrayed instance, a generate
// block instance, a task, a function, a named begin-end block, a named
// fork-join block and a named assertion action block each define a branch of
// the hierarchy, and their names are joined by periods; an instance array
// element is selected with a constant expression in brackets; $root starts
// at the top of the instantiation tree; an escaped identifier inside a path
// is terminated by white space before the period. A hierarchical name can be
// read, written, triggered and used to reference a subroutine from any level
// of the hierarchy. In hb_top the branches are u_arr[0] and u_arr[1] of the
// arrayed instance, the generate loop block g with its item gv, the named
// blocks seq and par with the nested fork block inner, the assertion label
// A1 with its action block act, and the task bump and function get of
// hb_child. The instance \esc_child is named with an escaped identifier and
// is read as "\esc_child .v". The module hb_low, instantiated below hb_top,
// writes $root.hb_top.v, triggers the event of u_one, calls the task bump
// and the function get of u_one, and reads u_one.v and u_one.hits, so every
// use comes from a lower level. The generate block that holds u_sib and
// u_in is written without a label; its items can be referenced from u_in,
// a hierarchy instantiated by the block, which reads the sibling u_sib.v.
// The block also declares its own gv = 7, while hb_top declares gv = 100;
// a reference to gv outside the block reads 100, so the block's item is not
// visible in the enclosing scope. The display times 2, 3, 30, 31, 32, 33 and
// 40 fix the order of the lines.
// Icarus Verilog 13.0 has neither $root nor concurrent assertions, so the
// expected output is recorded with Verilator 5.052.

module hb_child;
  int v = 5;
  event e;
  int hits = 0;
  always @(e) hits++;
  task bump;
    v = v + 1;
  endtask
  function int get();
    return v;
  endfunction
endmodule

module hb_sibling;
  int v = 7;
endmodule

module hb_in_unnamed;
  initial begin
    #3 $display("unnamed sibling=%0d", u_sib.v);
  end
endmodule

module hb_low;
  initial begin
    #1 begin
      $root.hb_top.v = 42;
      -> $root.hb_top.u_one.e;
      $root.hb_top.u_one.bump();
    end
    #1 $display("low read=%0d hits=%0d fn=%0d v=%0d", $root.hb_top.u_one.v,
                $root.hb_top.u_one.hits, $root.hb_top.u_one.get(), $root.hb_top.v);
  end
endmodule

module hb_top;
  int v = 1;
  int gv = 100;
  logic clk = 0;
  logic a = 0;
  hb_child u_one ();
  hb_child u_arr [2] ();
  hb_child \esc_child ();
  hb_low u_low ();

  generate
    for (genvar i = 0; i < 2; i = i + 1) begin : g
      int gv = i + 10;
    end
  endgenerate

  generate
    if (1) begin
      int gv = 7;
      hb_sibling u_sib ();
      hb_in_unnamed u_in ();
    end
  endgenerate

  always #1 clk = ~clk;

  A1: assert property (@(posedge clk) a) else begin : act
    int av;
    av = 1;
  end

  initial begin : seq
    #30 $display("seq v=%0d esc=%0d g=%0d%0d arr=%0d", v, \esc_child .v,
                 g[0].gv, g[1].gv, u_arr[1].v);
    #3 $display("unnamed outer gv=%0d", gv);
  end

  initial begin : par
    fork : inner
      begin
        #31 $display("inner %m");
      end
      begin
        #32 $display("inner2");
      end
    join
  end

  initial begin
    #40 begin
      $display("act av=%0d", A1.act.av);
      $finish;
    end
  end
endmodule
