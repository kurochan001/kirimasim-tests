/*
:name: test_assignment_forms
:description: Assignment forms: blocking, nonblocking, force/release, concatenation and part-select targets
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.3 7.4 9.2.2.4 10.4.2 10.6.2 11.4.12 11.5.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assignment_forms.expected
*/
// IEEE 1800-2023 assignment forms
// Sections: §10.4.2 (NBA), §10.6.2 (force/release), §11.5.1 (bit/part select),
//           §7.2 (packed struct), §7.3 (packed union), §11.4.12 (concatenation LHS)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_assignment_forms;

  typedef struct packed {
    logic [7:0] high;
    logic [7:0] low;
  } pair_t;

  typedef union packed {
    logic [15:0] word;
    pair_t fields;
  } overlay_t;

  logic clk = 0;
  always #5 clk = ~clk;

  // Signals for NBA tests
  logic [7:0] nba_var;
  logic [7:0] nba_arr [0:3];
  pair_t nba_struct;
  logic [15:0] nba_wide;
  logic [7:0] force_sig;
  logic [7:0] part_sel_sig;

  int pass_count = 0;
  int total_tests = 25;

  // Test signals for always_ff
  logic [7:0] ff_out;
  logic [7:0] ff_in;

  always_ff @(posedge clk) begin
    ff_out <= ff_in;
  end

  initial begin

    // Test 1: NBA simple variable (§10.4.2)
    @(posedge clk);
    nba_var <= 8'hAB;
    @(posedge clk);
    if (nba_var == 8'hAB) begin
      $display("PASS: Test 1 - NBA simple variable");
      pass_count++;
    end else $display("FAIL: Test 1 - NBA simple (got %h)", nba_var);

    // Test 2: NBA array element (§10.4.2)
    nba_arr[2] <= 8'hCD;
    @(posedge clk);
    if (nba_arr[2] == 8'hCD) begin
      $display("PASS: Test 2 - NBA array element");
      pass_count++;
    end else $display("FAIL: Test 2 - NBA array (got %h)", nba_arr[2]);

    // Test 3: NBA struct member (§10.4.2)
    nba_struct.high <= 8'hEF;
    nba_struct.low <= 8'h01;
    @(posedge clk);
    if (nba_struct.high == 8'hEF && nba_struct.low == 8'h01) begin
      $display("PASS: Test 3 - NBA struct member");
      pass_count++;
    end else $display("FAIL: Test 3 - NBA struct (got %h,%h)", nba_struct.high, nba_struct.low);

    // Test 4: Bit-select assignment (§11.5.1)
    begin
      static logic [7:0] val = 8'h00;
      val[3] = 1'b1;
      val[7] = 1'b1;
      if (val == 8'b1000_1000) begin
        $display("PASS: Test 4 - Bit-select assignment");
        pass_count++;
      end else $display("FAIL: Test 4 - Bit-select (got %b)", val);
    end

    // Test 5: Part-select assignment (§11.5.1)
    begin
      static logic [15:0] val = 16'h0000;
      val[11:8] = 4'hA;
      if (val == 16'h0A00) begin
        $display("PASS: Test 5 - Part-select assignment");
        pass_count++;
      end else $display("FAIL: Test 5 - Part-select (got %h)", val);
    end

    // Test 6: Indexed part-select +: (§11.5.1)
    begin
      static logic [31:0] val = 32'hDEADBEEF;
      val[8 +: 8] = 8'hFF;
      if (val == 32'hDEADFFEF) begin
        $display("PASS: Test 6 - Indexed part-select +: assignment");
        pass_count++;
      end else $display("FAIL: Test 6 - Part-select +: (got %h)", val);
    end

    // Test 7: Indexed part-select -: (§11.5.1)
    begin
      static logic [31:0] val = 32'hDEADBEEF;
      val[15 -: 8] = 8'h00;
      if (val == 32'hDEAD00EF) begin
        $display("PASS: Test 7 - Indexed part-select -: assignment");
        pass_count++;
      end else $display("FAIL: Test 7 - Part-select -: (got %h)", val);
    end

    // Test 8: force signal (§10.6.2)
    force_sig = 8'h55;
    #1;
    force force_sig = 8'hAA;
    #1;
    if (force_sig == 8'hAA) begin
      $display("PASS: Test 8 - force signal");
      pass_count++;
    end else $display("FAIL: Test 8 - force (got %h)", force_sig);

    // Test 9: release signal (§10.6.2)
    release force_sig;
    force_sig = 8'h33;
    #1;
    if (force_sig == 8'h33) begin
      $display("PASS: Test 9 - release signal accepts new value");
      pass_count++;
    end else $display("FAIL: Test 9 - release (got %h)", force_sig);

    // Test 10: force overrides normal assignment (§10.6.2)
    begin
      logic [7:0] f_val;
      f_val = 8'h11;
      force f_val = 8'h22;
      f_val = 8'h33;  // should be ignored while forced
      #1;
      if (f_val == 8'h22) begin
        $display("PASS: Test 10 - force overrides normal assign");
        pass_count++;
      end else $display("FAIL: Test 10 - force override (got %h)", f_val);
      release f_val;
    end

    // Test 11: Variable index bit-select (§11.5.1)
    begin
      static logic [7:0] val = 8'b0000_0000;
      static int idx = 5;
      val[idx] = 1'b1;
      if (val == 8'b0010_0000) begin
        $display("PASS: Test 11 - Variable index bit-select");
        pass_count++;
      end else $display("FAIL: Test 11 - Var bit-select (got %b)", val);
    end

    // Test 12: Multiple NBA same signal - last wins (§10.4.2)
    nba_var <= 8'h11;
    nba_var <= 8'h22;
    nba_var <= 8'h33;
    @(posedge clk);
    if (nba_var == 8'h33) begin
      $display("PASS: Test 12 - Multiple NBA last wins");
      pass_count++;
    end else $display("FAIL: Test 12 - Multi NBA (got %h)", nba_var);

    // Test 13: LHS concatenation assignment (§11.4.12)
    begin
      logic [3:0] a, b;
      {a, b} = 8'hA5;
      if (a == 4'hA && b == 4'h5) begin
        $display("PASS: Test 13 - LHS concatenation {a,b} = 8'hA5");
        pass_count++;
      end else $display("FAIL: Test 13 - LHS concat (a=%h, b=%h)", a, b);
    end

    // Test 14: Packed struct field assignment (§7.2)
    begin
      pair_t p;
      p.high = 8'hDE;
      p.low = 8'hAD;
      if (p == 16'hDEAD) begin
        $display("PASS: Test 14 - Packed struct field assignment");
        pass_count++;
      end else $display("FAIL: Test 14 - Packed struct (got %h)", p);
    end

    // Test 15: Packed union field assignment (§7.3)
    begin
      overlay_t u;
      u.word = 16'hFFFF;
      u.fields.low = 8'h00;
      if (u.word == 16'hFF00) begin
        $display("PASS: Test 15 - Packed union field assignment");
        pass_count++;
      end else $display("FAIL: Test 15 - Packed union (got %h)", u.word);
    end

    // Test 16: 2D array access (§7.4)
    begin
      int arr[2][3];
      arr[1][2] = 42;
      if (arr[1][2] == 42) begin
        $display("PASS: Test 16 - 2D array access");
        pass_count++;
      end else $display("FAIL: Test 16 - 2D array (got %0d)", arr[1][2]);
    end

    // Test 17: NBA in always_ff (§9.2.2.4)
    ff_in = 8'h77;
    @(posedge clk);
    @(posedge clk);
    if (ff_out == 8'h77) begin
      $display("PASS: Test 17 - NBA in always_ff");
      pass_count++;
    end else $display("FAIL: Test 17 - always_ff NBA (got %h)", ff_out);

    // Test 18: NBA array with computed index (§10.4.2)
    begin
      static int idx = 1;
      nba_arr[idx + 1] <= 8'hBB;
      @(posedge clk);
      if (nba_arr[2] == 8'hBB) begin
        $display("PASS: Test 18 - NBA computed index");
        pass_count++;
      end else $display("FAIL: Test 18 - NBA computed (got %h)", nba_arr[2]);
    end

    // Test 19: Full width assignment (§11.5.1)
    begin
      logic [31:0] val;
      val = 32'hCAFEBABE;
      if (val == 32'hCAFEBABE) begin
        $display("PASS: Test 19 - Full width assignment");
        pass_count++;
      end else $display("FAIL: Test 19 - Full width (got %h)", val);
    end

    // Test 20: Release + reassign (§10.6.2)
    begin
      static logic [7:0] r_val = 8'h00;
      force r_val = 8'hFF;
      #1;
      release r_val;
      r_val = 8'h42;
      #1;
      if (r_val == 8'h42) begin
        $display("PASS: Test 20 - Release + reassign");
        pass_count++;
      end else $display("FAIL: Test 20 - Release reassign (got %h)", r_val);
    end

    // Test 21: Part-select assignment to lower bits (§11.5.1)
    begin
      static logic [15:0] val = 16'hFF00;
      val[3:0] = 4'hA;
      if (val == 16'hFF0A) begin
        $display("PASS: Test 21 - Part-select lower bits");
        pass_count++;
      end else $display("FAIL: Test 21 - Part-select low (got %h)", val);
    end

    // Test 22: Part-select assignment to upper bits (§11.5.1)
    begin
      static logic [15:0] val = 16'h00FF;
      val[15:12] = 4'hB;
      if (val == 16'hB0FF) begin
        $display("PASS: Test 22 - Part-select upper bits");
        pass_count++;
      end else $display("FAIL: Test 22 - Part-select high (got %h)", val);
    end

    // Test 23: Nested struct assignment (§7.2)
    begin
      typedef struct packed {
        pair_t inner;
        logic [15:0] extra;
      } nested_t;
      nested_t n;
      n.inner.high = 8'hAA;
      n.inner.low = 8'hBB;
      n.extra = 16'hCCDD;
      if (n.inner == 16'hAABB && n.extra == 16'hCCDD) begin
        $display("PASS: Test 23 - Nested struct assignment");
        pass_count++;
      end else $display("FAIL: Test 23 - Nested struct (got inner=%h extra=%h)", n.inner, n.extra);
    end

    // Test 24: LHS concat with different widths (§11.4.12)
    begin
      logic [7:0] a;
      logic [3:0] b;
      logic [3:0] c;
      {a, b, c} = 16'hABCD;
      if (a == 8'hAB && b == 4'hC && c == 4'hD) begin
        $display("PASS: Test 24 - LHS concat different widths");
        pass_count++;
      end else $display("FAIL: Test 24 - LHS widths (a=%h b=%h c=%h)", a, b, c);
    end

    // Test 25: Multiple bit-select assignments (§11.5.1)
    begin
      static logic [7:0] val = 8'h00;
      val[0] = 1'b1;
      val[2] = 1'b1;
      val[4] = 1'b1;
      val[6] = 1'b1;
      if (val == 8'b0101_0101) begin
        $display("PASS: Test 25 - Multiple bit-select assignments");
        pass_count++;
      end else $display("FAIL: Test 25 - Multi bit-select (got %b)", val);
    end

    $display("\n=== Assignment Forms Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end
endmodule
