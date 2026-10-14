/*
:name: test_continuous_assign_2
:description: Test: Continuous assignments (assign)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_assign_2.expected
*/
// Test: Continuous assignments (assign)

module test_continuous_assign;
    int pass_count = 0;
    int total_tests = 12;

    // Basic wires
    logic [7:0] a, b, c;
    wire [7:0] sum, diff, product;
    wire [15:0] wide_product;
    wire [7:0] mux_out;
    wire [7:0] cond_out;
    wire and_out, or_out, xor_out;
    wire [7:0] cascade1, cascade2, cascade3;
    wire [7:0] delayed_out;
    logic sel;
    logic [3:0] vec;
    wire reduced;

    // Continuous assignments
    assign sum = a + b;
    assign diff = a - b;
    assign wide_product = a * b;
    assign mux_out = sel ? a : b;
    assign cond_out = (a > b) ? a : b;  // max function
    assign and_out = a[0] & b[0];
    assign or_out = a[0] | b[0];
    assign xor_out = a[0] ^ b[0];
    assign cascade1 = a + 1;
    assign cascade2 = cascade1 + 1;
    assign cascade3 = cascade2 + 1;
    assign #1 delayed_out = a;  // delayed continuous assignment
    assign reduced = &vec;  // reduction operator

    initial begin
        // Test 1: Simple addition
        a = 8'h10;
        b = 8'h05;
        #1;
        if (sum == 8'h15) begin
            pass_count++;
            $display("PASS: Continuous add");
        end else $display("FAIL: Continuous add, got %h", sum);

        // Test 2: Subtraction
        if (diff == 8'h0B) begin
            pass_count++;
            $display("PASS: Continuous subtract");
        end else $display("FAIL: Continuous subtract, got %h", diff);

        // Test 3: Wide multiplication
        a = 8'h10;
        b = 8'h10;
        #1;
        if (wide_product == 16'h0100) begin
            pass_count++;
            $display("PASS: Continuous wide multiply");
        end else $display("FAIL: Continuous wide multiply, got %h", wide_product);

        // Test 4: Mux with sel=0
        a = 8'hAA;
        b = 8'h55;
        sel = 0;
        #1;
        if (mux_out == 8'h55) begin
            pass_count++;
            $display("PASS: Continuous mux sel=0");
        end else $display("FAIL: Continuous mux sel=0, got %h", mux_out);

        // Test 5: Mux with sel=1
        sel = 1;
        #1;
        if (mux_out == 8'hAA) begin
            pass_count++;
            $display("PASS: Continuous mux sel=1");
        end else $display("FAIL: Continuous mux sel=1, got %h", mux_out);

        // Test 6: Conditional max
        a = 8'h20;
        b = 8'h30;
        #1;
        if (cond_out == 8'h30) begin
            pass_count++;
            $display("PASS: Continuous conditional max");
        end else $display("FAIL: Continuous conditional max");

        // Test 7: Bitwise operations
        a = 8'h01;
        b = 8'h00;
        #1;
        if (and_out == 0 && or_out == 1 && xor_out == 1) begin
            pass_count++;
            $display("PASS: Continuous bitwise ops");
        end else $display("FAIL: Continuous bitwise ops");

        // Test 8: Cascaded assignments
        a = 8'h00;
        #1;
        if (cascade1 == 8'h01 && cascade2 == 8'h02 && cascade3 == 8'h03) begin
            pass_count++;
            $display("PASS: Cascaded continuous assigns");
        end else $display("FAIL: Cascaded continuous assigns");

        // Test 9: Propagation on change
        a = 8'h10;
        #1;
        if (cascade1 == 8'h11 && cascade2 == 8'h12 && cascade3 == 8'h13) begin
            pass_count++;
            $display("PASS: Continuous assign propagation");
        end else $display("FAIL: Continuous assign propagation");

        // Test 10: Delayed continuous assignment
        a = 8'hCC;
        #0;  // Before delay completes
        if (delayed_out != 8'hCC) begin
            pass_count++;
            $display("PASS: Delayed assign before");
        end else $display("FAIL: Delayed assign before");

        // Test 11: Delayed continuous assignment after
        #2;
        if (delayed_out == 8'hCC) begin
            pass_count++;
            $display("PASS: Delayed assign after");
        end else $display("FAIL: Delayed assign after, got %h", delayed_out);

        // Test 12: Reduction operator
        vec = 4'b1111;
        #1;
        if (reduced == 1) begin
            pass_count++;
            $display("PASS: Reduction operator assign");
        end else $display("FAIL: Reduction operator assign");

        $display("PASS: continuous_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
