script_patth=$(realpath "${BASH_SOURCE[0]}")
this_script_dir=$(dirname "$script_patth")
[ -d $this_script_dir ] && export PATH="$PATH:$this_script_dir"
