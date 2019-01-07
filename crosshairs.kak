declare-option str highlight_line_face default,rgb:383838+bd
declare-option bool crosshair_mode true
declare-option bool highlight_current_line false
declare-option bool highlight_current_column false

define-command -hidden highlight-current-column %{ evaluate-commands -save-regs 'CT' %{
  try %(remove-highlighter window/cursor-column)
  evaluate-commands -draft %{
    try %{
      execute-keys '<space><a-h>s\t<ret>'
      set-register T %sh(count() { echo $#; }; count $kak_selections_desc)
    } catch %{
      set-register T 0
    }
  }
  set-register C %sh{
    echo $(((kak_cursor_column - kak_main_reg_T) + (kak_main_reg_T * kak_opt_tabstop)))
  }
  add-highlighter window/cursor-column column %reg(C) %opt{highlight_line_face}
}}

define-command -hidden highlight-current-line -docstring "Highlight current line" %{
    try %{ remove-highlighter window/cursor-line }
    add-highlighter window/cursor-line line %val{cursor_line} %opt{highlight_line_face}
}

hook global RawKey .+ show-line-col-highlighters

define-command -hidden show-line-col-highlighters %{
    eval %sh{
        if [ "$kak_opt_crosshair_mode" = true ] ; then
          echo "highlight-current-line ; highlight-current-column"
        fi

        if [ "$kak_opt_highlight_current_line" = true ] ; then
          echo "highlight-current-line"
        fi

        if [ "$kak_opt_highlight_current_column" = true ] ; then
          echo "highlight-current-column"
        fi
    }
}

define-command toggle-crosshairs -docstring "Toggle Crosshairs or line/col highlighting" %{
    eval %sh{
        if [ "$kak_opt_crosshair_mode" = true ] ; then
            echo 'set-option global crosshair_mode false'
            echo 'try %(remove-highlighter window/cursor-column)'
            echo 'try %(remove-highlighter window/cursor-line)'
        else
            echo 'set-option global crosshair_mode true'
            echo 'highlight-current-line; highlight-current-column'
        fi
    }
}

define-command toggle-current-line-highlight -docstring "Toggle Highlighting for current line" %{
    eval %sh{
        if [ "$kak_opt_highlight_current_line" = true ] ; then
            echo 'set-option global highlight_current_line false'
            echo 'try %(remove-highlighter window/cursor-line)'
        else
            echo 'set-option global highlight_current_line true'
            echo 'highlight-current-line'
        fi
    }
}

define-command toggle-current-column-highlight -docstring "Toggle highlighting for current column" %{
    eval %sh{
        if [ "$kak_opt_highlight_current_column" = true ] ; then
            echo 'set-option global highlight_current_column false'
            echo 'try %(remove-highlighter window/cursor-column)'
        else
            echo 'set-option global highlight_current_column true'
            echo 'highlight-current-column'
        fi
    }
}


