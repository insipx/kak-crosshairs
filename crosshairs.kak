set-face global crosshairs_line default,rgb:383838+bd
set-face global crosshairs_column default,rgb:383838+bd

declare-option bool highlight_current_line false
declare-option str highlight_current_line_hook_cmd "nop"
declare-option bool highlight_current_column false
declare-option str highlight_current_column_hook_cmd "nop"

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

define-command -hidden crosshairs-update %{
    evaluate-commands %{
    %opt(highlight_current_line_hook_cmd)
    %opt(highlight_current_column_hook_cmd)
}}

define-command -hidden -docstring "update hooks for highlighters" \
crosshairs-change-hooks %{
    evaluate-commands %sh{
        # set actions
        if [ "$kak_opt_highlight_current_line" = true ]; then
            printf "%s\n" "set-option global highlight_current_line_hook_cmd crosshairs-highlight-line"
        else
            printf "%s\n" "try %(remove-highlighter window/crosshairs-line)"
            printf "%s\n" "set-option global highlight_current_line_hook_cmd nop"
        fi
        if [ "$kak_opt_highlight_current_column" = true ]; then
            printf "%s\n" "set-option global highlight_current_column_hook_cmd crosshairs-highlight-column"
        else
            printf "%s\n" "try %(remove-highlighter window/crosshairs-column)"
            printf "%s\n" "set-option global highlight_current_column_hook_cmd nop"
        fi
        # set hook
        if [ "$kak_opt_highlight_current_column" = true ] || [ "$kak_opt_highlight_current_line" = true ]; then
            printf "%s\n" "hook global -group crosshairs RawKey .+ crosshairs-update"
        else
            printf "%s\n" "remove-hooks global crosshairs"
        fi
    }
}

define-command crosshairs -docstring "Toggle Crosshairs or line/col highlighting" %{
    evaluate-commands %sh{
        if [ "$kak_opt_highlight_current_column" = true ] && [ "$kak_opt_highlight_current_line" = true ]; then
            printf "%s\n" "set-option global highlight_current_line false"
            printf "%s\n" "set-option global highlight_current_column false"
        else
            printf "%s\n" "set-option global highlight_current_line true"
            printf "%s\n" "set-option global highlight_current_column true"
        fi
    }
    crosshairs-change-hooks
    crosshairs-update
}

define-command cursorline -docstring "Toggle Highlighting for current line" %{
    evaluate-commands %sh{
        if [ "$kak_opt_highlight_current_line" = true ] ; then
            printf "%s\n" "set-option global highlight_current_line false"
        else
            printf "%s\n" "set-option global highlight_current_line true"
        fi
    }
    crosshairs-change-hooks
    crosshairs-update
}

define-command cursorcolumn -docstring "Toggle highlighting for current column" %{
    evaluate-commands %sh{
        if [ "$kak_opt_highlight_current_column" = true ] ; then
            printf "%s\n" "set-option global highlight_current_column false"
        else
            printf "%s\n" "set-option global highlight_current_column true"
        fi
    }
    crosshairs-change-hooks
    crosshairs-update
}


