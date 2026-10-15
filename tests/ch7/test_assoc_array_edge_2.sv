/*
:name: test_assoc_array_edge_2
:description: Test: Associative array edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_edge_2.expected
*/
// Test: Associative array edge cases
module test_assoc_array_edge_2;
    int pass_count = 0;
    int test_count = 0;
    
    int aa[string];
    string sa[int];
    int ia[*];
    
    initial begin
        // Test 1: Initial empty
        test_count++;
        if (aa.num() == 0) pass_count++;
        
        // Test 2: Add element
        test_count++;
        aa["one"] = 1;
        aa["two"] = 2;
        aa["three"] = 3;
        if (aa.num() == 3) pass_count++;
        
        // Test 3: Access element
        test_count++;
        if (aa["two"] == 2) pass_count++;
        
        // Test 4: Exists check
        test_count++;
        if (aa.exists("one")) pass_count++;
        
        // Test 5: Non-existent key
        test_count++;
        if (!aa.exists("four")) pass_count++;
        
        // Test 6: Delete element
        test_count++;
        aa.delete("two");
        if (aa.num() == 2) pass_count++;
        
        // Test 7: Int key array
        test_count++;
        sa[100] = "hundred";
        sa[200] = "two_hundred";
        if (sa[100] == "hundred") pass_count++;
        
        // Test 8: First/Last
        test_count++;
        begin
            string first_key;
            // string keys are ordered lexically: "one" < "three" (7.8.2)
            if (aa.first(first_key) && first_key == "one")
                pass_count++;
        end
        
        // Test 9: Clear all
        test_count++;
        aa.delete();
        if (aa.num() == 0) pass_count++;
        
        // Test 10: Wildcard index
        test_count++;
        ia[1] = 10;
        ia[1000] = 20;
        if (ia.num() == 2) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
