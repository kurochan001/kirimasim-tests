/*
:name: test_assign_chain_ordering
:description: Test for continuous assignment chain ordering
:tags: continuous_assign
:type: simulation
:lrm: 1800-2023 10.3.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assign_chain_ordering.expected
*/
// Test for continuous assignment chain ordering
// IEEE 1800-2023 Section 10.3.2

module test_assign_chain_ordering;
    int pass_count = 0;
    int fail_count = 0;

    // Input signals
    logic [7:0] a, b, c;

    // Intermediate signals - chain of assignments
    logic [7:0] d, e, f, g, h;

    // Dependency chain: a -> d -> e -> f -> g -> h
    assign d = a + 1;
    assign e = d + 1;
    assign f = e + 1;
    assign g = f + 1;
    assign h = g + 1;

    // Parallel chains that should be independent
    logic [7:0] x, y, z;
    assign x = b * 2;
    assign y = c * 3;
    assign z = x + y;

    // Diamond dependency: a -> (p,q) -> r
    logic [7:0] p, q, r;
    assign p = a << 1;
    assign q = a >> 1;
    assign r = p | q;

    initial begin
        $display("=== Continuous Assignment Chain Ordering Test ===");

        // Test 1: Single chain evaluation
        $display("Test 1: Single chain a->d->e->f->g->h");
        a = 8'd10;
        #1;  // Let continuous assignments settle
        if (d == 11 && e == 12 && f == 13 && g == 14 && h == 15) begin
            $display("Test 1 PASS: Chain correctly evaluates a=%0d to h=%0d", a, h);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: Expected h=15, got d=%0d,e=%0d,f=%0d,g=%0d,h=%0d", d, e, f, g, h);
            fail_count++;
        end

        // Test 2: Parallel chains
        $display("Test 2: Parallel chains b->x, c->y, (x,y)->z");
        b = 8'd5;
        c = 8'd3;
        #1;
        if (x == 10 && y == 9 && z == 19) begin
            $display("Test 2 PASS: x=%0d, y=%0d, z=%0d", x, y, z);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: Expected x=10,y=9,z=19, got x=%0d,y=%0d,z=%0d", x, y, z);
            fail_count++;
        end

        // Test 3: Diamond dependency
        $display("Test 3: Diamond a->(p,q)->r");
        a = 8'b00001111;
        #1;
        // p = a << 1 = 0001_1110 = 30
        // q = a >> 1 = 0000_0111 = 7
        // r = p | q  = 0001_1111 = 31
        if (p == 30 && q == 7 && r == 31) begin
            $display("Test 3 PASS: p=%0d, q=%0d, r=%0d", p, q, r);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: Expected p=30,q=7,r=31, got p=%0d,q=%0d,r=%0d", p, q, r);
            fail_count++;
        end

        // Test 4: Update source and verify propagation
        $display("Test 4: Update propagation");
        a = 8'd20;
        #1;
        if (h == 25) begin
            $display("Test 4 PASS: Propagation correct, a=%0d -> h=%0d", a, h);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Expected h=25, got h=%0d", h);
            fail_count++;
        end

        // Test 5: Zero propagation through chain
        $display("Test 5: Zero propagation");
        a = 8'd0;
        #1;
        if (d == 1 && e == 2 && f == 3 && g == 4 && h == 5) begin
            $display("Test 5 PASS: Zero base propagation correct");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Chain values incorrect");
            fail_count++;
        end

        // Test 6: Maximum value handling
        $display("Test 6: Maximum value with wrap");
        a = 8'd250;
        #1;
        // d=251, e=252, f=253, g=254, h=255 (no wrap)
        if (h == 255) begin
            $display("Test 6 PASS: Max value propagation correct, h=%0d", h);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: Expected h=255, got h=%0d", h);
            fail_count++;
        end

        // Summary
        $display("");
        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
