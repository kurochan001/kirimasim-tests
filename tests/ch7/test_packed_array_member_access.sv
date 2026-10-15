/*
:name: test_packed_array_member_access
:description: Member access of packed structs in an unpacked array
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 7.4
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array_member_access.expected
*/
// IEEE 1800-2023 §7.2-7.3 Packed Struct Array Element Member Access Test
// Tests pattern: arr[i].member = value where arr is an unpacked array of packed structs

module test_packed_array_member_access;
    // Define a packed struct
    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
        logic [7:0] a;
    } color_t;

    // Unpacked array of packed structs
    color_t colors [4];

    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Packed Struct Array Element Member Access Test (IEEE 1800-2023 §7.2) ===");

        // Initialize arrays using full struct assignment
        for (int i = 0; i < 4; i++) begin
            colors[i] = 32'h00000000;
        end

        // Test 1: Assign to entire struct element
        colors[0] = 32'hFFAABBCC;
        if (colors[0] == 32'hFFAABBCC) begin
            $display("PASS: colors[0] = 0x%h", colors[0]);
            passed++;
        end else begin
            $display("FAIL: colors[0] = 0x%h, expected 0xFFAABBCC", colors[0]);
            failed++;
        end

        // Test 2: Read individual member from packed struct array element
        if (colors[0].r == 8'hFF) begin
            $display("PASS: colors[0].r = 0x%h", colors[0].r);
            passed++;
        end else begin
            $display("FAIL: colors[0].r = 0x%h, expected 0xFF", colors[0].r);
            failed++;
        end

        // Test 3: Write to packed struct array element member
        colors[1].r = 8'h12;
        if (colors[1].r == 8'h12) begin
            $display("PASS: colors[1].r = 0x%h after assignment", colors[1].r);
            passed++;
        end else begin
            $display("FAIL: colors[1].r = 0x%h, expected 0x12", colors[1].r);
            failed++;
        end

        // Test 4: Write to different member
        colors[1].g = 8'h34;
        if (colors[1].g == 8'h34) begin
            $display("PASS: colors[1].g = 0x%h after assignment", colors[1].g);
            passed++;
        end else begin
            $display("FAIL: colors[1].g = 0x%h, expected 0x34", colors[1].g);
            failed++;
        end

        // Test 5: Verify entire struct value
        // colors[1] should have r=0x12, g=0x34, b=0x00, a=0x00
        if (colors[1] == 32'h12340000) begin
            $display("PASS: colors[1] = 0x%h (combined)", colors[1]);
            passed++;
        end else begin
            $display("FAIL: colors[1] = 0x%h, expected 0x12340000", colors[1]);
            failed++;
        end

        // Test 6: Write to multiple members of same element
        colors[2].r = 8'hAA;
        colors[2].g = 8'hBB;
        colors[2].b = 8'hCC;
        colors[2].a = 8'hDD;
        if (colors[2] == 32'hAABBCCDD) begin
            $display("PASS: colors[2] = 0x%h after all members set", colors[2]);
            passed++;
        end else begin
            $display("FAIL: colors[2] = 0x%h, expected 0xAABBCCDD", colors[2]);
            failed++;
        end

        // Test 7: Verify other elements unchanged
        if (colors[3] == 32'h00000000) begin
            $display("PASS: colors[3] = 0x%h (unchanged)", colors[3]);
            passed++;
        end else begin
            $display("FAIL: colors[3] = 0x%h, expected 0x00000000", colors[3]);
            failed++;
        end

        // Test 8: Loop-based member assignment
        for (int i = 0; i < 4; i++) begin
            colors[i].a = 8'hFF;  // Set all alpha to 0xFF
        end

        if (colors[0].a == 8'hFF && colors[1].a == 8'hFF &&
            colors[2].a == 8'hFF && colors[3].a == 8'hFF) begin
            $display("PASS: All alpha channels set to 0xFF");
            passed++;
        end else begin
            $display("FAIL: Alpha channel assignment failed");
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
