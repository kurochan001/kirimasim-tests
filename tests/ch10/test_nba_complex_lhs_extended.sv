/*
:name: test_nba_complex_lhs_extended
:description: Extended complex LHS NBA patterns
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 7.2 7.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_complex_lhs_extended.expected
*/
// IEEE 1800-2023 §10.4.2: Extended complex LHS NBA patterns
// Tests:
// 1. reg_bank[addr].data <= value (member of an array element)
// 2. obj.pkts[i].data <= value (member of an element of a struct member)
// 3. several nonblocking assignments to different parts of one struct

module test_nba_complex_lhs_extended;
    // Test structure for array of structs
    typedef struct packed {
        logic [7:0] data;
        logic [3:0] control;
    } packet_t;

    // Container class/struct with array member
    typedef struct {
        packet_t pkts[4];  // Array of packets
        logic [15:0] id;
    } container_t;

    // Test signals
    container_t obj;
    packet_t reg_bank[4];  // Array of packets (simulating register bank)
    logic clk = 0;

    // Clock generation
    always #5 clk = ~clk;

    // Test results
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Initialize
        for (int i = 0; i < 4; i++) begin
            obj.pkts[i].data = 8'h00;
            obj.pkts[i].control = 4'h0;
            reg_bank[i].data = 8'h00;
            reg_bank[i].control = 4'h0;
        end
        obj.id = 16'h0000;

        // Wait for clock edge
        @(posedge clk);

        // =========================================================
        // Test 1: member of an array element (reg_bank[addr].data)
        // =========================================================
        reg_bank[0].data <= 8'hAA;
        reg_bank[1].data <= 8'hBB;
        reg_bank[2].data <= 8'hCC;
        reg_bank[3].data <= 8'hDD;
        @(posedge clk);

        if (reg_bank[0].data == 8'hAA &&
            reg_bank[1].data == 8'hBB &&
            reg_bank[2].data == 8'hCC &&
            reg_bank[3].data == 8'hDD) begin
            $display("PASS: Test 1 - NBA to a member of an array element (reg_bank[addr].data)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - reg_bank[0].data=%02x, [1]=%02x, [2]=%02x, [3]=%02x",
                     reg_bank[0].data, reg_bank[1].data,
                     reg_bank[2].data, reg_bank[3].data);
            fail_count++;
        end

        // =========================================================
        // Test 2: member of an array element (control field)
        // =========================================================
        reg_bank[0].control <= 4'h1;
        reg_bank[1].control <= 4'h2;
        reg_bank[2].control <= 4'h3;
        reg_bank[3].control <= 4'h4;
        @(posedge clk);

        if (reg_bank[0].control == 4'h1 &&
            reg_bank[1].control == 4'h2 &&
            reg_bank[2].control == 4'h3 &&
            reg_bank[3].control == 4'h4) begin
            $display("PASS: Test 2 - NBA to a member of an array element (reg_bank[addr].control)");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - control fields incorrect");
            fail_count++;
        end

        // =========================================================
        // Test 3: member of an element of a struct member (obj.pkts[i].data)
        // =========================================================
        obj.pkts[0].data <= 8'h11;
        obj.pkts[1].data <= 8'h22;
        obj.pkts[2].data <= 8'h33;
        obj.pkts[3].data <= 8'h44;
        @(posedge clk);

        if (obj.pkts[0].data == 8'h11 &&
            obj.pkts[1].data == 8'h22 &&
            obj.pkts[2].data == 8'h33 &&
            obj.pkts[3].data == 8'h44) begin
            $display("PASS: Test 3 - NBA to a member of an element of a struct member (obj.pkts[i].data)");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - obj.pkts[*].data incorrect");
            fail_count++;
        end

        // =========================================================
        // Test 4: Mixed NBA - same root, different paths
        // =========================================================
        obj.pkts[0].data <= 8'hFF;
        obj.pkts[0].control <= 4'hE;
        obj.id <= 16'h1234;
        @(posedge clk);

        if (obj.pkts[0].data == 8'hFF &&
            obj.pkts[0].control == 4'hE &&
            obj.id == 16'h1234) begin
            $display("PASS: Test 4 - Mixed NBA same root, different paths");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - obj.pkts[0].data=%02x, control=%x, id=%04x",
                     obj.pkts[0].data, obj.pkts[0].control, obj.id);
            fail_count++;
        end

        // =========================================================
        // Test 5: Variable index NBA
        // =========================================================
        begin
            int idx;
            idx = 2;
            reg_bank[idx].data <= 8'hAB;
            @(posedge clk);

            if (reg_bank[2].data == 8'hAB) begin
                $display("PASS: Test 5 - Variable index NBA (reg_bank[idx].data)");
                pass_count++;
            end else begin
                $display("FAIL: Test 5 - reg_bank[2].data=%02x (expected 0xAB)", reg_bank[2].data);
                fail_count++;
            end
        end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
