script_patth=$(realpath "${BASH_SOURCE[0]}")
this_script_dir=$(dirname "$script_patth")

if [ -d $this_script_dir ]
then
    export PATH="$PATH:$this_script_dir"
    if type "register-python-argcomplete" > /dev/null 2>&1
    then
        eval "$(register-python-argcomplete rose)"
    fi
fi
