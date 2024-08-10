function ls --wraps='eza --group-directories-first' --wraps='eza --group-directories-first --icons=always' --description 'alias ls eza --group-directories-first --icons=always'
  eza --group-directories-first --icons=always $argv
        
end
