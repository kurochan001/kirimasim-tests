/*
:name: test_always_comb_chain
:description: A chain of always_comb blocks settles after its input changes
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_chain.expected
*/
// A chain of always_comb blocks, each reading the output of another,
// settles to the right values after its input changes (9.2.2.2).

module test_always_comb_chain;
    logic clk = 0;
    logic [7:0] a, b, c, d;
    logic sel;
    int pass_count = 0;
    int test_count = 0;

    always #5 clk = ~clk;

    // Simple combinational logic chain
    always_comb begin
        b = a + 1;
    end

    always_comb begin
        c = b * 2;
    end

    always_comb begin
        d = sel ? c : a;
    end

    initial begin
        // Test 1: Linear dependency
        test_count++;
        a = 8'h10;
        sel = 0;
        #1;
        if (b == 8'h11 && c == 8'h22) begin
            $display("Test 1: Linear dependency PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL b=%h c=%h", b, c);
        end

        // Test 2: Mux selection
        test_count++;
        sel = 1;
        #1;
        if (d == c) begin
            $display("Test 2: Mux select PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL d=%h", d);
        end

        // Test 3: Change input
        test_count++;
        a = 8'h20;
        #1;
        if (b == 8'h21 && c == 8'h42) begin
            $display("Test 3: Input change PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Multiple updates
        test_count++;
        begin
            static int bad = 0;
            for (int i = 0; i < 5; i++) begin
                a = i;
                #1;
                if (b != 8'(i + 1) || c != 8'((i + 1) * 2) || d != c) bad++;
            end
            if (bad == 0) begin
                $display("Test 4: Multiple updates PASS");
                pass_count++;
            end else begin
                $display("Test 4: FAIL %0d updates wrong", bad);
            end
        end

        // Test 5: Sel toggle
        test_count++;
        sel = 0;
        #1;
        begin
            static logic [7:0] d_sel0;
            d_sel0 = d;
            sel = 1;
            #1;
            if (d_sel0 == a && d == c) begin
                $display("Test 5: Sel toggle PASS");
                pass_count++;
            end else begin
                $display("Test 5: FAIL d=%h with sel 0, d=%h with sel 1", d_sel0, d);
            end
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
