#! /bin/bash

my_dir=$(pwd)

scan_file(){
    file_path=$1
    file=$(basename -- "$file_path")
    first_line=$(head -n 1 "$file_path")
    if [[ "$first_line" == "#!"* ]]; then
        echo
        echo "###############################################"
        echo "         Scanning $file"
        echo "###############################################"
        shellcheck -x "$file_path"
        exit_code=$?
        if [ $exit_code -eq 0 ] ; then
            printf "%b" "Successfully scanned ${file_path} 🙌\n"
        else
            exit $exit_code
            printf "\e[31m ERROR: ShellCheck detected issues in %s.\e[0m\n" "${file_path} 🐛"
        fi
    else
        printf "\n\e[33m ⚠️  Warning: '%s' is not a valid shell script. Make sure shebang is on the first line.\e[0m\n" "$file_path"
    fi
}

scan_all(){
    echo "Scanning all the shell scripts at $1 🔎"
    while IFS= read -r script 
    do
        first_line=$(head -n 1 "$script")
        if [[ "$first_line" == "#!"* ]]; then
            scan_file "$script"
        else
            printf "\n\e[33m ⚠️  Warning: '%s' is not scanned. If it is a shell script, make sure shebang is on the first line.\e[0m\n" "$script"
        fi
    done < <(find "$1" -name '*.sh' -o ! -name '*.*' -type f ! -path "$1/.git/*" ! -path "$1/node_modules/*")
}

scan_all "$my_dir"