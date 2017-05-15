Block = require './block'

note = atom.notifications

module.exports =
  find_trash_comment: (text) ->
    comments = Block.find_garbage_comments(text)
    trash = (can for can in comments when can.name is "TRASH")
    if trash.length
      trash[0].content = trash[0].paramstr
      return trash[0]
    else return null

  append_trash_comment: (editor, trash) ->
    editor.getBuffer().append("\n\n<!-- TRASH:\n#{trash}\n -->")

  replace_trash_comment: (editor, trash) ->
    point = editor.getCursorBufferPosition()
    editor.getBuffer().replace(/\n*<!-- TRASH:[\s\S]*?-->/, "")
    @append_trash_comment(editor, trash)
    editor.setCursorBufferPosition(point)

  get_trash: (editor) ->
    text = editor.getText()
    trash = @find_trash_comment(text)
    unless trash
      text = @append_trash_comment(editor, "")
      trash = @find_trash_comment(text)
    trash.content

  compact_trash: (trash, fresh) ->
    trash.replace(RegExp("-->", 'g'), "- - >")

    seen = {}
    if fresh then for f in fresh.split("\n")
      seen[f] = true

    results = []
    for l in trash.split("\n")
      if not seen[l] then results.push(l)
      seen[l] = true
    results.join("\n")

  set_trash: (editor, trash) ->
    trash = trash.split("\n").slice(0, 25).join("\n")
    @replace_trash_comment(editor, trash)

  push_trash: (editor, stuff, fresh) ->
    trash = @get_trash(editor)
    trash = @compact_trash("#{stuff}\n#{trash}", fresh)
    @set_trash(editor, trash)
