/*
:name: test_unsized_fill_wide_part_select_nba
:description: An unsized fill literal such as '1 fills the whole width of a part-select wider than 32 bits in a nonblocking assignment (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 11.6.1 10.4.2 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unsized_fill_wide_part_select_nba.expected
*/
// IEEE 1800-2023 §5.7.1, §11.6.1: an unsized fill literal ('0, '1) is an operand
// of a context-determined expression and takes the width of its context, with
// every bit set to the given value. As the operand of an expression assigned to
// a 33-bit or 65-bit part-select, it is 33 or 65 bits wide, also in a
// nonblocking assignment (10.4.2), when the part-select is an indexed one or its
// bound is a parameter, and when the target is a member of an interface.

localparam integer UNIT_WIDTH = 65;
interface unsized_fill_ifc;
  logic [UNIT_WIDTH-1:0] tdata;
endinterface

module test_unsized_fill_wide_part_select_nba;
  localparam integer W = 65;
  logic [32:0] a, d, e, f, g;
  logic [64:0] b;
  unsized_fill_ifc cmd();
  int errors = 0;

  task automatic chk(string name, bit ok);
    if (!ok) begin
      $display("WRONG %s", name);
      errors++;
    end else begin
      $display("ok    %s", name);
    end
  endtask

  initial begin
    a = '0; b = '0; d = '0; e = '0; f = '0; g = '0; cmd.tdata = '0;
    #1;
    a[32:0] <= a[32:0] ^ '1;
    b[W-1:0] <= b[W-1:0] ^ '1;
    cmd.tdata[UNIT_WIDTH-1:0] <= cmd.tdata[UNIT_WIDTH-1:0] ^ '1;
    d[32:0] <= ~'0;
    e[0 +: 33] <= e[0 +: 33] | '1;
    f[32:0] <= ~f[32:0];
    g[32:0] = g[32:0] ^ '1;
    #1;
    chk("A 33-bit a[32:0] <= a[32:0] ^ '1", a === {33{1'b1}});
    chk("B 65-bit b[W-1:0] <= b[W-1:0] ^ '1", b === {65{1'b1}});
    chk("C interface member with a compilation-unit localparam", cmd.tdata === {65{1'b1}});
    chk("D d[32:0] <= ~'0", d === {33{1'b1}});
    chk("E e[0 +: 33] <= e[0 +: 33] | '1", e === {33{1'b1}});
    chk("F control: f[32:0] <= ~f[32:0]", f === {33{1'b1}});
    chk("G control: blocking g[32:0] = g[32:0] ^ '1", g === {33{1'b1}});
    if (errors == 0) $display("TEST PASSED");
    else $display("TEST FAILED: %0d check(s) failed", errors);
  end
endmodule
