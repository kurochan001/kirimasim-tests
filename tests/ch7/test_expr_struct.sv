/*
:name: test_expr_struct
:description: Struct expressions test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_struct.expected
*/
// Struct expressions test
module test_expr_struct;
    int pass_count = 0;
    int fail_count = 0;

    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
    } color_t;

    point_t p1, p2;
    color_t c1, c2;

    initial begin
        // Test 1: Struct member assignment
        p1.x = 10;
        p1.y = 20;
        p1.name = "origin";
        if (p1.x == 10 && p1.y == 20 && p1.name == "origin") begin
            $display("PASS: Struct member assignment");
            pass_count++;
        end else begin
            $display("FAIL: Struct member assignment failed");
            fail_count++;
        end

        // Test 2: Struct literal assignment
        p2 = '{x: 100, y: 200, name: "point2"};
        if (p2.x == 100 && p2.y == 200 && p2.name == "point2") begin
            $display("PASS: Struct literal assignment");
            pass_count++;
        end else begin
            $display("FAIL: Struct literal assignment failed");
            fail_count++;
        end

        // Test 3: Packed struct
        c1.r = 8'hFF;
        c1.g = 8'h00;
        c1.b = 8'h80;
        if (c1 == 24'hFF0080) begin
            $display("PASS: Packed struct = 24'hFF0080");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct, expected 0xFF0080, got 0x%06X", c1);
            fail_count++;
        end

        // Test 4: Struct copy
        p1 = p2;
        if (p1.x == p2.x && p1.y == p2.y && p1.name == p2.name) begin
            $display("PASS: Struct copy");
            pass_count++;
        end else begin
            $display("FAIL: Struct copy failed");
            fail_count++;
        end

        // Test 5: Packed struct bit access
        c2 = 24'hAABBCC;
        if (c2.r == 8'hAA && c2.g == 8'hBB && c2.b == 8'hCC) begin
            $display("PASS: Packed struct member read r=0xAA g=0xBB b=0xCC");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct read, got r=0x%02X g=0x%02X b=0x%02X", c2.r, c2.g, c2.b);
            fail_count++;
        end

        // Summary
        $display("Struct expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All struct expression tests passed");
        else $display("FAIL: Some struct expression tests failed");
        $finish;
    end
endmodule
