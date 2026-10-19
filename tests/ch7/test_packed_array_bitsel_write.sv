/*
:name: test_packed_array_bitsel_write
:description: Blocking and nonblocking writes to one bit of an element of a two-dimensional packed array (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.5 11.5.1 10.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_bitsel_write.expected
*/
// IEEE 1800-2023 §7.4.1, §7.4.5: a packed array with two dimensions is one
// vector, and pa[i][j] is bit j of element i, that is bit 8*i+j of
// logic [3:0][7:0] pa. Writing it changes only that bit. A nonblocking write to
// one bit (10.4.2) is applied on top of the blocking writes made to other bits
// earlier in the same time step.

module test_packed_array_bitsel_write;
  logic [3:0][7:0] pa;
  int errs;
  task automatic chk(string w, logic [31:0] got, logic [31:0] exp);
    if (got === exp) $display("  ok   %s = %08h", w, got);
    else begin errs++; $display("  FAIL %s = %08h (exp %08h)", w, got, exp); end
  endtask
  initial begin
    // (1) blocking writes that set the corner bits of elements, and one inside
    pa = 0; pa[0][0] = 1'b1;  chk("pa[0][0]=1",  pa, 32'h0000_0001);
    pa = 0; pa[0][7] = 1'b1;  chk("pa[0][7]=1",  pa, 32'h0000_0080);
    pa = 0; pa[3][0] = 1'b1;  chk("pa[3][0]=1",  pa, 32'h0100_0000);
    pa = 0; pa[3][7] = 1'b1;  chk("pa[3][7]=1",  pa, 32'h8000_0000);
    pa = 0; pa[2][5] = 1'b1;  chk("pa[2][5]=1",  pa, 32'h0020_0000);
    // (2) a blocking write that clears a bit
    pa = 32'h0020_0000; pa[2][5] = 1'b0; chk("clr pa[2][5]", pa, 32'h0000_0000);
    // (3) set and then clear the same bit
    pa = 0; pa[1][3] = 1'b1; pa[1][3] = 1'b0; chk("pa[1][3] 1->0", pa, 32'h0000_0000);
    // (4) a nonblocking write that sets a bit
    pa = 0; pa[1][0] <= 1'b1; #1; chk("NBA pa[1][0]=1", pa, 32'h0000_0100);
    // (5) a nonblocking write after a blocking write of the whole array
    pa = 32'h0020_0000; pa[0][7] <= 1'b1; #1; chk("NBA after whole", pa, 32'h0020_0080);
    // (6) blocking writes to bits of two elements, then a nonblocking write to a
    //     bit of a third element in the same time step
    pa = 0;
    pa[1][2] = 1'b1;   // bit 10
    pa[2][7] = 1'b1;   // bit 23
    pa[0][1] <= 1'b1;  // bit 1
    #1; chk("NBA w/ blocking bits", pa, 32'h0080_0402);
    if (errs == 0) $display("TEST PASSED");
    else $display("TEST FAILED: errs=%0d", errs);
    $finish;
  end
endmodule
