/*
:name: test_named_block_hier_write
:description: Hierarchical writes to variables of a named block, and a force on such a variable (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.4 23.6 10.4.2 10.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_block_hier_write.expected
*/
// IEEE 1800-2023 §9.3.4, §23.6: a named block is a scope whose variables can be
// reached from outside with a hierarchical name. Blocking and nonblocking writes
// through such a name, short or starting from the module, change the block's
// own variable, and the block sees the new values. §10.6.2: while a variable is
// forced, a procedural assignment to it has no effect.

module test_named_block_hier_write;
  int errors = 0;
  int q = 3;                       // a module variable that nothing writes

  task automatic check(string name, logic [31:0] got, logic [31:0] exp);
    if (got !== exp) begin
      errors++;
      $display("CHECK-FAIL %s: got=%0d exp=%0d", name, got, exp);
    end
  endtask

  // The block that owns the variables checks their values itself.
  initial begin : blk
    static int x = 1;
    static int y = 1;
    static int z = 1;
    #3;
    check("blk_x_block", x, 5);
    check("blk_y_nba_block", y, 6);
    check("blk_z_full_name_block", z, 7);
  end

  // Another process writes them through hierarchical names and reads them back.
  initial begin
    #1;
    blk.x = 5;                                 // blocking
    blk.y <= 6;                                // nonblocking
    test_named_block_hier_write.blk.z = 7;     // name starting from the module
    check("blk_x_read", blk.x, 5);
    #2;
    check("blk_y_nba_read", blk.y, 6);
    check("blk_z_full_name_read", test_named_block_hier_write.blk.z, 7);
    check("q_untouched", q, 3);
  end

  // A forced variable of a named block keeps the forced value.
  initial begin : fblk
    static int g = 0;
    #7;
    check("force_g_block", g, 8);
  end
  initial begin
    #5;
    force test_named_block_hier_write.fblk.g = 8;
    #1;
    fblk.g = 2;                      // no effect while forced
    #4;
    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED (%0d errors)", errors);
    $finish;
  end
endmodule
