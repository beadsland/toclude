{CompositeDisposable} = require 'atom'

Block = require './block'
Util = require './util'
deny = Util.deny

note = atom.notifications

module.exports = Toclude =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
                                         'toclude:run': => @run()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  run: ->
    note.addSuccess('toclude running')
    try @do_run() catch error
      if error.guard? then note.addError("#{error.message}")
      else note.addFatalError(error.stack)

  do_run: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    return unless editor.getGrammar().scopeName is "source.gfm"

    text = editor.getBuffer().getText()

    closers = Block.find_block_closers(text)
    nonclosers = Block.find_noncloser_comments(text)
    blocks = Block.find_blocks_from_closers(text, closers)
    nonblocks = Block.find_nonblocks_from_blocks(text, blocks)
    tocludes = Block.find_tocludes_comments(text)
    first = Block.find_first_bullet_from_nonblocks(text, nonblocks)

    if first then note.addInfo("first '#{first.line}' at #{first.start}")

    tag = 'BOO'
    text = Block.insert_block_unless_found(text, tag)
    editor.getBuffer().setText(text)
