import yaml
import subprocess
import argparse

def load_config(config_path):
    with open(config_path) as f:
        return yaml.safe_load(f)

def generate_yosys_script(config, top_level):
    global_cfg = config.get("global", {})
    verilog_sources = global_cfg.get("verilog_sources", [])
    incdirs = global_cfg.get("verilog_include_dirs", [])

    if incdirs:
        incdir_flag = "+incdir+" + "+".join(d.rstrip('/') + '/' for d in incdirs)
    else:
        incdir_flag = ""

    # Put all source files in one read_systemverilog command
    files_str = " ".join(verilog_sources)

    lines = []
    lines.append(f'read_systemverilog +define+synthesis {incdir_flag} {files_str}')

    if top_level:
        lines.append(f'hierarchy -top {top_level}')

    lines.append("flatten")
    lines.append("synth")
    lines.append('write_json synth_out.json')

    return "\n".join(lines)



def write_script(script_text, filename="run.ys"):
    with open(filename, "w") as f:
        f.write(script_text)
    print(f"Wrote Yosys script to {filename}")

def run_yosys(script_file="run.ys"):
    print(f"Running Yosys with script {script_file} ...")
    subprocess.run(["synlig", "-s", script_file], check=True)

def main():
    parser = argparse.ArgumentParser(description="Generate and run Yosys from config.yaml")
    parser.add_argument("--config", default="config.yaml", help="Path to YAML config file")
    parser.add_argument("--top", default=None, help="Top-level module name for synthesis")
    args = parser.parse_args()

    config = load_config(args.config)
    script_text = generate_yosys_script(config, args.top)
    write_script(script_text)
    run_yosys()

if __name__ == "__main__":
    main()
