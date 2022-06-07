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
    if (((winnr('1l') != winnr()) && (winbufnr(winnr('1l')) == winbufnr(winnr()))) && (target_pos[1] >= b:right_top))
      let left_offset = (line('w0') - b:left_top)
      exe 'normal! ' . left_offset . '\<c-y>'
      wincmd l
      call setpos('.', target_pos)

    " Jump to left window
    elseif (((winnr('1h') != winnr()) && (winbufnr(winnr('1h')) == winbufnr(winnr()))) && (target_pos[1] < b:right_top))
      let right_offset = (b:right_top - line('w0'))
      exe 'normal! ' . right_offset . '\<c-e>'
      wincmd h
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
