import subprocess
import sys
import os

# Update this to the full path to Rscript.exe on your system
RSCRIPT_PATH = r"C:\Program Files\R\R-4.4.2\bin\Rscript.exe"

def run_r_scripts(r_scripts_dir, r_scripts):
    # Check that the scripts directory exists
    if not os.path.isdir(r_scripts_dir):
        print(f"Error: The directory '{r_scripts_dir}' does not exist.")
        sys.exit(1)

    for script_name in r_scripts:
        script_path = os.path.join(r_scripts_dir, script_name)
        
        # Ensure the script file exists
        if not os.path.isfile(script_path):
            print(f"Error: {script_path} does not exist.")
            sys.exit(1)
        
        # Run the R script using the full path to Rscript
        print(f"Running {script_path}...")
        result = subprocess.run([RSCRIPT_PATH, script_path], capture_output=True, text=True)
        
        # Check if the execution was successful
        if result.returncode == 0:
            print(f"Successfully finished {script_name}.")
        else:
            print(f"Error running {script_name}. Return code: {result.returncode}")
            print("Standard Output:")
            print(result.stdout)
            print("Standard Error:")
            print(result.stderr)
            sys.exit(result.returncode)
    print("All scripts have been successfully executed.")

if __name__ == "__main__":
    # List the R scripts you want to run
    r_scripts_to_run = [
        "gep_wateruse_01_clean_aquastats_waterefficiency.R",
        "gep_wateruse_02_calc_gep_wateruse.R"
    ]
    
    # Directory where R scripts are located
    r_scripts_directory = "scripts"
    
    run_r_scripts(r_scripts_directory, r_scripts_to_run)
