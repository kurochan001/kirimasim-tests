/*
:name: test_contassign_packed_element_of_unpacked
:description: Continuous assignments to packed elements of an element of an unpacked array (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 6.5 10.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_contassign_packed_element_of_unpacked.expected
*/
// IEEE 1800-2023 §7.4.5: for logic [1:0][7:0] a[2], a[0][1] is the packed
// element 1 of a[0], its bits [15:8]. §6.5: every bit of a packed type is an
// element of its own, so separate continuous assignments (10.3.2) may drive
// different packed elements, or a range of them, of the same unpacked element,
// for variables and nets alike. With an ascending packed dimension, index 0 is
// the leftmost element.

module test_contassign_packed_element_of_unpacked;
  logic [7:0] s = 8'd5;
  logic [1:0][7:0] a1[2];  assign a1[0][0] = s; assign a1[0][1] = s + 1;    // A: two packed elements
  logic [1:0][7:0] a2[2];  assign a2[1][1] = s;                            // B: one packed element
  wire  [1:0][7:0] n1[2];  assign n1[0][0] = s; assign n1[0][1] = s + 1;     // C: the same with a net
  logic [2:0][3:0] r1[2];  assign r1[1][2:1] = {s[3:0], s[7:4]};          // D: a range of packed elements
  logic [0:1][7:0] u1[2];  assign u1[0][0] = s; assign u1[0][1] = 8'hee;     // E: ascending packed dimension
  logic [7:0] b1[2];       assign b1[1][3] = 1'b1;                          // control: a bit of a vector element
  logic [1:0][7:0] k1[2];  assign k1[0] = {s + 8'd1, s};                    // control: a whole unpacked element
  logic [11:0] r1_flat;
  assign r1_flat = r1[1];
  int errors = 0;

  task automatic check(string what, logic [15:0] got, logic [15:0] exp);
    if (got !== exp) begin
      $display("WRONG %s: got %h expected %h", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    #1;
    check("A a1[0]", a1[0], 16'h0605);
    check("B a2[1][1]", a2[1][1], 16'h0005);
    check("C n1[0]", n1[0], 16'h0605);
    check("D r1[1] bits [11:4]", r1_flat[11:4], 16'h0050);   // r1[1][2] = s[3:0] = 5, r1[1][1] = s[7:4] = 0
    check("E u1[0][0]", u1[0][0], 16'h0005);
    check("E u1[0][1]", u1[0][1], 16'h00ee);
    check("E u1[0]", u1[0], 16'h05ee);
    check("ctl b1[1][3]", b1[1][3], 16'h0001);
    check("ctl k1[0]", k1[0], 16'h0605);
    s = 8'd9;
    #1;
    check("A a1[0] after s = 9", a1[0], 16'h0a09);
    check("D r1[1] bits [11:4] after s = 9", r1_flat[11:4], 16'h0090);
    if (errors == 0) begin
      $display("TEST PASSED: continuous assignments to packed elements of an unpacked element");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
