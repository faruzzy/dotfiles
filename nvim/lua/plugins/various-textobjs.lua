-- Extra text objects (by nvim-spider's author; iS/aS pair with spider's subword motions). Use them
-- after an operator (d, c, y, …) or in visual mode. Most search forward, so the cursor only needs
-- to be on the same line, before the target.
--
-- Mapped (i = inside, a = around, usually adding the separator or surrounding space):
--   Keys          Selects                                   Example
--   iS / aS       One part of a camelCase, snake_case or    ciS on fetchUserData changes just User
--                 kebab-case word
--   iv / av       The value in `key: value`, or the right   civ on `timeout: 5000,` changes 5000
--                 side of `=`; av adds the trailing , or ;  (acts on the first : or = of the line)
--   ik / ak       The key, or the left side of `=`          cik renames a property
--   im / am       One link of a chain like foo.bar().baz    dam removes .filter(Boolean) from a chain
--   iq / aq       Inside the nearest ", ' or ` quotes       ciq instead of choosing ci" / ci' / ci`
--   io / ao       Inside the nearest (), [] or {}           cio instead of choosing ci( / ci[ / ci{
--   ii / ai / aI  The block at the current indent; ai adds  dii empties a block in YAML, Lua, Python
--                 the line above, aI the lines above and
--                 below
--   in / an       A number; an adds sign and decimals       cin changes the next number on the line
--   gG            The whole buffer                          ygG copies the file
--   iu / au       A URL (both keys select the whole URL)    yiu copies the link on the line
--   ix / ax       An HTML or JSX attribute (treesitter,     dax removes className="…"
--                 mapped in plugins/treesitter.lua)
--   iC / aC       A Markdown fenced code block (treesitter) diC empties the code block
--
-- Not mapped. Their default keys would shadow built-in ones; give one a free key if it's useful:
--   Default  Object                  Selects                                 Default key shadows
--   n        nearEoL                 Cursor to end of line, minus last char  dn (to next search match)
--   r        restOfParagraph         Like }, but linewise                    visual r (replace)
--   R        restOfIndentation       Lines below with the same indentation   visual R (replace lines)
--   C        toNextClosingBracket    Cursor to the next ), ] or }            visual C (change lines)
--   Q        toNextQuotationMark     Cursor to the next quote                visual Q (macro per line)
--   L        url                     (mapped to iu/au instead)               L (bottom of window)
--   gw       visibleInWindow         Lines visible in the window             gw (format operator)
--   gW       restOfWindow            Cursor line to the window's last line   -
--   g;       lastChange              The last change, yank or paste          g; (older change position)
--   !        diagnostic              The diagnostic under/after the cursor   ! (filter operator)
--   ig / ag  greedyOuterIndentation  Indent block plus surrounding blank     -
--                                    lines (a function with its comments)
--   i_ / a_  lineCharacterwise       The current line, characterwise         -
--   |        column                  A column down to a shorter line         | (to column N)
--   iz / az  closedFold              A closed fold                           -
--   i, / a,  argument                A comma-separated argument (ia/aa from  -
--                                    treesitter is more accurate)
--   iF / aF  filepath                A UNIX file path                        -
--   i# / a#  color                   A hex, rgb(), hsl() or ANSI color       -
--   iD / aD  doubleSquareBrackets    Text inside [[ ]] (Lua long strings)    -
--   iN / aN  notebookCell            A Jupytext `# %%` cell                  -
--   .        emoji                   An emoji or Nerd Font glyph             -
--
-- Mapped as <cmd> strings: called as Lua functions they don't dot-repeat
local function obj(lhs, call, desc)
  return { lhs, '<cmd>lua require("various-textobjs").' .. call .. '<CR>', mode = { 'o', 'x' }, desc = desc }
end

return {
  'chrisgrieser/nvim-various-textobjs',
  keys = {
    obj('iS', 'subword("inner")', 'Subword'),
    obj('aS', 'subword("outer")', 'Subword with separator'),
    obj('iv', 'value("inner")', 'Value (right of : or =)'),
    obj('av', 'value("outer")', 'Value with trailing , or ;'),
    obj('ik', 'key("inner")', 'Key (left of : or =)'),
    obj('ak', 'key("outer")', 'Key with the : or ='),
    obj('im', 'chainMember("inner")', 'Chain member'),
    obj('am', 'chainMember("outer")', 'Chain member with its .'),
    obj('iq', 'anyQuote("inner")', 'Inside nearest quotes'),
    obj('aq', 'anyQuote("outer")', 'Nearest quotes'),
    obj('io', 'anyBracket("inner")', 'Inside nearest brackets'),
    obj('ao', 'anyBracket("outer")', 'Nearest brackets'),
    obj('ii', 'indentation("inner", "inner")', 'Indented block'),
    obj('ai', 'indentation("outer", "inner")', 'Indented block and the line above'),
    obj('aI', 'indentation("outer", "outer")', 'Indented block and the lines around it'),
    obj('in', 'number("inner")', 'Number'),
    obj('an', 'number("outer")', 'Number with sign and decimals'),
    obj('gG', 'entireBuffer()', 'Entire buffer'),
    -- url() has no inner/outer; both keys select the whole URL (its default, L, is a motion)
    obj('iu', 'url()', 'URL'),
    obj('au', 'url()', 'URL'),
  },
}
