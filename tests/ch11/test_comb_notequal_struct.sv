/*
:name: test_comb_notequal_struct
:description: Test: notEqual() for StructValue/UnionValue and value_ops edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5 7.2 7.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_notequal_struct.expected
*/
// Test: Inequality and equality of structures and unions
// Verifies IEEE 1800-2023 §7.3 struct/union equality/inequality
module test_comb_notequal_struct;
    int pass_count = 0;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } packed_pair_t;

    typedef struct {
        int x;
        int y;
        string name;
    } point_t;

    typedef union packed {
        logic [15:0] raw;
        packed_pair_t fields;
    } data_u;

    initial begin
        // T1: Packed struct != with different values
        begin
            packed_pair_t s1, s2;
            s1 = '{a: 8'hAA, b: 8'hBB};
            s2 = '{a: 8'hCC, b: 8'hDD};
            if (s1 != s2) begin
                $display("T1: PASS - packed struct != works");
                pass_count++;
            end else
                $display("T1: FAIL");
        end

        // T2: Packed struct != with same values
        begin
            packed_pair_t s1, s2;
            s1 = '{a: 8'h55, b: 8'h77};
            s2 = '{a: 8'h55, b: 8'h77};
            if (!(s1 != s2)) begin
                $display("T2: PASS - identical packed structs not !=");
                pass_count++;
            end else
                $display("T2: FAIL");
        end

        // T3: Unpacked struct != with different values
        begin
            point_t p1, p2;
            p1 = '{x: 10, y: 20, name: "A"};
            p2 = '{x: 30, y: 40, name: "B"};
            if (p1 != p2) begin
                $display("T3: PASS - unpacked struct != works");
                pass_count++;
            end else
                $display("T3: FAIL");
        end

        // T4: Unpacked struct != with same values
        begin
            point_t p1, p2;
            p1 = '{x: 5, y: 10, name: "test"};
            p2 = '{x: 5, y: 10, name: "test"};
            if (!(p1 != p2)) begin
                $display("T4: PASS - identical unpacked structs not !=");
                pass_count++;
            end else
                $display("T4: FAIL");
        end

        // T5: Packed union !=
        begin
            data_u u1, u2;
            u1.raw = 16'hAABB;
            u2.raw = 16'hCCDD;
            if (u1 != u2) begin
                $display("T5: PASS - packed union !=");
                pass_count++;
            end else
                $display("T5: FAIL");
        end

        // T6: Packed union == via fields
        begin
            data_u u1, u2;
            u1.fields = '{a: 8'h12, b: 8'h34};
            u2.raw = 16'h1234;
            if (u1 == u2) begin
                $display("T6: PASS - packed union == via fields/raw");
                pass_count++;
            end else
                $display("T6: FAIL - u1=%h u2=%h", u1.raw, u2.raw);
        end

        // T7: Single member difference
        begin
            point_t p1, p2;
            p1 = '{x: 100, y: 200, name: "hello"};
            p2 = '{x: 100, y: 201, name: "hello"};
            if (p1 != p2) begin
                $display("T7: PASS - single member difference detected");
                pass_count++;
            end else
                $display("T7: FAIL");
        end

        // T8: String member difference
        begin
            point_t p1, p2;
            p1 = '{x: 1, y: 2, name: "alpha"};
            p2 = '{x: 1, y: 2, name: "beta"};
            if (p1 != p2) begin
                $display("T8: PASS - string member difference detected");
                pass_count++;
            end else
                $display("T8: FAIL");
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 8)
            $display("PASS: test_comb_notequal_struct");
        else
            $display("FAIL: test_comb_notequal_struct (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
