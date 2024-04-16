git config --global user.name "Collin Stevens"
git config --global user.email "github@collinstevens.com"
git config --global init.defaultBranch master
git config --global push.autoSetupRemote true
git config --global core.autoclrf false
git config --global rerere.enabled true
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.changelog "log --pretty=format:'%h: %s%n%n    %b'"
git config --global alias.markdown "log --reverse --pretty=format:'- **%h**: %s%n  - %b'"