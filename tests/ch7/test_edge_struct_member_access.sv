/*
:name: test_edge_struct_member_access
:description: Structures
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_struct_member_access.expected
*/
// IEEE 1800-2023 Section 7.2: Structures
// Tests basic struct member access and modification
// This test verifies struct member access in initial blocks

typedef struct {
    int x;
    int y;
} point_t;

module test_edge_struct_member_access;
    initial begin
        point_t p;

        // Test initial values (should be 0 for int members)
        if (p.x != 0 || p.y != 0) begin
            $display("FAIL: Expected initial values x=0,y=0, got x=%0d,y=%0d", p.x, p.y);
        end

        // Test member assignment
        p.x = 10;
        p.y = 20;

        // Verify assigned values
        if (p.x == 10 && p.y == 20) begin
            $display("PASS: Struct member access works correctly");
        end else begin
            $display("FAIL: Expected x=10,y=20, got x=%0d,y=%0d", p.x, p.y);
        end

        // Test member modification
        p.x = p.x + 5;
        p.y = p.y * 2;

        if (p.x == 15 && p.y == 40) begin
            $display("PASS: Struct member modification works correctly");
        end else begin
            $display("FAIL: Expected x=15,y=40, got x=%0d,y=%0d", p.x, p.y);
        end

        $finish;
    end
endmodule
