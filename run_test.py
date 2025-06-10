import argparse
import os 
import yaml
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
import subprocess

MAKEFILE_TEMPLATE = """
export PYTHONPATH := $(PWD)/testbench:$(PYTHONPATH)
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = {verilog_sources}
TOPLEVEL = {top_module}
MODULE = {test_module}
SIM = {simulator}
EXTRA_ARGS += {extra_args}

include $(shell cocotb-config --makefiles)/Makefile.sim
"""

def generate_makefile(test_name, yaml,  output_dir):
    test = yaml['tests'][test_name]
    testbench = test.get("testbench_module")
    verilog_sources_str = " ".join(yaml['global']["verilog_sources"])
    extra_args_str = " ".join(test.get("extra_args", []))
    content = MAKEFILE_TEMPLATE.format(
        verilog_sources=verilog_sources_str,
        top_module=test["top_level"],
        test_module=test["testbench_module"],
        simulator=test.get("simulator", "verilator"),
        extra_args=extra_args_str,
    )
    filename = os.path.join(output_dir, f"Makefile.{test_name}_{testbench}")
    with open(filename, "w") as f:
        f.write(content)
    print(f"[INFO] Generated {filename}")
    return filename

def run_makefile(makefile_path, test_name):
    print(f"[RUN] Starting test '{test_name}'")
    ret = subprocess.call(["make", "-f", makefile_path])
    if ret == 0:
        print(f"[PASS] Test '{test_name}' passed")
        return (test_name, True)
    else:
        print(f"[FAIL] Test '{test_name}' failed")
        return (test_name, False)

def main(yaml_file, max_workers, selected_testbenches):
    with open(yaml_file) as f:
        data = yaml.safe_load(f)

    output_dir = "generated_makefiles"
    os.makedirs(output_dir, exist_ok=True)

    tests = data['tests'].keys()
    print(len(tests))
    if not tests:
        print("[ERROR] No tests found in YAML")
        sys.exit(1)

    # Normalize CLI selected testbenches to set for quick lookup
    selected_set = set(selected_testbenches) if selected_testbenches else None

    makefiles = []
    for test in tests:
        # Filter testbenches if user specified any
        filtered_tbns =  test if (selected_set is None or tb in selected_set) else None

        if not filtered_tbns:
            print(f"[WARN] No matching testbenches to run for test '{test}', skipping.")
            continue

        mkfile = generate_makefile(test, data, output_dir)
        makefiles.append((mkfile, f"{test}/{test}"))

    results = {}

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(run_makefile, mkfile, name): name for mkfile, name in makefiles}
        for future in as_completed(futures):
            test_name, passed = future.result()
            results[test_name] = passed

    # Summary report
    print("\n=== Test Summary ===")
    passed_tests = [n for n, p in results.items() if p]
    failed_tests = [n for n, p in results.items() if not p]

    print(f"Total tests run: {len(results)}")
    print(f"Passed: {len(passed_tests)}")
    print(f"Failed: {len(failed_tests)}")
    if failed_tests:
        print("Failed tests:")
        for t in failed_tests:
            print(f" - {t}")

    # Exit with code 1 if any failed
    if failed_tests:
        sys.exit(1)
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run cocotb tests from YAML")
    parser.add_argument("yaml_file", help="YAML file describing tests")
    parser.add_argument(
        "--testbenches",
        help="Comma-separated list of testbench names to run (default: all)",
        default=None,
    )
    parser.add_argument(
        "--jobs",
        help="Number of parallel jobs (default: 4)",
        type=int,
        default=1,
    )
    args = parser.parse_args()

    selected = args.testbenches.split(",") if args.testbenches else None

    main(args.yaml_file, max_workers=args.jobs, selected_testbenches=selected)
