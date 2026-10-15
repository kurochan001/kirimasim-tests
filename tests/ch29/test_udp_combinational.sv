/*
:name: test_udp_combinational
:description: Test combinational UDP (User-Defined Primitive)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_combinational.expected
*/
// Test combinational UDP (User-Defined Primitive)
module test_udp_combinational;
    reg a, b, c;
    wire y_and, y_or, y_xor, y_mux;
    int pass_count = 0;
    int fail_count = 0;

    // Instantiate combinational UDPs
    // UDP instances use ordered port connections
    udp_and u_and(y_and, a, b);
    udp_or u_or(y_or, a, b);
    udp_xor u_xor(y_xor, a, b);
    udp_mux u_mux(y_mux, a, b, c);

    initial begin
        // Test 1: UDP AND gate - both inputs 1
        a = 1; b = 1;
        #1;
        if (y_and == 1'b1) begin
            $display("PASS: Test 1 - UDP AND (1,1) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - UDP AND (1,1), got %b", y_and);
            fail_count++;
        end

        // Test 2: UDP AND gate - one input 0
        a = 1; b = 0;
        #1;
        if (y_and == 1'b0) begin
            $display("PASS: Test 2 - UDP AND (1,0) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - UDP AND (1,0), got %b", y_and);
            fail_count++;
        end

        // Test 3: UDP OR gate
        a = 0; b = 1;
        #1;
        if (y_or == 1'b1) begin
            $display("PASS: Test 3 - UDP OR (0,1) = 1");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - UDP OR (0,1), got %b", y_or);
            fail_count++;
        end

        // Test 4: UDP XOR gate
        a = 1; b = 1;
        #1;
        if (y_xor == 1'b0) begin
            $display("PASS: Test 4 - UDP XOR (1,1) = 0");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - UDP XOR (1,1), got %b", y_xor);
            fail_count++;
        end

        // Test 5: UDP MUX (sel=0 selects a)
        a = 1; b = 0; c = 0;
        #1;
        if (y_mux == 1'b1) begin
            $display("PASS: Test 5 - UDP MUX sel=0 selects a=1");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - UDP MUX sel=0, got %b", y_mux);
            fail_count++;
        end

        // Test 6: UDP MUX (sel=1 selects b)
        a = 0; b = 1; c = 1;
        #1;
        if (y_mux == 1'b1) begin
            $display("PASS: Test 6 - UDP MUX sel=1 selects b=1");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - UDP MUX sel=1, got %b", y_mux);
            fail_count++;
        end

        $display("\nSummary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule

// Combinational UDP: AND gate
primitive udp_and(output y, input a, b);
    table
        // a b : y
        0 0 : 0;
        0 1 : 0;
        1 0 : 0;
        1 1 : 1;
        x ? : x;
        ? x : x;
    endtable
endprimitive

// Combinational UDP: OR gate
primitive udp_or(output y, input a, b);
    table
        // a b : y
        0 0 : 0;
        0 1 : 1;
        1 0 : 1;
        1 1 : 1;
        1 ? : 1;
        ? 1 : 1;
        x 0 : x;
        0 x : x;
    endtable
endprimitive

// Combinational UDP: XOR gate
primitive udp_xor(output y, input a, b);
    table
        // a b : y
        0 0 : 0;
        0 1 : 1;
        1 0 : 1;
        1 1 : 0;
        x ? : x;
        ? x : x;
    endtable
endprimitive

// Combinational UDP: 2-to-1 MUX
// Overlapping rows must not give different outputs
primitive udp_mux(output y, input a, b, sel);
    table
        // a b sel : y
        // sel=0 selects a
        0 0 0 : 0;
        0 1 0 : 0;
        1 0 0 : 1;
        1 1 0 : 1;
        // sel=1 selects b
        0 0 1 : 0;
        0 1 1 : 1;
        1 0 1 : 0;
        1 1 1 : 1;
        // sel=x propagates x
        ? ? x : x;
        // x inputs propagate x
        x ? 0 : x;
        ? x 1 : x;
    endtable
endprimitive
