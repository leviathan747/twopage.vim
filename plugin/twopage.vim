function! EnableTwoPage()

  if (line('$') <= line('w$'))

    echom "No point in enabling two page editing for a small document"

  else

    " Initialize windows
    vsplit
    let b:left_winid = win_getid()
    let b:right_winid = win_getid(winnr('1l'))
    call s:TwoPageSyncWindows()

    " Set up autocommand
    augroup TwoPage
      autocmd!
      autocmd CursorMoved * :call s:TwoPageHandleMove()
      exe 'autocmd WinClosed ' . b:left_winid . ' :call DisableTwoPage()'
      exe 'autocmd WinClosed ' . b:right_winid . ' :call DisableTwoPage()'
    augroup end

    let b:two_page_enable = 1

    echom "Two page editing enabled"

  end

endfunction


function! DisableTwoPage()

  " Remove autocommand
  augroup TwoPage
    autocmd!
  augroup end

  let b:two_page_enable = 0

  echom "Two page editing disabled"

endfunction


function! s:TwoPageHandleMove()
  if exists('b:left_winid')

    " Determine target
    let target_pos = getcurpos()

    " Jump to right window
    if ((win_getid() == b:left_winid) && (target_pos[1] >= b:right_top))
      call win_gotoid(b:right_winid)
      call setpos('.', target_pos)

    " Jump to left window
    elseif ((win_getid() == b:right_winid) && (target_pos[1] < b:right_top))
      call win_gotoid(b:left_winid)
      call setpos('.', target_pos)
    end

    " Update window positions
    call s:TwoPageSyncWindows()

  end
endfunction


function! s:TwoPageSyncWindows()
  " Keep windows in sync
  let offset = (line('w0', b:right_winid) - line('w$', b:left_winid)) - 1
  if (offset < 0)
    if (win_getid() == b:left_winid)
      call win_execute(b:right_winid, 'exe "normal ' . (-1 * offset) . '\<c-e>"')
    elseif (win_getid() == b:right_winid)
      call win_execute(b:left_winid, 'exe "normal ' . (-1 * offset) . '\<c-y>"')
    end
  elseif (offset > 0)
    if (win_getid() == b:left_winid)
      call win_execute(b:right_winid, 'exe "normal ' . offset . '\<c-y>"')
    elseif (win_getid() == b:right_winid)
      call win_execute(b:left_winid, 'exe "normal ' . offset . '\<c-e>"')
    end
  end
  let b:left_top = line('w0', b:left_winid)
  let b:right_top = line('w0', b:right_winid)
endfunction
