sed -i 's/:/\//g;s/git@/https:\/\//g' .gitmodules
git submodule foreach 'git config --local url."git@github.com:$(basename $(pwd))".insteadOf "https://github.com/$(basename $(pwd))"'
