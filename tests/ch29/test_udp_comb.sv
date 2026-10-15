/*
:name: test_udp_comb
:description: Combinational UDP
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_comb.expected
*/
// Combinational UDP
// Combinational UDPs produce output based solely on current inputs

// Test UDP 1: 2-input multiplexer
primitive mux2to1 (output y, input a, input b, input sel);
    table
        // a b sel : y
        0  ?  0  : 0;
        1  ?  0  : 1;
        ?  0  1  : 0;
        ?  1  1  : 1;
        0  0  ?  : 0;
        1  1  ?  : 1;
    endtable
endprimitive

// Test UDP 2: 3-input majority gate
primitive majority3 (output y, input a, input b, input c);
    table
        // a b c : y
        0  0  0 : 0;
        0  0  1 : 0;
        0  1  0 : 0;
        0  1  1 : 1;
        1  0  0 : 0;
        1  0  1 : 1;
        1  1  0 : 1;
        1  1  1 : 1;
    endtable
endprimitive

// Test UDP 3: Simple AND with X handling
primitive and_udp (output y, input a, input b);
    table
        // a b : y
        0  0 : 0;
        0  1 : 0;
        1  0 : 0;
        1  1 : 1;
        0  x : 0;
        x  0 : 0;
        1  x : x;
        x  1 : x;
        x  x : x;
    endtable
endprimitive

module test_udp_comb;

    logic a, b, c, sel;
    wire y_mux, y_maj, y_and;

    // Instantiate UDPs
    mux2to1 u_mux(y_mux, a, b, sel);
    majority3 u_maj(y_maj, a, b, c);
    and_udp u_and(y_and, a, b);

    initial begin
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Multiplexer - select a
        a = 1; b = 0; sel = 0; #1;
        if (y_mux === 1'b1) begin
            $display("Test 1 PASS: MUX selects a when sel=0");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: MUX output (got %b)", y_mux);
            fail_count++;
        end

        // Test 2: Multiplexer - select b
        a = 0; b = 1; sel = 1; #1;
        if (y_mux === 1'b1) begin
            $display("Test 2 PASS: MUX selects b when sel=1");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: MUX b select (got %b)", y_mux);
            fail_count++;
        end

        // Test 3: Majority gate - 2 of 3 high
        a = 1; b = 1; c = 0; #1;
        if (y_maj === 1'b1) begin
            $display("Test 3 PASS: Majority gate outputs 1 for 2/3 high");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: Majority output (got %b)", y_maj);
            fail_count++;
        end

        // Test 4: Majority gate - 1 of 3 high
        a = 1; b = 0; c = 0; #1;
        if (y_maj === 1'b0) begin
            $display("Test 4 PASS: Majority gate outputs 0 for 1/3 high");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Majority minority (got %b)", y_maj);
            fail_count++;
        end

        // Test 5: AND UDP with X input
        a = 0; b = 1'bx; #1;
        if (y_and === 1'b0) begin
            $display("Test 5 PASS: AND UDP 0&X = 0");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: AND UDP X handling (got %b)", y_and);
            fail_count++;
        end

        $display("\nResults: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
