set-face global crosshairs_line default,rgb:383838+bd
set-face global crosshairs_column default,rgb:383838+bd

declare-option bool crosshair_mode false
declare-option bool highlight_current_line false
declare-option bool highlight_current_column false

define-command -hidden crosshairs-highlight-column %{ evaluate-commands -save-regs 'CT' %{
    try %(remove-highlighter window/crosshairs-column)
    evaluate-commands -draft %{
        try %{
            execute-keys '<space><a-h>s\t<ret>'
            set-register T %sh(count() { printf "%s\n" $#; }; count $kak_selections_desc)
        } catch %{
            set-register T 0
        }
    }
    set-register C %sh{
        printf "%s\n" "$(((kak_cursor_char_column - kak_main_reg_T) + (kak_main_reg_T * kak_opt_tabstop)))"
    }
    add-highlighter window/crosshairs-column column %reg{C} crosshairs_column
}}

define-command -hidden crosshairs-highlight-line -docstring "Highlight current line" %{
    try %{ remove-highlighter window/crosshairs-line }
    try %{ add-highlighter window/crosshairs-line line %val{cursor_line} crosshairs_line }
}

define-command -hidden crosshairs-update %{ evaluate-commands %sh{
    if [ "$kak_opt_crosshair_mode" = "true" ]; then
        printf "%s\n" "crosshairs-highlight-line; crosshairs-highlight-column"
    else
        [ "$kak_opt_highlight_current_line" = "true" ] && printf "%s\n" "crosshairs-highlight-line"
        [ "$kak_opt_highlight_current_column" = "true" ] && printf "%s\n" "crosshairs-highlight-column"
    fi
}}

define-command crosshairs -docstring "Toggle Crosshairs or line/col highlighting" %{
    evaluate-commands %sh{
        if [ "$kak_opt_crosshair_mode" = true ] ; then
            printf "%s\n" "set-option global crosshair_mode false"
            printf "%s\n" "try %(remove-highlighter window/crosshairs-column)"
            printf "%s\n" "try %(remove-highlighter window/crosshairs-line)"
            printf "%s\n" "remove-hooks global crosshairs"
        else
            printf "%s\n" "set-option global crosshair_mode true"
            printf "%s\n" "crosshairs-highlight-line; crosshairs-highlight-column"
            printf "%s\n" "hook global -group crosshairs RawKey .+ crosshairs-update"
        fi
    }
}

define-command cursorline -docstring "Toggle Highlighting for current line" %{
    evaluate-commands %sh{
        if [ "$kak_opt_highlight_current_line" = true ] ; then
            printf "%s\n" "set-option global highlight_current_line false"
            printf "%s\n" "try %(remove-highlighter window/crosshairs-line)"
            printf "%s\n" "remove-hooks global crosshairs"
        else
            printf "%s\n" "set-option global highlight_current_line true"
            printf "%s\n" "crosshairs-highlight-line"
            printf "%s\n" "hook global -group crosshairs RawKey .+ crosshairs-update"
        fi
    }
}

define-command cursorcolumn -docstring "Toggle highlighting for current column" %{
    evaluate-commands %sh{
        if [ "$kak_opt_highlight_current_column" = true ] ; then
            printf "%s\n" "set-option global highlight_current_column false"
            printf "%s\n" "try %(remove-highlighter window/crosshairs-column)"
            printf "%s\n" "remove-hooks global crosshairs"
        else
            printf "%s\n" "set-option global highlight_current_column true"
            printf "%s\n" "crosshairs-highlight-column"
            printf "%s\n" "hook global -group crosshairs RawKey .+ crosshairs-update"
        fi
    }
}


