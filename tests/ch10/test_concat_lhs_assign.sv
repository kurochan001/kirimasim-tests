/*
:name: test_concat_lhs_assign
:description: Concatenations as the left-hand side of blocking and nonblocking assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 10.4.2 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_lhs_assign.expected
*/
// IEEE 1800-2023 §11.4.12 concatenation used as LHS

module tb;
  logic clk = 0;
  int pass_count = 0;
  int fail_count = 0;

  // Module-level variables for NBA tests
  logic [7:0] nba_high, nba_low;

  always #5 clk = ~clk;

  // Test 1: Basic concatenation LHS
  task automatic test_basic_concat_lhs;
    logic [7:0] a, b;
    {a, b} = 16'hABCD;
    if (a === 8'hAB && b === 8'hCD) begin
      pass_count++;
      $display("PASS: basic concat LHS");
    end else begin
      fail_count++;
      $display("FAIL: basic concat LHS: a=%h b=%h", a, b);
    end
  endtask

  // Test 2: Three-way concatenation
  task automatic test_three_way_concat;
    logic [7:0] x, y, z;
    {x, y, z} = 24'h112233;
    if (x === 8'h11 && y === 8'h22 && z === 8'h33) begin
      pass_count++;
      $display("PASS: three-way concat");
    end else begin
      fail_count++;
      $display("FAIL: three-way concat");
    end
  endtask

  // Test 3: Concat with part-select
  task automatic test_concat_part_select;
    logic [15:0] combined = 16'h0000;
    logic [7:0] val = 8'hFF;
    {combined[15:8], combined[7:0]} = {val, 8'hAA};
    if (combined === 16'hFFAA) begin
      pass_count++;
      $display("PASS: concat with part-select");
    end else begin
      fail_count++;
      $display("FAIL: concat with part-select: got %h", combined);
    end
  endtask

  // Test 4: Concat LHS with different widths
  task automatic test_mixed_width_concat;
    logic [3:0] nibble;
    logic [11:0] rest;
    {nibble, rest} = 16'hFACE;
    if (nibble === 4'hF && rest === 12'hACE) begin
      pass_count++;
      $display("PASS: mixed width concat");
    end else begin
      fail_count++;
      $display("FAIL: mixed width concat: nibble=%h rest=%h", nibble, rest);
    end
  endtask

  // Test 5: Nested concatenation
  task automatic test_nested_concat;
    logic [3:0] a, b, c, d;
    {{a, b}, {c, d}} = 16'h1234;
    if (a === 4'h1 && b === 4'h2 && c === 4'h3 && d === 4'h4) begin
      pass_count++;
      $display("PASS: nested concat");
    end else begin
      fail_count++;
      $display("FAIL: nested concat: a=%h b=%h c=%h d=%h", a, b, c, d);
    end
  endtask

  // Test 6: Concat LHS NBA (using module-level variables)
  task automatic test_concat_lhs_nba;
    nba_high = 8'h00;
    nba_low = 8'h00;
    @(posedge clk);
    {nba_high, nba_low} <= 16'hDEAD;
    @(posedge clk);
    if (nba_high === 8'hDE && nba_low === 8'hAD) begin
      pass_count++;
      $display("PASS: concat LHS NBA");
    end else begin
      fail_count++;
      $display("FAIL: concat LHS NBA: high=%h low=%h", nba_high, nba_low);
    end
  endtask

  // Test 7: Single bit in concat
  task automatic test_single_bit_concat;
    logic a, b, c, d;
    {a, b, c, d} = 4'b1010;
    if (a === 1'b1 && b === 1'b0 && c === 1'b1 && d === 1'b0) begin
      pass_count++;
      $display("PASS: single bit concat");
    end else begin
      fail_count++;
      $display("FAIL: single bit concat");
    end
  endtask

  initial begin
    test_basic_concat_lhs();
    test_three_way_concat();
    test_concat_part_select();
    test_mixed_width_concat();
    test_nested_concat();
    test_concat_lhs_nba();
    test_single_bit_concat();

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
