/*
:name: test_dynamic_array_methods
:description: Test for IEEE 1800-2023 §7.5-7.6: Dynamic array methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.12 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_methods.expected
*/
// Test for IEEE 1800-2023 §7.5 and §7.12: Dynamic array methods

module test_dynamic_array_methods;
    int dyn[];
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Dynamic Array Methods Test ===");

        // Test new(size)
        dyn = new[5];
        if (dyn.size() == 5) begin
            $display("PASS: new[5] - size = %0d", dyn.size());
            pass_count++;
        end else begin
            $display("FAIL: new[5] expected size 5, got %0d", dyn.size());
            fail_count++;
        end

        // Initialize values
        foreach (dyn[i]) dyn[i] = (i + 1) * 10;

        // Test size()
        result = dyn.size();
        if (result == 5) begin
            $display("PASS: dyn.size() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn.size() expected 5, got %0d", result);
            fail_count++;
        end

        // Test delete() - clear array
        dyn.delete();
        if (dyn.size() == 0) begin
            $display("PASS: delete() - size = %0d", dyn.size());
            pass_count++;
        end else begin
            $display("FAIL: delete() expected size 0, got %0d", dyn.size());
            fail_count++;
        end

        // Re-initialize for method tests
        dyn = '{50, 20, 40, 10, 30};

        // Test sum()
        result = dyn.sum();
        if (result == 150) begin
            $display("PASS: dyn.sum() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn.sum() expected 150, got %0d", result);
            fail_count++;
        end

        // Test product()
        dyn = '{1, 2, 3, 4, 5};
        result = dyn.product();
        if (result == 120) begin
            $display("PASS: dyn.product() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn.product() expected 120, got %0d", result);
            fail_count++;
        end

        // Test min()
        dyn = '{50, 20, 40, 10, 30};
        begin
            int min_q[$];
            min_q = dyn.min();
            if (min_q.size() > 0 && min_q[0] == 10) begin
                $display("PASS: dyn.min() = %0d", min_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.min() expected 10");
                fail_count++;
            end
        end

        // Test max()
        begin
            int max_q[$];
            max_q = dyn.max();
            if (max_q.size() > 0 && max_q[0] == 50) begin
                $display("PASS: dyn.max() = %0d", max_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.max() expected 50");
                fail_count++;
            end
        end

        // Test reverse()
        dyn = '{1, 2, 3, 4, 5};
        dyn.reverse();
        if (dyn[0] == 5 && dyn[4] == 1) begin
            $display("PASS: dyn.reverse() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn[0], dyn[1], dyn[2], dyn[3], dyn[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn.reverse() incorrect");
            fail_count++;
        end

        // Test sort()
        dyn = '{50, 20, 40, 10, 30};
        dyn.sort();
        if (dyn[0] == 10 && dyn[4] == 50) begin
            $display("PASS: dyn.sort() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn[0], dyn[1], dyn[2], dyn[3], dyn[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn.sort() incorrect");
            fail_count++;
        end

        // Test rsort()
        dyn.rsort();
        if (dyn[0] == 50 && dyn[4] == 10) begin
            $display("PASS: dyn.rsort() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn[0], dyn[1], dyn[2], dyn[3], dyn[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn.rsort() incorrect");
            fail_count++;
        end

        // Test shuffle()
        dyn = '{1, 2, 3, 4, 5};
        dyn.shuffle();
        // The order is random, so sort and check the elements
        dyn.sort();
        if (dyn.size() == 5 && dyn[0] == 1 && dyn[1] == 2 && dyn[2] == 3 && dyn[3] == 4 && dyn[4] == 5) begin
            $display("PASS: dyn.shuffle() kept the elements");
            pass_count++;
        end else begin
            $display("FAIL: dyn.shuffle() changed the elements");
            fail_count++;
        end

        // Test find() with with-clause
        dyn = '{1, 5, 2, 5, 3};
        begin
            int found_q[$];
            found_q = dyn.find() with (item == 5);
            if (found_q.size() == 2) begin
                $display("PASS: dyn.find() with item==5 found %0d elements", found_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn.find() expected 2, got %0d", found_q.size());
                fail_count++;
            end
        end

        // Test find_index()
        begin
            int idx_q[$];
            idx_q = dyn.find_index() with (item > 2);
            // Locator methods traverse the array in an unspecified order (7.12.1)
            idx_q.sort();
            if (idx_q.size() == 3 && idx_q[0] == 1 && idx_q[1] == 3 && idx_q[2] == 4) begin
                $display("PASS: dyn.find_index() with item>2 found %0d indices", idx_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn.find_index() with item>2 found %0d indices", idx_q.size());
                fail_count++;
            end
        end

        // Test find_first()
        begin
            int first_q[$];
            first_q = dyn.find_first() with (item > 3);
            if (first_q.size() > 0) begin
                $display("PASS: dyn.find_first() with item>3 = %0d", first_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.find_first()");
                fail_count++;
            end
        end

        // Test find_first_index()
        begin
            int idx_q[$];
            idx_q = dyn.find_first_index() with (item == 5);
            if (idx_q.size() > 0) begin
                $display("PASS: dyn.find_first_index() with item==5 = %0d", idx_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.find_first_index()");
                fail_count++;
            end
        end

        // Test find_last()
        begin
            int last_q[$];
            last_q = dyn.find_last() with (item == 5);
            if (last_q.size() > 0) begin
                $display("PASS: dyn.find_last() with item==5 = %0d", last_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.find_last()");
                fail_count++;
            end
        end

        // Test find_last_index()
        begin
            int idx_q[$];
            idx_q = dyn.find_last_index() with (item == 5);
            if (idx_q.size() > 0) begin
                $display("PASS: dyn.find_last_index() with item==5 = %0d", idx_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn.find_last_index()");
                fail_count++;
            end
        end

        // Test unique()
        dyn = '{1, 2, 1, 3, 2, 4, 1};
        begin
            int uniq_q[$];
            uniq_q = dyn.unique();
            if (uniq_q.size() == 4) begin
                $display("PASS: dyn.unique() = %0d unique elements", uniq_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn.unique() expected 4, got %0d", uniq_q.size());
                fail_count++;
            end
        end

        // Test unique_index()
        begin
            int idx_q[$];
            idx_q = dyn.unique_index();
            if (idx_q.size() == 4) begin
                $display("PASS: dyn.unique_index() = %0d unique indices", idx_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn.unique_index() expected 4, got %0d", idx_q.size());
                fail_count++;
            end
        end

        // Summary
        $display("\n=== Dynamic Array Methods Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
