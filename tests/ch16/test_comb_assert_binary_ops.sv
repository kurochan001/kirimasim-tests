/*
:name: test_comb_assert_binary_ops
:description: Tests: /, %, **, <<, >>, >>>, ~^, ===, !==
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 11.4.3 11.4.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_assert_binary_ops.expected
*/
// Tests: /, %, **, <<, >>, >>>, ~^, ===, !==
// IEEE 1800-2023 §11.4.3, §11.4.5, §11.4.8, §11.4.10

module test_comb_assert_binary_ops;
    logic clk = 0;
    always #5 clk = ~clk;

    logic [31:0] a, b;
    logic signed [31:0] sa;

    // === Division (/) ===
    property p_div_basic;
        @(posedge clk) (a == 10 && b == 3) |-> ((a / b) == 3);
    endproperty

    property p_div_exact;
        @(posedge clk) (a == 12 && b == 4) |-> ((a / b) == 3);
    endproperty

    assert property(p_div_basic) else $error("FAIL: 10/3");
    assert property(p_div_exact) else $error("FAIL: 12/4");

    // === Modulo (%) ===
    property p_mod_basic;
        @(posedge clk) (a == 10 && b == 3) |-> ((a % b) == 1);
    endproperty

    property p_mod_exact;
        @(posedge clk) (a == 12 && b == 4) |-> ((a % b) == 0);
    endproperty

    assert property(p_mod_basic) else $error("FAIL: 10%%3");
    assert property(p_mod_exact) else $error("FAIL: 12%%4");

    // === Power (**) ===
    property p_pow_basic;
        @(posedge clk) (a == 2 && b == 8) |-> ((a ** b) == 256);
    endproperty

    property p_pow_zero;
        @(posedge clk) (a == 5 && b == 0) |-> ((a ** b) == 1);
    endproperty

    assert property(p_pow_basic) else $error("FAIL: 2**8");
    assert property(p_pow_zero) else $error("FAIL: 5**0");

    // === Left Shift (<<) ===
    property p_lshift_basic;
        @(posedge clk) (a == 1 && b == 4) |-> ((a << b) == 16);
    endproperty

    property p_lshift_data;
        @(posedge clk) (a == 8'hA5 && b == 2) |-> ((a << b) == 32'h294);
    endproperty

    assert property(p_lshift_basic) else $error("FAIL: 1<<4");
    assert property(p_lshift_data) else $error("FAIL: 0xA5<<2");

    // === Right Shift (>>) ===
    property p_rshift_basic;
        @(posedge clk) (a == 16 && b == 2) |-> ((a >> b) == 4);
    endproperty

    property p_rshift_data;
        @(posedge clk) (a == 8'hFF && b == 4) |-> ((a >> b) == 8'h0F);
    endproperty

    assert property(p_rshift_basic) else $error("FAIL: 16>>2");
    assert property(p_rshift_data) else $error("FAIL: 0xFF>>4");

    // === Arithmetic Right Shift (>>>) ===
    property p_arshift_pos;
        @(posedge clk) (sa == 32'sd16) |-> ((sa >>> 2) == 32'sd4);
    endproperty

    assert property(p_arshift_pos) else $error("FAIL: 16>>>2");

    // === Bitwise XNOR (~^) ===
    property p_xnor_basic;
        @(posedge clk) (a == 32'hFF && b == 32'hFF) |-> ((a ~^ b) == 32'hFFFFFFFF);
    endproperty

    property p_xnor_diff;
        @(posedge clk) (a == 32'hFF && b == 32'h00) |-> ((a ~^ b) == 32'hFFFFFF00);
    endproperty

    assert property(p_xnor_basic) else $error("FAIL: 0xFF~^0xFF");
    assert property(p_xnor_diff) else $error("FAIL: 0xFF~^0x00");

    // === Case Equality (===) ===
    property p_case_eq_val;
        @(posedge clk) (a == 5 && b == 5) |-> (a === b);
    endproperty

    property p_case_neq_val;
        @(posedge clk) (a == 5 && b == 6) |-> (!(a === b));
    endproperty

    assert property(p_case_eq_val) else $error("FAIL: 5===5");
    assert property(p_case_neq_val) else $error("FAIL: !(5===6)");

    // === Case Inequality (!==) ===
    property p_case_ne_val;
        @(posedge clk) (a == 5 && b == 6) |-> (a !== b);
    endproperty

    property p_case_ne_same;
        @(posedge clk) (a == 5 && b == 5) |-> (!(a !== b));
    endproperty

    assert property(p_case_ne_val) else $error("FAIL: 5!==6");
    assert property(p_case_ne_same) else $error("FAIL: !(5!==5)");

    initial begin
        a = 0; b = 0; sa = 0;
        @(posedge clk);

        // Division & modulo
        a = 10; b = 3;
        @(posedge clk); @(posedge clk);

        a = 12; b = 4;
        @(posedge clk); @(posedge clk);

        // Power
        a = 2; b = 8;
        @(posedge clk); @(posedge clk);

        a = 5; b = 0;
        @(posedge clk); @(posedge clk);

        // Left shift
        a = 1; b = 4;
        @(posedge clk); @(posedge clk);

        a = 8'hA5; b = 2;
        @(posedge clk); @(posedge clk);

        // Right shift
        a = 16; b = 2;
        @(posedge clk); @(posedge clk);

        a = 8'hFF; b = 4;
        @(posedge clk); @(posedge clk);

        // Arithmetic right shift
        sa = 32'sd16;
        @(posedge clk); @(posedge clk);

        // XNOR
        a = 32'hFF; b = 32'hFF;
        @(posedge clk); @(posedge clk);

        a = 32'hFF; b = 32'h00;
        @(posedge clk); @(posedge clk);

        // Case equality
        a = 5; b = 5;
        @(posedge clk); @(posedge clk);

        a = 5; b = 6;
        @(posedge clk); @(posedge clk);

        $display("Binary ops test completed");
        $finish(0);
    end
endmodule
