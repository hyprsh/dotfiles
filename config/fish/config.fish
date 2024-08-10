
# env vars
set -Ux EDITOR nvim
set -Ux TZ Europe/Zurich


if status is-interactive
  # theme
  fish_config theme choose "Rosé Pine"
end

zoxide init fish --cmd cd | source
