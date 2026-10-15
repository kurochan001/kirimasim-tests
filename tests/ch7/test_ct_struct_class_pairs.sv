/*
:name: test_ct_struct_class_pairs
:description: T1: ClassInstance member access and modification
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.3 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ct_struct_class_pairs.expected
*/
module test_ct_struct_class_pairs;
    int pass_count = 0;
    int test_count = 20;

    typedef struct packed {
        logic [7:0] upper;
        logic [7:0] lower;
    } packed_pair_t;

    typedef struct {
        int x, y;
        string name;
    } point_t;

    class SimpleObj;
        int value;
        string label;
        function new(int v = 0, string l = "");
            value = v;
            label = l;
        endfunction
    endclass

    class Container;
        int data[$];
        int aa[string];
        function new();
        endfunction
    endclass

    initial begin
        // T1: ClassInstance member access and modification
        begin
            static SimpleObj obj = new(42, "test");
            if (obj.value == 42 && obj.label == "test") begin
                obj.value = 99;
                if (obj.value == 99) begin
                    $display("T1: PASS - class member access");
                    pass_count++;
                end else
                    $display("T1: FAIL - modify");
            end else
                $display("T1: FAIL - initial");
        end

        begin
            packed_pair_t p;
            p.upper = 8'hAB;
            p.lower = 8'hCD;
            p[0] = 1'b0;
            if (p.lower == 8'hCC) begin
                $display("T2: PASS - packed struct bit-select");
                pass_count++;
            end else
                $display("T2: FAIL - lower=%0h", p.lower);
        end

        // T3: Packed struct part-select write
        begin
            packed_pair_t p;
            p = 16'h0000;
            p[15:8] = 8'hFF;
            if (p.upper == 8'hFF && p.lower == 8'h00) begin
                $display("T3: PASS - packed struct part-select");
                pass_count++;
            end else
                $display("T3: FAIL - upper=%0h lower=%0h", p.upper, p.lower);
        end

        // T4: Unpacked struct assignment and comparison
        begin
            point_t p1, p2;
            p1.x = 10; p1.y = 20; p1.name = "a";
            p2 = p1;
            if (p2.x == 10 && p2.y == 20 && p2.name == "a") begin
                p2.x = 99;
                if (p1.x == 10) begin
                    $display("T4: PASS - struct copy semantics");
                    pass_count++;
                end else
                    $display("T4: FAIL - not a copy");
            end else
                $display("T4: FAIL - assign");
        end

        // T5: Class queue member push_back
        begin
            static Container c = new();
            c.data.push_back(1);
            c.data.push_back(2);
            c.data.push_back(3);
            if (c.data.size() == 3 && c.data[0] == 1 && c.data[2] == 3) begin
                $display("T5: PASS - class queue member");
                pass_count++;
            end else
                $display("T5: FAIL - size=%0d", c.data.size());
        end

        begin
            point_t p;
            p.x = 0; p.y = 0;
            p.x = 10; p.y = 20;
            if (p.x == 10 && p.y == 20) begin
                $display("T6: PASS - struct member assign p.x=%0d p.y=%0d", p.x, p.y);
                pass_count++;
            end else
                $display("T6: FAIL - p.x=%0d p.y=%0d", p.x, p.y);
        end

        // T7: Packed struct full assignment pattern
        begin
            packed_pair_t p;
            p = '{upper: 8'hAA, lower: 8'h55};
            if (p.upper == 8'hAA && p.lower == 8'h55) begin
                $display("T7: PASS - packed struct pattern");
                pass_count++;
            end else
                $display("T7: FAIL");
        end

        // T8: Struct array
        begin
            point_t points[3];
            points[0].x = 0; points[0].y = 0; points[0].name = "origin";
            points[1].x = 1; points[1].y = 0; points[1].name = "right";
            points[2].x = 0; points[2].y = 1; points[2].name = "up";
            if (points[0].name == "origin" && points[1].x == 1 && points[2].y == 1) begin
                $display("T8: PASS - struct array");
                pass_count++;
            end else
                $display("T8: FAIL");
        end

        // T9: Struct with queue member foreach
        begin
            typedef struct {
                int q[$];
            } sq_t;
            sq_t s;
            static int total = 0;
            s.q = '{1, 2, 3, 4};
            foreach (s.q[i])
                total += s.q[i];
            if (total == 10) begin
                $display("T9: PASS - struct queue foreach total=%0d", total);
                pass_count++;
            end else
                $display("T9: FAIL - total=%0d", total);
        end

        // T10: Nested struct
        begin
            typedef struct {
                int val;
            } inner_t;
            typedef struct {
                inner_t a, b;
            } outer_t;
            outer_t o;
            o.a.val = 10;
            o.b.val = 20;
            if (o.a.val == 10 && o.b.val == 20) begin
                $display("T10: PASS - nested struct");
                pass_count++;
            end else
                $display("T10: FAIL");
        end

        // T11: Class handle semantics
        begin
            static SimpleObj a = new(10, "shared");
            SimpleObj b;
            b = a;
            b.value = 99;
            if (a.value == 99) begin
                $display("T11: PASS - class handle semantics");
                pass_count++;
            end else
                $display("T11: FAIL - a.value=%0d", a.value);
        end

        // T12: Packed struct to logic vector conversion
        begin
            packed_pair_t p;
            logic [15:0] v;
            p.upper = 8'h12;
            p.lower = 8'h34;
            v = p;
            if (v == 16'h1234) begin
                $display("T12: PASS - packed struct to vector");
                pass_count++;
            end else
                $display("T12: FAIL - v=%0h", v);
        end

        // T13: Logic vector to packed struct
        begin
            packed_pair_t p;
            p = 16'hABCD;
            if (p.upper == 8'hAB && p.lower == 8'hCD) begin
                $display("T13: PASS - vector to packed struct");
                pass_count++;
            end else
                $display("T13: FAIL");
        end

        // T14: Struct equality
        begin
            point_t a, b;
            a.x = 1; a.y = 2; a.name = "test";
            b.x = 1; b.y = 2; b.name = "test";
            if (a == b) begin
                b.x = 3;
                if (a != b) begin
                    $display("T14: PASS - struct equality");
                    pass_count++;
                end else
                    $display("T14: FAIL - should be not equal");
            end else
                $display("T14: FAIL - should be equal");
        end

        // T15: Packed union
        begin
            typedef union packed {
                logic [15:0] word;
                struct packed {
                    logic [7:0] hi;
                    logic [7:0] lo;
                } bytes;
            } word_u;
            word_u u;
            u.word = 16'hDEAD;
            if (u.bytes.hi == 8'hDE && u.bytes.lo == 8'hAD) begin
                $display("T15: PASS - packed union");
                pass_count++;
            end else
                $display("T15: FAIL");
        end

        // T16: Class null check
        begin
            SimpleObj obj;
            obj = null;
            if (obj == null) begin
                obj = new(5, "created");
                if (obj != null && obj.value == 5) begin
                    $display("T16: PASS - null check");
                    pass_count++;
                end else
                    $display("T16: FAIL - created");
            end else
                $display("T16: FAIL - not null initially");
        end

        // T17: Packed struct array element
        begin
            packed_pair_t arr[4];
            arr[0] = 16'h1234;
            arr[1] = 16'h5678;
            arr[2] = 16'h9ABC;
            arr[3] = 16'hDEF0;
            if (arr[0].upper == 8'h12 && arr[1].lower == 8'h78 &&
                arr[2].upper == 8'h9A && arr[3].lower == 8'hF0) begin
                $display("T17: PASS - packed struct array");
                pass_count++;
            end else
                $display("T17: FAIL");
        end

        // T18: Struct default values
        begin
            point_t p;
            if (p.x == 0 && p.y == 0 && p.name == "") begin
                $display("T18: PASS - struct defaults");
                pass_count++;
            end else
                $display("T18: FAIL");
        end

        // T19: Object created in a static initializer
        begin
            static SimpleObj base = new(100, "base");
            if (base.value == 100 && base.label == "base") begin
                $display("T19: PASS - class basic");
                pass_count++;
            end else
                $display("T19: FAIL");
        end

        // T20: Struct members in an expression
        begin
            point_t p;
            p.x = 5; p.y = 10; p.name = "fn_test";
            begin
                int sum;
                sum = p.x + p.y;
                if (sum == 15 && p.name == "fn_test") begin
                    $display("T20: PASS - struct members in expression");
                    pass_count++;
                end else
                    $display("T20: FAIL");
            end
        end

        $display("pass_count = %0d / %0d", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS: test_ct_struct_class_pairs");
        else
            $display("FAIL: test_ct_struct_class_pairs (pass_count=%0d/%0d)", pass_count, test_count);
        $finish;
    end
endmodule
